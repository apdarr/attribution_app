require 'net/http'
require 'uri'
require 'json'

class BusinessUnitWorker
  def self.perform(repo_names)
    begin
      repo_names.each do |repo_name|
        # Find the repo's business unit membership via tags
        uri = URI.parse("https://api.github.com/repos/#{ENV["ORG_FILTER"]}/#{repo_name}/topics")
        request = Net::HTTP::Get.new(uri)
        request["Accept"] = "application/vnd.github.v3+json"
        request["Authorization"] = "Bearer #{ENV['GITHUB_TOKEN']}"
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
        response_body = JSON.parse(response.body)
        assign_repo_to_business_unit(response_body, repo_name)
      end
    rescue StandardError => e
        puts "Failed to fetch repo topic: #{e}"
    end
  end

  # This function does two important things before processing the usage cost data in UsageReportWorker:
  # 1) It assigns a Business Unit to each repo based on the repo's topic
  # 2) It creates the Repo in the database if it doesn't already exist
  def self.assign_repo_to_business_unit(response_body, repo_name)
    repo = Repo.find_or_create_by(name: repo_name)
    # For now, just grab the first matching prefix from the list and assign
    response_body["names"].each do |name|
      # Check if there's a matching prefix in the list
      prefix = BusinessUnit.first.prefix
      if prefix && name.start_with?(prefix)
        # Strip out the prefix from the name
        business_unit_name = name.gsub(prefix, "")
        business_unit = BusinessUnit.find_or_create_by(name: business_unit_name)
        repo.update(business_unit_id: business_unit.id)
        # A repo should only have one matching Business Unit, so we break out of the loop
        break
      else
         puts "No matching prefix found for Business Unit #{name}"
      end
    end
  end
end