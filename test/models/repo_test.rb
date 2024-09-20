require "test_helper"

class RepoTest < ActiveSupport::TestCase
  setup do 
    @bu_one = business_units(:one)
  end

  test "repo should not save without a name" do 
    # Write a test that creates a repo and then verifies it has a matching business unit ID and name
    nameless_repo = Repo.new(business_unit_id: @bu_one.id)
    assert_not nameless_repo.save
  end
end
