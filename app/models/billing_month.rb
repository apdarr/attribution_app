require 'csv'

class BillingMonth < ApplicationRecord
    has_many :repo_costs
    has_many :repos, through: :repo_costs
    belongs_to :business_unit
    validates :billing_month, uniqueness: { scope: :business_unit_id }
    before_save :format_billing_month

    def format_billing_month
        # We want to save the billing_month as a string in the format "Month Year"
        # Not using the Date class because we care about month totals, less say specific dates and probably won't need to do any date math
        parsed_date = Date.parse(self.billing_month).strftime("%B %Y")
        self.billing_month = parsed_date
    end

    def self.monthly_repo_sum(repo_name, billing_month)
        repo = Repo.find_by(name: repo_name)
        return 0.0 unless repo

        billing_month_record = BillingMonth.find_by(business_unit_id: repo.business_unit_id, billing_month: billing_month)
        return 0.0 unless billing_month_record

        repo_costs = RepoCost.where(repo_id: repo.id, billing_month_id: billing_month_record.id)
        repo_costs.sum(:cost)
    end

    # Sum each business unit's total cost for the month. Return a hash for each BU ID and the costs
    def self.costs_per_bu(current_month)
        BillingMonth.all.select{ |bm| bm.billing_month == current_month }
            .map{ |bm| { bm.business_unit_id => bm.total_cost.to_f } }
            .reduce({}, :merge) # Reduce the array of hashes to a single hash
    end
end