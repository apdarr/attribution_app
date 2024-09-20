class AddReposColumnToBusinessUnit < ActiveRecord::Migration[7.0]
  def change
    add_column :business_units, :repos, :text, array: true, default: []
  end
end
