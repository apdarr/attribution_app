class CreateBillingMonths < ActiveRecord::Migration[7.0]
  def change
    create_table :billing_months do |t|
      t.references :business_unit, null: false, foreign_key: true
      t.date :billing_month
      t.decimal :total_cost
      t.timestamps
    end
  end
end
