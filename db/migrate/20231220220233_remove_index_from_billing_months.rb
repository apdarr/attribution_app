class RemoveIndexFromBillingMonths < ActiveRecord::Migration[7.0]
  def change
    remove_index :billing_months, name: "index_billing_months_on_business_unit_id_and_billing_month"
  end
end
