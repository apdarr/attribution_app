module BillingMonthsHelper
    def previous_month_link(month)
        parsed_prev_month = Date.parse(month).prev_month.strftime("%B %Y")        
        link_to 'Previous Month', billing_month_path(month: parsed_prev_month) if month_exists?(parsed_prev_month)
    end

    def next_month_link(month)
        parsed_next_month = Date.parse(month).next_month.strftime("%B %Y")
        link_to 'Next Month', billing_month_path(month: parsed_next_month) if Date.parse(month) <= Date.today && month_exists?(parsed_next_month)
    end

    def month_exists?(month)
        BillingMonth.where(billing_month: month).exists?
    end
end
