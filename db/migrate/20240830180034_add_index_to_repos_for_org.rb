class AddIndexToReposForOrg < ActiveRecord::Migration[7.0]
  def change
    add_index :repos, [:org, :name], unique: true
  end
end
