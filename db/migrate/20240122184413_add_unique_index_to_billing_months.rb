class AddUniqueIndexToBillingMonths < ActiveRecord::Migration[7.0]
  def change
    unless index_exists?(:billing_months, [:business_unit_id, :billing_month], unique: true)
      remove_index :billing_months, [:business_unit_id, :billing_month] if index_exists?(:billing_months, [:business_unit_id, :billing_month])
      add_index :billing_months, [:business_unit_id, :billing_month], unique: true
    end
  end
end
