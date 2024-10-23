class BusinessUnit < ApplicationRecord
    #enum unit_type: { tag: 0, property: 1 }
    has_many :billing_months
    has_many :repos
end
