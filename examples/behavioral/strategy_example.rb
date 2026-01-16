#!/usr/bin/env ruby
# frozen_string_literal: true

# Strategy Pattern Example
# ========================
# ストラテジパターン: アルゴリズムをカプセル化し、実行時に交換可能にする
#
# Usage: ruby examples/behavioral/strategy_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Strategy = GofPatterns::Behavioral::Strategy

puts '=' * 60
puts 'Strategy Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Payment Strategies
# ========================================
puts '--- Example 1: Payment Strategies ---'
puts

credit_card = Strategy::CreditCardPayment.new(
  card_number: '1234-5678-9012-3456',
  expiry: '12/25',
  cvv: '123'
)

processor = Strategy::PaymentProcessor.new(credit_card)
result = processor.process_payment(10_000)
puts "Payment with #{credit_card.name}:"
puts "  Amount: ¥#{result.amount}"
puts "  Fee: ¥#{result.fee}"
puts "  Total: ¥#{result.total}"
puts "  Transaction ID: #{result.transaction_id}"
puts "  Success: #{result.success?}"

puts

paypal = Strategy::PayPalPayment.new(email: 'user@example.com')
processor2 = Strategy::PaymentProcessor.new(paypal)
result = processor2.process_payment(10_000)
puts "Payment with #{paypal.name}:"
puts "  Total: ¥#{result.total}"
puts "  Transaction ID: #{result.transaction_id}"

puts

bank = Strategy::BankTransferPayment.new(bank_code: '0001', account_number: '1234567')
processor3 = Strategy::PaymentProcessor.new(bank)
result = processor3.process_payment(10_000)
puts "Payment with #{bank.name}:"
puts "  Total: ¥#{result.total}"
puts "  Success: #{result.success?}"

puts

# ========================================
# Example 2: Sorting Strategies
# ========================================
puts '--- Example 2: Sorting Strategies ---'
puts

data = [64, 34, 25, 12, 22, 11, 90]

puts "Original data: #{data.inspect}"

sorter = Strategy::Sorter.new(Strategy::BubbleSort.new)
result = sorter.sort(data.dup)
puts "Bubble sort: #{result.inspect}"

sorter = Strategy::Sorter.new(Strategy::QuickSort.new)
result = sorter.sort(data.dup)
puts "Quick sort: #{result.inspect}"

sorter = Strategy::Sorter.new(Strategy::MergeSort.new)
result = sorter.sort(data.dup)
puts "Merge sort: #{result.inspect}"

puts

puts

# ========================================
# Example 3: Runtime Strategy Selection
# ========================================
puts '--- Example 3: Runtime Strategy Selection ---'
puts

amount = 50_000
payment_method = :credit_card

strategy = case payment_method
           when :credit_card
             Strategy::CreditCardPayment.new(
               card_number: '1111-2222-3333-4444',
               expiry: '01/26',
               cvv: '456'
             )
           when :paypal
             Strategy::PayPalPayment.new(email: 'customer@example.com')
           when :bitcoin
             Strategy::BitcoinPayment.new(wallet_address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh')
           else
             raise ArgumentError, "Unknown payment method: #{payment_method}"
           end

processor = Strategy::PaymentProcessor.new(strategy)
result = processor.process_payment(amount)
puts "Selected payment method: #{strategy.name}"
puts "Result: #{result.success? ? 'SUCCESS' : 'FAILED'}"
puts "Total charged: ¥#{result.total}"

puts
puts '=' * 60
puts 'End of Strategy Pattern Demo'
puts '=' * 60
