class BusinessUnitsController < ApplicationController
  def index
    @business_units = BusinessUnit.all
    current_month = Date.today.strftime("%B %Y")
    @current_billing_month_collection = BillingMonth.where(billing_month: current_month)
    # @first_business_unit = BusinessUnit.first
    # @first_business_unit_cost = BillingMonth.find_by(business_unit_id: 1).total_cost
  end

  def show
  end

  def new
    # A bit hacky but for now we can just store the prefix on the first business unit
    @current_prefix = BusinessUnit.first.prefix ? BusinessUnit.first.prefix : "bu_"
  end

  def create
    # We're updating all columns for now, but in the future, in probably makes to have multiple prefixes in a table with some maxiumum number
    BusinessUnit.update_all(prefix: params[:prefix])
    redirect_to new_business_unit_path, notice: 'Prefix was successfully updated.'
  end

  def edit
  end

  def update

  end

  def destroy
  end
end
