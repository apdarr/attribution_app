class AddOrgToRepos < ActiveRecord::Migration[7.0]
  def change
    add_column :repos, :org, :string
  end
end
