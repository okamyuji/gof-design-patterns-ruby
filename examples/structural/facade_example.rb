#!/usr/bin/env ruby
# frozen_string_literal: true

# Facade Pattern Example
# ======================
# ファサードパターン: 複雑なサブシステムに対する単純なインターフェースを提供する
#
# Usage: ruby examples/structural/facade_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Facade = GofPatterns::Structural::Facade

puts '=' * 60
puts 'Facade Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Simple Order Processing
# ========================================
puts '--- Example 1: Simple Order Processing ---'
puts

order_facade = Facade::ECommerceService.new

items = [
  Facade::OrderItem.new(product_id: 'PROD-001', name: 'Laptop', quantity: 2, unit_price: 80_000),
  Facade::OrderItem.new(product_id: 'PROD-002', name: 'Mouse', quantity: 3, unit_price: 2000)
]

customer_email = 'taro@example.com'

shipping_address = Facade::ShippingAddress.new(
  name: 'Taro Yamada',
  postal_code: '100-0001',
  address: 'Tokyo, Chiyoda-ku, 1-1-1 Marunouchi',
  phone: '090-1234-5678'
)

# Add inventory first
order_facade.add_inventory('PROD-001', 10)
order_facade.add_inventory('PROD-002', 20)

result = order_facade.place_order(items: items, shipping_address: shipping_address, payment_method: :credit_card,
                                  customer_email: customer_email)

puts "Order placed: #{result[:success]}"
puts "Order ID: #{result[:order_id]}"
puts "Total: #{result[:total_amount]} JPY"
puts "Transaction ID: #{result[:transaction_id]}"
puts "Tracking Number: #{result[:tracking_number]}"

puts

# ========================================
# Example 2: Order Status Tracking
# ========================================
puts '--- Example 2: Order Status Tracking ---'
puts

# Simulate status updates
result[:tracking_number]
order_id = result[:order_id]

statuses = %i[pending processing shipped delivered]
statuses.each_with_index do |_status, _i|
  puts "\nChecking order status..."
  info = order_facade.get_order_status(order_id)
  puts "  Order: #{info[:order_id]}"
  puts "  Status: #{info[:status]}"
  puts "  Shipping status: #{info[:shipping_status]}"
end

puts

# ========================================
# Example 3: Bulk Order Processing
# ========================================
puts '--- Example 3: Bulk Order Processing ---'
puts

facade = Facade::ECommerceService.new

# Add inventory
facade.add_inventory('P001', 10)
facade.add_inventory('P002', 10)

orders_data = [
  {
    customer_email: 'c1@example.com',
    items: [Facade::OrderItem.new(product_id: 'P001', name: 'Item 1', quantity: 1, unit_price: 5000)],
    address: Facade::ShippingAddress.new(
      name: 'Customer 1',
      postal_code: '150-0001',
      address: 'Tokyo, Shibuya-ku, 1-1-1',
      phone: '090-1111-1111'
    )
  },
  {
    customer_email: 'c2@example.com',
    items: [Facade::OrderItem.new(product_id: 'P002', name: 'Item 2', quantity: 2, unit_price: 3000)],
    address: Facade::ShippingAddress.new(
      name: 'Customer 2',
      postal_code: '530-0001',
      address: 'Osaka, Kita-ku, 2-2-2',
      phone: '090-2222-2222'
    )
  }
]

orders_data.each_with_index do |data, i|
  result = facade.place_order(
    items: data[:items],
    shipping_address: data[:address],
    payment_method: :credit_card,
    customer_email: data[:customer_email]
  )
  puts "Order #{i + 1}: #{result[:success] ? 'SUCCESS' : 'FAILED'} - #{result[:order_id]}"
end

puts

# ========================================
# Example 4: Order Cancellation
# ========================================
puts '--- Example 4: Order Cancellation ---'
puts

facade = Facade::ECommerceService.new

# Add inventory
facade.add_inventory('PROD-100', 5)

# Place an order
items = [Facade::OrderItem.new(product_id: 'PROD-100', name: 'Gadget', quantity: 1, unit_price: 10_000)]
customer_email = 'test@example.com'
address = Facade::ShippingAddress.new(
  name: 'Test Customer',
  postal_code: '100-0001',
  address: 'Tokyo, Test City, 1-1-1',
  phone: '090-0000-0000'
)

order_result = facade.place_order(
  items: items,
  shipping_address: address,
  payment_method: :paypal,
  customer_email: customer_email
)
order_id = order_result[:order_id]
transaction_id = order_result[:transaction_id]

puts "Order created: #{order_id}"
puts "Payment transaction: #{transaction_id}"
puts

# Cancel the order
puts 'Cancelling order...'
cancel_result = facade.cancel_order(order_id, customer_email: customer_email)

puts "Cancellation: #{cancel_result[:success] ? 'SUCCESS' : 'FAILED'}"
puts "Order status: #{cancel_result[:status]}"

puts

# ========================================
# Example 5: Error Handling
# ========================================
puts '--- Example 5: Error Handling ---'
puts

facade = Facade::ECommerceService.new

# Try to get info for non-existent order
status = facade.get_order_status('INVALID-ORDER-ID')
if status.nil?
  puts 'Error: Order not found'
else
  puts "Order status: #{status[:status]}"
end

puts
puts '=' * 60
puts 'End of Facade Pattern Demo'
puts '=' * 60
