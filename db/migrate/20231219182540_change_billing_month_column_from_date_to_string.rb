class ChangeBillingMonthColumnFromDateToString < ActiveRecord::Migration[7.0]
  def change
    change_column :billing_months, :billing_month, :string
  end
end
