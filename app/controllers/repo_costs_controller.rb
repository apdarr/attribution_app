class RepoCostsController < ApplicationController

    def index
        @billing_month = BillingMonth.find(params[:billing_month_id])
        # Only grabbing the first 10 until we have pagination
        @repo_cost = @billing_month.repo_costs.first(10)
        @view_month = @billing_month.billing_month
        @bu_name = BusinessUnit.find_by(id: @billing_month.business_unit_id).name

        # Pass in bread crumbs for easier linking
        bu_name = BusinessUnit.find_by(id: @billing_month.business_unit_id).name
        month_name = @billing_month.billing_month
        @bread_crumbs = ["#{bu_name}", "#{month_name}"]
    end
end
