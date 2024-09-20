class Repo < ApplicationRecord
    has_many :repo_costs
    has_many :billing_months, through: :repo_costs
    belongs_to :business_unit
    validates :name, presence: true
    validates :name, uniqueness: { scope: :org, message: "Repository name must be unique within an organization" }
end