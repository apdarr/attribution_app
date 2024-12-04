class UsageReportJob < ApplicationJob
  queue_as :default

  def perform
    begin
      response_body = fetch_api_data
      
      #### 🧪 For testing purposes, creating the JSON file to parse 
      File.open("usage_report.json", "w") do |f|
        f.write(JSON.pretty_generate(response_body))
      end
      ### 🧪

      parse_and_update(response_body)
    rescue StandardError => e
       puts "Failed to fetch the API: #{e}"
    end
  end

  private 

  def fetch_api_data
    uri = URI.parse("https://api.github.com/enterprises/#{ENV["ENTERPRISE_SLUG"]}/settings/billing/usage")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/vnd.github.v3+json"
    request["Authorization"] = "Bearer #{ENV['GITHUB_TOKEN']}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    JSON.parse(response)
  end

  def parse_and_update(response_body)
    # Manage state to determine if we've already saved the data from the API
    new_data = false
    batch_size = 500
    records = []
    
    if ENV["ORG_FILTER"]
      filtered_data = response_body["usageItems"].select{ |report| report["organizationName"] == ENV["ORG_FILTER"] }
      # Grab the unique repository names from the filtered data
      unique_repo_names = filtered_data.map{ |report| report["repositoryName"] }.uniq
      # Send the repo names to BusinessUnitWorker to fetch the business units
      !unique_repo_names.empty? ? BusinessUnitWorker.perform(unique_repo_names) : nil
    else 
      filtered_data = response_body["usageItems"]
    end
    
    last_polling_status = PollingStatus.first_or_create
    # Strip out any reports with empty repository names or organization names
    filtered_data = filtered_data.select{ |report| report["repositoryName"] != "" && report["organizationName"] != "" }
    total_items = filtered_data.length
    
    filtered_data.each_with_index do |report, index|
      repo_name = report["repositoryName"]
      date = Date.parse(report["date"]).strftime("%B %Y")
      cost = report["netAmount"]
      sku = report["sku"]
      
      current_polling_status = "#{report["date"]}_#{report["repositoryName"]}_#{report["organizationName"]}_#{report["sku"]}"
      
      if last_polling_status.usage_worker_checked_identifier == current_polling_status
        new_data = true
        # Skip the current record, as we've already saved it to the database
        next
      end
      
      # if ["test", "development"].include?(Rails.env)
      #   puts "Parsing record: #{index + 1} of #{total_items}"
      # end
      # Approach D
      if last_polling_status.usage_worker_checked_identifier == nil
        records << { repo_name: repo_name, date: date, cost: cost, sku: sku }
        if records.size >= batch_size
          update_records(records)
          records.clear
        elsif index + 1 == total_items
          update_records(records)
          records.clear
        end
      elsif new_data
        records << { repo_name: repo_name, date: date, cost: cost, sku: sku }
        if records.size >= batch_size
          update_records(records)
          records.clear
        elsif index + 1 == total_items
          update_records(records)
          records.clear
        end
      end
      if total_items == index + 1 
        last_polling_status.update!(usage_worker_checked_identifier: current_polling_status)
      end
    end
  end

  def update_records(records)
    repo_costs = []
    records.each do |record|
      ### 🧪 Temporary logic to fetch the BusinessUnit ID, which we're using in test
      repo = Repo.find_or_create_by(name: record[:repo_name])
      business_unit_id = repo.business_unit_id
      ### 🧪 Temporary logic to fetch the BusinessUnit ID, which we're using in test
      
      billing_month = BillingMonth.find_or_create_by(business_unit_id: business_unit_id, billing_month: record[:date])
      repo_costs << RepoCost.new(
        repo_name: record[:repo_name],
        repo_id: repo.id,
        billing_month_id: billing_month.id,
        sku: record[:sku],
        cost: record[:cost]
      )
    end
    # Use activerecord-import gem to save in bulk
    RepoCost.import(repo_costs)
  end
end
