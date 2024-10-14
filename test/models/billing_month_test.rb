require "test_helper"

class BillingMonthTest < ActiveSupport::TestCase
  setup do
    @bu_one = business_units(:one)
    @bu_two = business_units(:two)
    @bu_three = business_units(:three)
  end
  
  test "should not save billing_month date in anything but Month Year format" do
    entry_date = "2023-09-10"
    business_unit = business_units(:one)
    BillingMonth.create(business_unit_id: business_unit.id, billing_month: entry_date, total_cost: 100.00)
    assert_equal "September 2023", BillingMonth.find_by(business_unit_id: business_unit.id).billing_month.to_s
  end

  test "calendar months should be unique for each business unit ID" do 
    BillingMonth.create(billing_month: "January 2024", business_unit_id: @bu_one.id, total_cost: 1.00)
    BillingMonth.create(billing_month: "January 2024", business_unit_id: @bu_one.id, total_cost: 2.00)

    assert_equal 1, BillingMonth.where(billing_month: "January 2024", business_unit_id: @bu_one.id).count
  end


  test "costs_per_bu should return a hash for each business units costs for a given month" do 
    month = "January 2024"
    BillingMonth.create(billing_month: month, business_unit_id: @bu_one.id, total_cost: 1.00)
    BillingMonth.create(billing_month: month, business_unit_id: @bu_two.id, total_cost: 2.00)
    BillingMonth.create(billing_month: month, business_unit_id: @bu_three.id, total_cost: 3.00)

    assert_equal BillingMonth.costs_per_bu(month), { @bu_one.id => 1.00, @bu_two.id => 2.00, @bu_three.id => 3.00 }
  end
end
