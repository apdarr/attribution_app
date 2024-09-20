require "csv"
class BillingMonthsController < ApplicationController
  def index
    @billing_months = BillingMonth.all
    # Grab all business units' monthly costs associated with this month
    @current_month = Date.today.strftime("%B %Y")
    # Roll up business unit costs for the billing month and sort by business unit ID
    @current_billing_month = BillingMonth.costs_per_bu(@current_month).sort_by { |k, v| k }.to_h
    UsageReportWorker.perform
  end

  def show
    @billing_month = BillingMonth.find_by(billing_month: params[:month])
    @view_month = params[:month]
    @viewable_billing_month = BillingMonth.costs_per_bu(@view_month).sort_by { |k, v| k }.to_h
  end

  def new
  end

  def create
    # Upload and parse CSV file
    csv_file = params[:csv_file]
    csv_data = csv_file.read
    # Calculate costs, temporary ID for business unit
    BillingMonth.calculate_costs(csv_data)
    # redirect to root
    redirect_to root_path
  end

end
