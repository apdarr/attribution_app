class DeleteBusinessUnitNameColumnFromRepos < ActiveRecord::Migration[7.0]
  def change
    remove_column :repos, :business_unit, :string
  end
end
