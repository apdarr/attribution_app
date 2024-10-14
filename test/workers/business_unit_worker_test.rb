require "test_helper"
require "json"
require "debug"

class BusinessUnitWorkerTest < ActiveSupport::TestCase
  def setup
    json_data = File.read(Rails.root.join("db", "repo_topics_seed.json"))
    @seed_data = JSON.parse(json_data)
    # Simulate the user setting the prefix in the view
    BusinessUnit.update_all(prefix: "bu-")
  end

  test "business unit names should be created if matching prefix found" do
    # Assert that no business unit exists with the name "ops"
    assert_not BusinessUnit.find_by(name: "ops").present?
    # After the worker runs, the repo should exist
    BusinessUnitWorker.assign_repo_to_business_unit(@seed_data, "repo_foo")
    assert BusinessUnit.find_by(name: "ops").present?
  end

  test "repo membership to business unit should be created if matching prefix found" do
    BusinessUnitWorker.assign_repo_to_business_unit(@seed_data, "repo_foo")
    repo = Repo.find_by(name: "repo_foo")
    assert_not_nil repo.business_unit_id
  end

  test "worker should error if no org filter is set" do
    ENV["ORG_FILTER"] = nil
    assert_raises(URI::InvalidURIError) do
      BusinessUnitWorker.perform(["repo_foo"])
    end 
  end
   
  # test "prefix matching should handle closely related names" do 
  #   # In cases where the prefix is set to "bu-", we should match for "bu-*", but nothing else
  #   close_prefixes = ["bus-", "b-", "bu-r"]
  #   close_prefixes.each do |prefix|
  #     assert_not BusinessUnit.first.prefix.starts_with?(prefix)
  #   end
  # end
end  