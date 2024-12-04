require "test_helper"
require "json"

class UsageReportJobTest < ActiveJob::TestCase
  def setup
    # Load in the seed JSON data
    json_data = File.read(Rails.root.join("db", "usage_report_seed.json"))
    @seed_data = JSON.parse(json_data)

    # Create business units
    BusinessUnit.find_or_create_by(id: 1) do |bu|
      bu.name = "bu_ops"
    end
    
    BusinessUnit.find_or_create_by(id: 2) do |bu|
      bu.name = "bu_finance"
    end
    
    BusinessUnit.find_or_create_by(id: 3) do |bu|
      bu.name = "bu_it"
    end

    # Assign repos to business units
    @seed_data["usageItems"].each_with_index do |item, index|
      repo = item["repositoryName"]
      business_unit = if index % 2 == 0
        BusinessUnit.find_by(id: 1)
      elsif index % 3 == 0
        BusinessUnit.find_by(id: 2)
      else
        BusinessUnit.find_by(id: 3)
      end
      repo = Repo.find_or_create_by(name: repo, business_unit_id: business_unit.id)
    end
    
    @job = UsageReportJob.new
    
    # we're stubbing the fetch_api_data method to return our test data
    class << @job
      attr_accessor :test_data
      def fetch_api_data
        self.test_data
      end
    end
    @job.test_data = @seed_data
  end

  test "polling_status_should resume from last checked identifier" do
    RepoCost.destroy_all
    assert_equal 0, RepoCost.count    

    @job.perform_now
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
      }
    ]
    
    @seed_data["usageItems"].concat(new_records)
    
    # Create repos needed for test
    Repo.create(name: "verisk-setup", business_unit_id: 2)
    Repo.create(name: "actions-ci-cd", business_unit_id: 2)

    @job.perform_now  # No need for JSON regeneration, just use the modified @seed_data

    assert_equal "2024-08-22T14:00:00Z_verisk-setup_ursa-minus_Actions Linux", 
                 PollingStatus.first.usage_worker_checked_identifier
    assert_equal initial_repo_cost_count + 2, RepoCost.count
  end

  test "job should create new records in the database" do
    @job.perform_now
  
    repo = Repo.find_by(name: "victorious-scorpion-8969")
    assert repo
    
    billing_month = BillingMonth.last
    assert_equal "August 2024", billing_month.billing_month
        
    january_2024_cost = BillingMonth.monthly_repo_sum(repo.name, "January 2024").to_f
    assert_equal 2.29, january_2024_cost
  end

  test "job can be enqueued" do
    assert_enqueued_jobs 0
    UsageReportJob.perform_later
    assert_enqueued_jobs 1
  end
end