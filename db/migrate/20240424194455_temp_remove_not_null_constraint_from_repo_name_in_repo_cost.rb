class TempRemoveNotNullConstraintFromRepoNameRepoCost < ActiveRecord::Migration[7.0]
  def change
    change_column_null :repo_costs, :repo_name, true
  end
end
