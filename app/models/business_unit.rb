class BusinessUnit < ApplicationRecord
    has_many :billing_months
    has_many :repos
end
