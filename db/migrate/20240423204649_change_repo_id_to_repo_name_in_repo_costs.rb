class ChangeRepoIdToRepoNameInRepoCosts < ActiveRecord::Migration[7.0]
  def change
    rename_column :repo_costs, :repo_id, :repo_name
    change_column :repo_costs, :repo_name, :string
  end
end
