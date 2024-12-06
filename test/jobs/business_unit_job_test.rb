require "test_helper"

class BusinessUnitJobTest < ActiveJob::TestCase
  def setup
    json_data = File.read(Rails.root.join("db", "repo_topics_seed.json"))
    @seed_data = JSON.parse(json_data)
    # Simulate the user setting the prefix in the view
    BusinessUnit.update_all(prefix: "bu-")
    
    # @job = BusinessUnitJob.new
    # debugger
    
    # # # Stub the API call
    # # class << @job
    # #   attr_accessor :test_data
    # #   def fetch_api_data(repo_name)
    # #     self.test_data
    # #   end
    # # end
    # # @job.test_data = @seed_data
    # @repo_names = ["repo_foo"]
  end

  test "business unit names should be created if matching prefix found" do
    assert_not BusinessUnit.find_by(name: "ops").present?
    VCR.use_cassette("business_unit_job") do
      BusinessUnitJob.perform_now
    end
    assert BusinessUnit.find_by(name: "ops").present?
  end

  test "repo membership to business unit should be created if matching prefix found" do
    @job.perform_now(@repo_names)
    repo = Repo.find_by(name: "repo_foo")
    assert_not_nil repo.business_unit_id
  end

  test "job should error if no org filter is set" do
    ENV["ORG_FILTER"] = nil
    assert_raises(URI::InvalidURIError) do
      @job.perform_now(@repo_names)
    end 
  end

  test "job can be enqueued" do
    assert_enqueued_jobs 0
    BusinessUnitJob.perform_later(@repo_names)
    assert_enqueued_jobs 1
  end
end
