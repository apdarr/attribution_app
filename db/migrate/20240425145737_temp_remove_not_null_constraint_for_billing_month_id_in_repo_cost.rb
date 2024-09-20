class TempRemoveNotNullConstraintForBillingMonthIdInRepoCost < ActiveRecord::Migration[7.0]
  def change
    change_column_null :repo_costs, :billing_month_id, true
  end
end
