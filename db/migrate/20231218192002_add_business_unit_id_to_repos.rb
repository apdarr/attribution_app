class AddBusinessUnitIdToRepos < ActiveRecord::Migration[7.0]
  def change
    add_column :repos, :business_unit_id, :integer
  end
end
