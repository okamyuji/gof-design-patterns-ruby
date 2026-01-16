#!/usr/bin/env ruby
# frozen_string_literal: true

# Template Method Pattern Example
# ===============================
# テンプレートメソッドパターン: アルゴリズムの骨格を定義し、
#                               一部のステップをサブクラスで実装させる
#
# Usage: ruby examples/behavioral/template_method_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

TemplateMethod = GofPatterns::Behavioral::TemplateMethod

puts '=' * 60
puts 'Template Method Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Data Mining
# ========================================
puts '--- Example 1: Data Mining ---'
puts

csv_miner = TemplateMethod::CsvDataMiner.new
result = csv_miner.mine('data.csv')

puts 'CSV Mining Result:'
puts "  Status: #{result[:status]}"
puts "  Record count: #{result[:data][:count]}"
puts "  Columns: #{result[:data][:columns].join(', ')}"

puts

json_miner = TemplateMethod::JsonDataMiner.new
result = json_miner.mine('data.json')

puts 'JSON Mining Result:'
puts "  Status: #{result[:status]}"
puts "  Record count: #{result[:data].size}"

puts

xml_miner = TemplateMethod::XmlDataMiner.new
result = xml_miner.mine('data.xml')

puts 'XML Mining Result:'
puts "  Status: #{result[:status]}"
puts "  Root element: #{result[:data][:root]}"
puts "  Record count: #{result[:data][:records].size}"

puts

# ========================================
# Example 2: Game Template
# ========================================
puts '--- Example 2: Game AI Template ---'
puts

puts 'Aggressive AI:'
ai = TemplateMethod::AggressiveAI.new
ai.take_turn
puts

puts 'Defensive AI:'
ai2 = TemplateMethod::DefensiveAI.new
ai2.take_turn

puts

puts
puts '=' * 60
puts 'End of Template Method Pattern Demo'
puts '=' * 60
