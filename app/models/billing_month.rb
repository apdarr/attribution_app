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

    def self.calculate_costs(csv_data)
        csv = CSV.parse(csv_data, headers: true)
        # Initialize a cost value for summing
        costs = 0.0
        unattributed = 0.0
        dates = []
        # Initialize a hash to capture each repository's cost
        row_repo_cost = {}
        repo_name = ""
        repo_date = ""
        csv.each do |row|
            row_hash = row.to_hash.transform_keys(&:strip)
            # Convert to hash to make it easier to parse data. If it's not nil, strip it. Otherwise, leave it nil (v)
            row_hash.transform_values! { |v| v.is_a?(String) ? v.strip : v }
            r_cost = row_hash["Quantity"].to_f * row_hash["Price Per Unit ($)"].to_f * row_hash["Multiplier"].to_f
            parsed_date = Date.parse(row_hash["Date"]).strftime("%B %Y")
            repo_name = row_hash["Repository Slug"]
            sku = row_hash["SKU"]
            # Find the business unit that owns this repository
            business_unit = BusinessUnit.all.find{ |bu| bu.repos.exists?(name: repo_name) }
            if business_unit
                # Either update the existing billing month or create a new one
                billing_month = BillingMonth.find_or_initialize_by(business_unit_id: business_unit.id, billing_month: parsed_date)
                # Set the total cost to 0.0 if it's nil
                billing_month.total_cost ||= 0.0
                # Add the cost to the total cost
                billing_month.total_cost += r_cost
                # Now do the same as above, but for the repo_cost
                repo_cost = RepoCost.find_or_initialize_by(repo_name: repo_name, billing_month_id: billing_month.id)
                repo_cost.cost ||= 0.0
                repo_cost.cost += r_cost
                self.transaction do
                    billing_month.save!
                    repo = Repo.find_or_create_by(name: repo_name)
                    repo_cost = RepoCost.find_or_create_by(repo_id: repo.id, billing_month_id: billing_month.id, repo_name: repo.name, sku: sku)
                    repo_cost.cost ||= 0.0
                    repo_cost.cost += r_cost
                    repo_cost.save!
                    # Until the billing month is aggregated, the repo_cost and billing_month rows are the same
                end
            else 
                unattributed += cost
            end                        
            repo_name = row_hash["Repository Slug"]
        end
    end

    # Sum each business unit's total cost for the month. Return a hash for each BU ID and the costs
    def self.costs_per_bu(current_month)
        bu_costs = BillingMonth.all.select{ |bm| bm.billing_month == current_month }
                                    .map{ |bm| { bm.business_unit_id => bm.total_cost.to_f } }
                                    .reduce({}, :merge) # Reduce the array of hashes to a single hash
    end

    # Adding a URL method to the model is a bad practice. But, adding this here to validate basic behavior before before moving this to a background job.
    # Parse the response for this endpoint (https://api.github.com/enterprises/avocado-corp/settings/billing/usage) and return the parsed data, and save it to the database
end