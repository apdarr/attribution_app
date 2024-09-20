class CreateRepoCosts < ActiveRecord::Migration[7.0]
  def change
    create_table :repo_costs do |t|
      t.timestamps
      t.decimal :cost, precision: 10, scale: 2
      t.bigint :repo_id, null: false
      t.bigint :billing_month_id, null: false
      t.index [:repo_id, :billing_month_id], unique: true
    end
  end
end
