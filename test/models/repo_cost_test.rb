require "test_helper"
require "debug"

class RepoCostTest < ActiveSupport::TestCase
  setup do 
    @bu_one = business_units(:one)
    @bu_two = business_units(:two)
    @bu_three = business_units(:three)
  end
end
