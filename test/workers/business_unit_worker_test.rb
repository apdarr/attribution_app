require "test_helper"
require "json"
require "debug"

class UsageReportWorkerTest < ActiveSupport::TestCase
  def setup
    json_data = File.read(Rails.root.join("db", "repo_topics_seed.json"))
    @seed_data = JSON.parse(json_data)
  end

  test "business unit names should be created if matching prefix found" do

  end

  test "repo membership to business unit should be created if matching prefix found" do
  end

  test "worker should error if no org filter is set" do 
    # We need to know the org name to filter on for fetching repo topics and properties
  end

  test "prefix matching should handle closely related names" do 
    # In cases where the prefix is set to "bu-", we should match for "bu-*", but nothing else
    BusinessUnit.update_all(prefix: "bu-")
    close_prefixes = ["bus-", "b-", "bu-r"]
    close_prefixes.each do |prefix|
      assert_not BusinessUnit.first.prefix.start_with?(prefix)
    end
  end
end  