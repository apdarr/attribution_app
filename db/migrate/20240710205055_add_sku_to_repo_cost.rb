class AddSkuToRepoCost < ActiveRecord::Migration[7.0]
  def change
    add_column :repo_costs, :sku, :string
  end
end
