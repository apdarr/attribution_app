require "json"
require "rails"
require "haikunate"
require "debug"

#file_path = File.join("db", "usage_report_seed.json")
file_content = File.read("usage_report_seed.json")
data = JSON.parse(file_content)

org_name_map = {}
repo_name_map = {}

data["usageItems"].select! do |item|
  org_name = item["organizationName"]
  repo_name = item["repositoryName"]

  next if org_name.nil? || repo_name.nil?

  unless org_name_map.key?(org_name)
    org_name_map[org_name] = Haiku.call
  end
  item["organizationName"] = org_name_map[org_name]

  unless repo_name_map.key?(repo_name)
    repo_name_map[repo_name] = Haiku.call
  end
  item["repositoryName"] = repo_name_map[repo_name]

  true
end

File.open("usage_report_seed_sanitized.json", "w") do |f|
  f.write(JSON.pretty_generate(data))
end