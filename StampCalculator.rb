#!/usr/bin/ruby
# frozen_string_literal: true

# asdasd
class StampCalculator
  Error = Class.new(StandardError)

  attr_reader :sum_in_cents

  def initialize(sum_in_cents)
    @sum_in_cents = sum_in_cents
    @stamp_count_five = 0
    @stamp_count_three = 0
  end

  def call
    self.stamp_count_five = sum_in_cents / 5 # 5 cents stamps amount
    self.stamp_count_three = (sum_in_cents - total_cost_five) / 3 # 5 cents stamps amount

    raise Error, 'Minimālām sūtījumā izmaksām jābūt 0.08 EUR' if sum_in_cents < 8

    while !spent_all_without_remainder && stamp_count_five.positive?
      self.stamp_count_five -= 1
      self.stamp_count_three += (sum_in_cents - total_cost_five - total_cost_three) / 3
    end

    [stamp_count_five, stamp_count_three]
  end

  private

  attr_accessor :stamp_count_five, :stamp_count_three

  def spent_all_without_remainder
    total_cost_five + total_cost_three == sum_in_cents
  end

  def total_cost_five
    stamp_count_five * 5
  end

  def total_cost_three
    stamp_count_three * 3
  end
end

class StampFormatter
  attr_reader :num5, :num3

  def initialize(num5, num3)
    @num5 = num5
    @num3 = num3
  end

  def call
    ary = []
    ary << pluralize(num5, 'piecu centu marka') unless num5.zero?
    ary << pluralize(num3, 'trīs centu marka') unless num3.zero?
    ary.join(', ')
  end

  private

  def pluralize(number, phrase)
    if number == 1 || !number.to_s.end_with?('11') && number % 10 == 1 #&& number != 11
      "#{number} #{phrase}"
    else
      "#{number} #{phrase}s"
    end
  end
end

def exit_with_error
  print 'Lūdzu ievadiet korektu skaitli'
  exit(1)
end

if ARGV.size == 1
  # sum = nil
  begin
    # sum = Integer(ARGV[0])
  rescue ArgumentError
    exit_with_error
  end

  begin
    sum = Integer(ARGV[0])
    calculator = StampCalculator.new(sum)
    num5, num3 = calculator.call
    print StampFormatter.new(num5, num3).call
  rescue StampCalculator::Error => e
    print e.message
  end
else
  exit_with_error
end
