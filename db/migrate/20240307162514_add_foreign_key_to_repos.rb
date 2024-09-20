class AddForeignKeyToRepos < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :repos, :business_units
  end
end
