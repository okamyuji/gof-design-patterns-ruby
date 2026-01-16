#!/usr/bin/env ruby
# frozen_string_literal: true

# Adapter Pattern Example
# =======================
# アダプターパターン: 互換性のないインターフェースを持つクラス同士を協調させる
#
# Usage: ruby examples/structural/adapter_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Adapter = GofPatterns::Structural::Adapter

puts '=' * 60
puts 'Adapter Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Legacy Payment System Adapter
# ========================================
puts '--- Example 1: Legacy Payment System ---'
puts

legacy_system = Adapter::LegacyPaymentSystem.new
adapter = Adapter::LegacyPaymentAdapter.new(legacy_system)

money = Adapter::Money.new(5000, 'JPY')
result = adapter.process_payment(money, 'JPY')

puts 'Payment result:'
puts "  Success: #{result.success?}"
puts "  Transaction ID: #{result.transaction_id}"
puts "  Status: #{result.status}"
puts "  Message: #{result.message}"

puts

# ========================================
# Example 2: External API Adapter
# ========================================
puts '--- Example 2: External API Adapter ---'
puts

external_api = Adapter::ExternalPaymentApi.new
adapter = Adapter::ExternalApiAdapter.new(external_api)

money = Adapter::Money.new(10_000, 'JPY')
result = adapter.process_payment(money, 'JPY')

puts 'Payment result:'
puts "  Success: #{result.success?}"
puts "  Transaction ID: #{result.transaction_id}"
puts "  Status: #{result.status}"
puts "  Message: #{result.message}"

puts

# ========================================
# Example 3: Payment Service with Multiple Adapters
# ========================================
puts '--- Example 3: Payment Service ---'
puts

legacy_service = Adapter::PaymentService.new(adapter_type: :legacy)
external_service = Adapter::PaymentService.new(adapter_type: :external)

# Process payments through different systems
orders = [
  { id: 'ORDER-101', amount: 3000, currency: 'JPY', service: legacy_service },
  { id: 'ORDER-102', amount: 5000, currency: 'JPY', service: external_service },
  { id: 'ORDER-103', amount: 8000, currency: 'JPY', service: legacy_service }
]

orders.each do |order|
  result = order[:service].pay(order[:amount], order[:currency])
  puts "#{order[:id]}: #{result.success? ? 'SUCCESS' : 'FAILED'} - #{result.message}"
end

puts

# ========================================
# Example 4: Refund Operations
# ========================================
puts '--- Example 4: Refund Operations ---'
puts

legacy_adapter = Adapter::LegacyPaymentAdapter.new(Adapter::LegacyPaymentSystem.new)
money = Adapter::Money.new(2000, 'JPY')
payment_result = legacy_adapter.process_payment(money, 'JPY')

puts "Original payment: #{payment_result.transaction_id}"

refund_result = legacy_adapter.refund(payment_result.transaction_id, money)
puts 'Refund result:'
puts "  Success: #{refund_result.success?}"
puts "  Message: #{refund_result.message}"

puts
puts '=' * 60
puts 'End of Adapter Pattern Demo'
puts '=' * 60
