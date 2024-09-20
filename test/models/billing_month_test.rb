require "test_helper"

class BillingMonthTest < ActiveSupport::TestCase
  setup do
    @csv_data = <<-CSV
      Date,Product,SKU,Quantity,Unit Type,Price Per Unit ($),Multiplier,Owner,Repository Slug,Username,Actions Workflow,Notes
      2024-01-02,Actions,Compute - UBUNTU,4,minute,0.008,1.0,ursa-plus,foo-ubuntu,alex,.github/workflows/main1.yml
      2024-01-03,Actions,Compute - WINDOWS,6,minute,0.016,2.0,ursa-plus,foo-windows,alex,.github/workflows/main2.yml
      2024-01-03,Actions,Compute - MACOS,4,minute,0.08,10.0,ursa-plus,foo-macos,alex,.github/workflows/main3.yml
    CSV

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

  test "calculate_costs should total costs for specific business units, based on repos in CSV data" do
    # For each business unit, calculate costs
    BillingMonth.calculate_costs(@csv_data)
    
    # Grab the billing months for each business unit
    bu_one_billing_month = BillingMonth.find_by(billing_month: "January 2024", business_unit_id: @bu_one.id)
    bu_two_billing_month = BillingMonth.find_by(billing_month: "January 2024", business_unit_id: @bu_two.id)
    bu_three_billing_month = BillingMonth.find_by(billing_month: "January 2024", business_unit_id: @bu_three.id)

    # Ensure the costs have been totaled for each business unit
    assert_equal bu_one_billing_month.total_cost.to_f, 0.03
    assert_equal bu_two_billing_month.total_cost.to_f, 0.19
    assert_equal bu_three_billing_month.total_cost.to_f, 3.20
  end

  test "calculate_costs should update existing billing month if it exists" do
    BillingMonth.create(billing_month: "January 2024", business_unit_id: @bu_one.id, total_cost: 0.01)
    BillingMonth.calculate_costs(@csv_data)
    
    # Ensure the costs have been totaled for each business unit
    bu_one_billing_month = BillingMonth.find_by(billing_month: "January 2024", business_unit_id: @bu_one.id)
    assert_equal bu_one_billing_month.total_cost.to_f, 0.04
  end

  test "calendar months should be unique for each business unit ID" do 
    BillingMonth.create(billing_month: "January 2024", business_unit_id: @bu_one.id, total_cost: 1.00)
    BillingMonth.create(billing_month: "January 2024", business_unit_id: @bu_one.id, total_cost: 2.00)

    assert_equal 1, BillingMonth.where(billing_month: "January 2024", business_unit_id: @bu_one.id).count
  end

  test "should handle CSV data that spans multiple calendar months" do
    csv_data = <<-CSV
      Date,Product,SKU,Quantity,Unit Type,Price Per Unit ($),Multiplier,Owner,Repository Slug,Username,Actions Workflow,Notes
      2024-01-02,Actions,Compute - UBUNTU,4,minute,0.008,1.0,ursa-plus,foo-ubuntu,alex,.github/workflows/main1.yml
      2024-01-03,Actions,Compute - WINDOWS,6,minute,0.016,2.0,ursa-plus,foo-windows,alex,.github/workflows/main2.yml
      2024-01-03,Actions,Compute - MACOS,4,minute,0.08,10.0,ursa-plus,foo-macos,alex,.github/workflows/main3.yml
      2023-12-02,Actions,Compute - UBUNTU,4,minute,0.008,1.0,ursa-plus,foo-ubuntu,alex,.github/workflows/main1.yml
      2023-12-03,Actions,Compute - WINDOWS,6,minute,0.016,2.0,ursa-plus,foo-windows,alex,.github/workflows/main2.yml
      2023-12-03,Actions,Compute - MACOS,4,minute,0.08,10.0,ursa-plus,foo-macos,alex,.github/workflows/main3.yml
      2023-10-02,Actions,Compute - UBUNTU,4,minute,0.008,1.0,ursa-plus,foo-ubuntu,alex,.github/workflows/main1.yml
      2023-10-03,Actions,Compute - WINDOWS,6,minute,0.016,2.0,ursa-plus,foo-windows,alex,.github/workflows/main2.yml
      2023-10-03,Actions,Compute - MACOS,4,minute,0.08,10.0,ursa-plus,foo-macos,alex,.github/workflows/main3.yml
    CSV
    
    BillingMonth.calculate_costs(csv_data)
    assert_equal 3, BillingMonth.where(business_unit_id: @bu_one.id).count
    billing_month_jan = BillingMonth.find_by(billing_month: "January 2024", business_unit_id: @bu_one.id)
    billing_month_dec = BillingMonth.find_by(billing_month: "December 2023", business_unit_id: @bu_one.id)
    billing_month_oct = BillingMonth.find_by(billing_month: "October 2023", business_unit_id: @bu_one.id)

    assert_equal billing_month_oct.total_cost.to_f, 0.03
    assert billing_month_dec.total_cost == billing_month_jan.total_cost
    assert_equal 3, BillingMonth.where(business_unit_id: @bu_one.id).count
  end

  test "costs_per_bu should return a hash for each business units costs for a given month" do 
    month = "January 2024"
    BillingMonth.create(billing_month: month, business_unit_id: @bu_one.id, total_cost: 1.00)
    BillingMonth.create(billing_month: month, business_unit_id: @bu_two.id, total_cost: 2.00)
    BillingMonth.create(billing_month: month, business_unit_id: @bu_three.id, total_cost: 3.00)

    assert_equal BillingMonth.costs_per_bu(month), { @bu_one.id => 1.00, @bu_two.id => 2.00, @bu_three.id => 3.00 }
  end
end
