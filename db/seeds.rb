require "json"
require "date"

# Parse the file usage_report_seed.json and seed: 
# - Three business units: bu_ops, bu_finance, bu_it
# - Randomly assign the repos to the business units
# - And finally, grab the costs from the file's data fields

puts "Cleaning and seeding the database..."

# Put them in the right order so that we can delete the records without violating foreign key constraints
BillingMonth.destroy_all
RepoCost.destroy_all
Repo.destroy_all
BusinessUnit.destroy_all


# Create the BUs if they don't already exist
BusinessUnit.find_or_create_by(id: 1) do |bu|
    bu.name = "bu_ops"
end
  
BusinessUnit.find_or_create_by(id: 2) do |bu|
    bu.name = "bu_finance"
end
  
BusinessUnit.find_or_create_by(id: 3) do |bu|
    bu.name = "bu_it"
end

puts "Opening the usage report json file..."
# Read and parse the JSON file 
file_path = Rails.root.join("db", "usage_report_seed.json")
json_data = File.read(file_path)
data = JSON.parse(json_data)

# We want to strip out any reports with empty repository names or organization names are empty, at least for now
filtered_data = data["usageItems"].select{ |report| report["repositoryName"] != "" && report["organizationName"] != "" }

# Each item here is a comma separated cost report from a given repo, per product type, for a given date
puts "Creating seed data..."
puts "Creating the repos and assigning them to a business unit..."

# We need to have two separate loops. One to assign the repo to a business unit, and another to create the repo costs
filtered_data.each_with_index do |item, index|
    repo = item["repositoryName"]
    org = item["organizationName"]

    # Randomly assign the repo to a business unit based on the .each block's index
    business_unit = if index % 2 == 0
        BusinessUnit.find_by(id: 1)
    elsif index % 3 == 0
        BusinessUnit.find_by(id: 2)
    else
        BusinessUnit.find_by(id: 3)
    end

    # If they don't already exists, create the repo, billing month, and repo cost all matching up the same business unit ID
    Repo.find_or_create_by(name: repo, business_unit_id: business_unit.id, org: org)
end

puts "Done. Seeded #{Repo.count} repos."
puts "Creating repo costs per repo and billing month..."

filtered_data.each_with_index do |item, index|
    repo = item["repositoryName"]
    date = Date.parse(item["date"]).strftime("%B %Y")
    cost = item["netAmount"]
    org = item["organizationName"]
    business_unit_id = Repo.find_by(name: repo, org: org).business_unit_id

    # If they don't already exists, create the repo, billing month, and repo cost all matching up the same business unit ID
    repo = Repo.find_by(name: repo)
    
    billing_month = BillingMonth.find_or_create_by(business_unit_id: business_unit_id, billing_month: date)
    RepoCost.find_or_create_by(cost: cost, repo_id: repo.id, billing_month_id: billing_month.id)
end