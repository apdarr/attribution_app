class RemoveReposArrayFromBusinessUnits < ActiveRecord::Migration[8.0]
  def change
    remove_column :business_units, :repos
  end
end
