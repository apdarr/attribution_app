class RepoCost < ApplicationRecord
    belongs_to :repo
    belongs_to :billing_month


    def update_cost(cost)
        self.cost = cost
        save
    end
end
