module Validators
  class AbstentionsValidator
    def initialize(customer_success:, away_customer_success:)
      @present_customer_success = customer_success.length
      @absent_customer_success = away_customer_success.length
    end

    def valid?
      allowed_number_of_absenses?
    end

    private

    attr_reader @present_customer_success, @absent_customer_success

    def allowed_number_of_absenses?
      @absent_customer_success <= (@present_customer_success/2).floor
    end
  end
end
