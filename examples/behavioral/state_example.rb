#!/usr/bin/env ruby
# frozen_string_literal: true

# State Pattern Example
# =====================
# ステートパターン: オブジェクトの内部状態が変化したときに、
#                   その振る舞いを変更する
#
# Usage: ruby examples/behavioral/state_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

State = GofPatterns::Behavioral::State

puts '=' * 60
puts 'State Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Vending Machine
# ========================================
puts '--- Example 1: Vending Machine ---'
puts

machine = State::VendingMachine.new
machine.add_product('Coke', 120, 10)
machine.add_product('Water', 100, 5)

puts "Current state: #{machine.state.name}"
puts

puts 'Inserting ¥100...'
machine.insert_money(100)
puts "Balance: ¥#{machine.balance}"
puts "State: #{machine.state.name}"
puts

puts 'Selecting Water...'
machine.select_product('Water')
puts "Selected: #{machine.selected_product}"
puts "State: #{machine.state.name}"
puts

puts 'Dispensing...'
machine.dispense
puts "Balance: ¥#{machine.balance}"
puts "State: #{machine.state.name}"

puts

# ========================================
# Example 2: Order Status
# ========================================
puts '--- Example 2: Order Status ---'
puts

order = State::Order.new('ORDER-001', %w[Item1 Item2], 15_000)

puts "Initial state: #{order.state.name}"
puts

puts 'Confirming order...'
order.confirm
puts "Status: #{order.state.name}"
puts

puts 'Shipping order...'
order.ship
puts "Status: #{order.state.name}"
puts

puts 'Delivering order...'
order.deliver
puts "Status: #{order.state.name}"
puts

# ========================================
# Example 3: Invalid State Transitions
# ========================================
puts '--- Example 3: Invalid State Transitions ---'
puts

machine = State::VendingMachine.new
machine.add_product('Juice', 150, 3)

puts "Current state: #{machine.state.name}"
puts

begin
  puts 'Trying to select product without money...'
  machine.select_product('Juice')
rescue RuntimeError => e
  puts "Error: #{e.message}"
end

puts

begin
  puts 'Trying to dispense without selection...'
  machine.dispense
rescue RuntimeError => e
  puts "Error: #{e.message}"
end

puts
puts '=' * 60
puts 'End of State Pattern Demo'
puts '=' * 60
