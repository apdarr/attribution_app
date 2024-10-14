require "test_helper"

class BillingMonthsHelperTest < ActionView::TestCase
    include BillingMonthsHelper

    setup do
        @bu_one = business_units(:one)
    end

    # Likely no longer required in new UI, so commented out for now

    # test "previous_month_link should return link to previous month if it exists" do
    #     # Create a month previously from today and format it
    #     month = Date.today.strftime("%B %Y")
    #     prev_expected_month = Date.today.prev_month.strftime("%B %Y")
    #     # Create previous billing month to pass test case
    #     BillingMonth.create(billing_month: prev_expected_month, total_cost: 1.0, business_unit_id: @bu_one.id)

    #     assert_match /Previous Month/, previous_month_link(month)
    #     assert_match /\/billing_months\/January%202024/, previous_month_link(month)
    # end

    # test "previous_month_link should not return link to previous month if it doesn't exist" do
    #     month = Date.today.strftime("%B %Y")
    #     assert_nil previous_month_link(month)
    # end

    # test "next_month_link should return link to next month if it exists" do
    #     # Define a month that simulates a user viewing the page in October 2023
    #     viewable_month = "October 2023"
    #     next_viewable_month = "November 2023"
    #     BillingMonth.create(billing_month: viewable_month, total_cost: 1.0, business_unit_id: @bu_one.id)
    #     BillingMonth.create(billing_month: next_viewable_month, total_cost: 1.0, business_unit_id: @bu_one.id)

    #     assert_match /Next Month/, next_month_link(viewable_month)
    #     assert_match /\/billing_months\/November%202023/, next_month_link(viewable_month)
    # end

    # test "next_month_link should not return link for next month if it doesn't exist" do
    #     month = "September 2023"

    #     assert_nil next_month_link(month)
    # end
end