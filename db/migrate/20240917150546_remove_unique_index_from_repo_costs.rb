class RemoveUniqueIndexFromRepoCosts < ActiveRecord::Migration[7.0]
  def change
    remove_index :repo_costs, name: "index_repo_costs_on_repo_name_and_billing_month_id"
  end
end
