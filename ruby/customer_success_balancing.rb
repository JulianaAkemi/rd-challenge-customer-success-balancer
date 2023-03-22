require 'minitest/autorun'
require 'timeout'
require_relative './validators/customer_success_validator.rb'
require_relative './validators/customer_validator.rb'
require_relative './filters/filter_available_customer_success.rb'
require_relative './utils/errors_messages.rb'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  def execute
    sorted_available_customer_success = available_customer_success.sort_by { |cs| cs[:score] }
    sorted_customers = @customers.sort_by { |cs| cs[:score] }
    customer_success_balancing = {}
    puts sorted_available_customer_success.inspect
    puts sorted_customers.inspect
  
    if sorted_available_customer_success.last[:score] < sorted_customers.first[:score] || customer_success.size == 0 || customers.size == 0
      return 0
    end

    if sorted_available_customer_success.first[:score] > sorted_customers.last[:score]
      return sorted_available_customer_success.first[:id]
    end
    
    sorted_available_customer_success.each do |cs|
      customer_success_balancing[cs[:id]] = 0
    end

    customers.each do |customer|
      suitable_cs = customer_success.select {|cs| cs[:score] >= customer[:score]}.first
      customer_success_balancing[suitable_cs[:id]] += 1 if suitable_cs
    end

    max_clients = customer_success_balancing.values.max
    winner_cs = customer_success_balancing.select { |k, v| v == max_clients }.keys

    return winner_cs.size == 1 ? winner_cs.first : 0
  end

  private

  attr_reader :customer_success, :away_customer_success, :customers

  def valid_customer_success
    Validators::CustomerSuccessValidator.new(customer_success: customer_success).valid?
  end

  def valid_customers
    Validators::CustomerValidator.new(customer: customer).valid?
  end

  def valid_abstentions
    if away_customer_success.size == 0 then
      true
    else
      Validators::AbstentionsValidator(customer_success: customer_success, away_customer_success: away_customer_success)
    end
  end

  def available_customer_success
    if away_customer_success.size == 0 then
      customer_success
    else
      filter = Filters::FilterAvailableCustomerSuccess.new(customer_success: @customer_success, away_customer_success: @away_customer_success)
      available_cs = filter.only_available_customer_success
    end
  end

  def cs_with_largest_ammount_of_customers
    customer_success_balancing.max_by{|k,v| v}[0]
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
