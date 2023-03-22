module Validators
  class CustomerSuccessValidator
    LIMIT_SCORE = 10_000
    LIMIT_ID = 1000
    LIMIT_CS_NUMBER = 1000
    def initialize(customer_success:)
      @customer_success = customer_success
    end

    def valid?
      id_inside_limit? && score_inside_limit? && allowed_cs_number?
    end

    private

    def allowed_cs_number?
      @customer_success.size.positive? && @customer_success.size < LIMIT_CS_NUMBER
    end

    def id_inside_limit?
      @customer_success.each do |cs|
        if cs[:id].positive? && cs[:id] < LIMIT_ID
          next
        else
          return false
        end
  
        return true
      end
    end

    def score_inside_limit?
      @customer_success.each do |cs|
        if cs[:score].positive? && cs[:score] < LIMIT_SCORE
          next
        else
          return false
        end
  
        return true
      end
    end
  end
end
