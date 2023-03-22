module Filters
	class FilterAvailableCustomerSuccess
		def initialize(customer_success:, away_customer_success:)
      @customer_success = customer_success
      @away_customer_success = away_customer_success
    end

		def only_available_customer_success
			@customer_success.reject { |cs| @away_customer_success.include?(cs[:id]) }
		end
	end
end
