class BusinessUnitJob < ApplicationJob
  queue_as :default

  def initialize
    @client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
  end
  # Expects an array of repo name strings to be passed as arguments
  def perform
    raise URI::InvalidURIError, "ORG_FILTER environment variable is not set" if ENV["ORG_FILTER"].nil?
    begin
      topics = fetch_repo_topics
      assign_repo_to_business_unit(topics)
    rescue StandardError => e
        puts "Failed to fetch repo topic: #{e}"
    end
  end

  private
  
  def fetch_repo_topics
    # Get a list of repo names first
    org_repos = @client.org_repos(ENV["ORG_FILTER"]).map { |r| r.name }
    debugger
    org_repos.each do |r|
      repo_name = r.name
      topics = @client.topics("#{ENV["ORG_FILTER"]}/#{r}")
    end
    topics = @client.topics("#{ENV["ORG_FILTER"]}/#{repo_name}")
    topics
  end

  # This function does two important things before processing the usage cost data in UsageReportWorker:
  # 1) It assigns a Business Unit to each repo based on the repo's topic
  # 2) It creates the Repo in the database if it doesn't already exist
  def assign_repo_to_business_unit(topics, repo_name)
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
      end
    end
  end
end
