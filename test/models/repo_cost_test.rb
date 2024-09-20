require "test_helper"
require "debug"

class RepoCostTest < ActiveSupport::TestCase
  setup do 
    @bu_one = business_units(:one)
    @bu_two = business_units(:two)
    @bu_three = business_units(:three)
  end
    
  test "repo_cost should be update when usage report is calculated" do
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
      2023-10-04,Actions,Compute - MACOS,4,minute,0.08,10.0,ursa-plus,foo-macos,alex,.github/workflows/main3.yml
    CSV
    
    billing_month = BillingMonth.calculate_costs(csv_data)
    # Grab all costs for repos associated with the billing month of October 2023, for a specific business unit
    oct_2023 = BillingMonth.find_by(billing_month: "October 2023", business_unit_id: @bu_one.id)
    assert oct_2023.repo_costs.first.cost > 0   
  end

  test "repo_cost calculation should resolve if there are two matching repo names in a billing month" do
    # Incorporate error handling in cases where there are somehow two repositories with the same name in a billing month
  end

end
