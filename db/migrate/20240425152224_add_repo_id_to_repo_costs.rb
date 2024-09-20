class AddRepoIdToRepoCosts < ActiveRecord::Migration[7.0]
  def change
    add_reference :repo_costs, :repo, foreign_key: true
  end
end
