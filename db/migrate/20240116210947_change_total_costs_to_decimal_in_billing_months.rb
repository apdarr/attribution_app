class ChangeTotalCostsToDecimalInBillingMonths < ActiveRecord::Migration[7.0]
  def change
    change_column :billing_months, :total_cost, :decimal, precision: 10, scale: 2
  end
end
