require "test_helper"
require "json"
require "debug"

class UsageReportWorkerTest < ActiveSupport::TestCase
  def setup
    # Load in the seed JSON data
    json_data = File.read(Rails.root.join("db", "usage_report_seed.json"))
    @seed_data = JSON.parse(json_data)

    # Parse through the JSON data and randomly assign a business unit to each repo
    BusinessUnit.find_or_create_by(id: 1) do |bu|
      bu.name = "bu_ops"
    end
    
    BusinessUnit.find_or_create_by(id: 2) do |bu|
        bu.name = "bu_finance"
    end
    
    BusinessUnit.find_or_create_by(id: 3) do |bu|
        bu.name = "bu_it"
    end

    @seed_data["usageItems"].each_with_index do |item, index|
      repo = item["repositoryName"]
      # Randomly assign the repo to a business unit based on the .each block's index
      business_unit = if index % 2 == 0
        BusinessUnit.find_by(id: 1)
      elsif index % 3 == 0
        BusinessUnit.find_by(id: 2)
      else
        BusinessUnit.find_by(id: 3)
      end

      repo = Repo.find_or_create_by(name: repo, business_unit_id: business_unit.id)
    end
  end

  test "polling_status_should resume from last checked identifier" do
    # Given an arbitrary "stop" date, we want to simulate the worker picking up from where it left off
  
    # First pass, without the new records
    UsageReportWorker.parse_and_update(@seed_data)
    initial_repo_cost_count = RepoCost.count
    new_records = [
      {
        "date" => "2024-08-20T14:00:00Z",
        "product" => "actions",
        "sku" => "Actions Linux",
        "quantity" => 31.0,
        "unitType" => "Minutes",
        "pricePerUnit" => 0.008,
        "grossAmount" => 0.248,
        "discountAmount" => 0.0,
        "netAmount" => 0.248,
        "organizationName" => "ursa-minus",
        "repositoryName" => "actions-ci-cd"
      },
      {
        "date" => "2024-08-22T14:00:00Z",
        "product" => "actions",
        "sku" => "Actions Linux",
        "quantity" => 14.0,
        "unitType" => "Minutes",
        "pricePerUnit" => 0.008,
        "grossAmount" => 0.112,
        "discountAmount" => 0.0,
        "netAmount" => 0.112,
        "organizationName" => "ursa-minus",
        "repositoryName" => "verisk-setup"
      },
    ]
    # Add the new records to the seed data
    @seed_data["usageItems"].concat(new_records)
    # Rerun the job and validate that we have the right date for PollingStatus
    # We've added new data, so now let's run it again
    UsageReportWorker.parse_and_update(@seed_data)
    debugger
    assert PollingStatus.first.usage_worker_checked_identifier, "2024-08-22T14:00:00Z_veriks-setup_ursa-minus_Actions Linux"
    # Check that the new costs were added
    assert_equal initial_repo_cost_count + 2, RepoCost.count
  end

  test "UsageReportWorker should create new records in the database" do
    UsageReportWorker.parse_and_update(@seed_data)
  
    repo = Repo.find_by(name: "actions-ci-cd")
    assert repo
    
    billing_month = BillingMonth.last
    assert_equal billing_month.billing_month, "August 2024"
        
    # Ensure that the repo costs were saved correctly by referencing a total sum
    # Convert BigDecimal to a float
    january_2024_cost = BillingMonth.monthly_repo_sum(repo.name, "January 2024").to_f
    puts "January 2024 cost: #{january_2024_cost}"
    assert_equal january_2024_cost, 2.29
  end
end