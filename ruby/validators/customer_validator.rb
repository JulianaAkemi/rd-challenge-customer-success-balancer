module Validators
  class CustomerValidator
    LIMIT_SCORE = 100_000
    LIMIT_ID = 1_000_000
    LIMIT_CUSTOMER_NUMBER = 1_000_000
    def initialize(customers:)
      @customers = customers
    end

    def valid?
      id_inside_limit? && score_inside_limit? && allowed_customers_number?
    end

    private

    def allowed_customers_number?
      customers.size.positive? && customers.size < LIMIT_CUSTOMER_NUMBER
    end

    def id_inside_limit?
      customers.each do |customer|
        if customer[:id].positive? && customer[:id] < LIMIT_ID
          next
        else
          return false
        end
  
        return true
      end
    end

    def score_inside_limit?
      customers.each do |customer|
        if customer[:score].positive? && customer.score < LIMIT_SCORE
          next
        else
          return false
        end
  
        return true
      end
    end
		
  end
end
