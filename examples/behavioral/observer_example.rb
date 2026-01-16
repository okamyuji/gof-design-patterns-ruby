#!/usr/bin/env ruby
# frozen_string_literal: true

# Observer Pattern Example
# ========================
# オブザーバーパターン: オブジェクトの状態変化を他のオブジェクトに通知する
#
# Usage: ruby examples/behavioral/observer_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Observer = GofPatterns::Behavioral::Observer

puts '=' * 60
puts 'Observer Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Stock Price Monitoring
# ========================================
puts '--- Example 1: Stock Price Monitoring ---'
puts

monitor = Observer::StockMonitor.new

display = Observer::StockDisplay.new('Display 1')
alert = Observer::StockAlert.new(threshold_percent: 5.0)
logger = Observer::StockLogger.new

monitor.attach(display)
monitor.attach(alert)
monitor.attach(logger)

monitor.update_price('AAPL', 150.0)
monitor.update_price('AAPL', 152.5)
monitor.update_price('AAPL', 156.0)

puts

# ========================================
# Example 2: Weather Station
# ========================================
puts '--- Example 2: Weather Station ---'
puts

station = Observer::WeatherStation.new

Observer::CurrentConditionsDisplay.new(station)
Observer::StatisticsDisplay.new(station)
Observer::ForecastDisplay.new(station)

puts 'Setting weather measurements...'
station.set_measurements(25.0, 65.0, 1013.0)
puts

station.set_measurements(27.0, 70.0, 1012.0)
puts

station.set_measurements(23.0, 60.0, 1015.0)

puts

# ========================================
# Example 3: News Publisher with Event Emitter
# ========================================
puts '--- Example 3: News Publisher ---'
puts

publisher = Observer::NewsPublisher.new

# Subscribe to news
publisher.on(:news_published) do |article|
  puts "Subscriber 1 received: #{article[:title]}"
end

subscriber2 = lambda do |article|
  puts "Subscriber 2 received: #{article[:title]} (Category: #{article[:category]})"
end
publisher.on(:news_published, &subscriber2)

# Subscribe once
publisher.once(:breaking_news) do |article|
  puts "BREAKING NEWS (once): #{article[:title]}"
end

publisher.publish('Technology', 'New Ruby Version Released', 'A new version of Ruby has been released.')
puts

publisher.publish('Science', 'AI Breakthrough', 'Major breakthrough in artificial intelligence.')
puts

# Breaking news will only be received once
publisher.emit(:breaking_news, title: 'Major Event', category: 'Breaking')
puts

# This won't trigger the 'once' subscriber
publisher.emit(:breaking_news, title: 'Another Major Event', category: 'Breaking')

puts

# ========================================
# Example 4: Multiple Subjects
# ========================================
puts '--- Example 4: Multiple Stocks ---'
puts

monitor = Observer::StockMonitor.new

multi_display = Observer::StockDisplay.new('Multi Display')
multi_logger = Observer::StockLogger.new('Multi Logger')

monitor.attach(multi_display)
monitor.attach(multi_logger)

monitor.update_price('GOOGL', 2800.0)
monitor.update_price('MSFT', 380.0)
monitor.update_price('TSLA', 750.0)

puts

# ========================================
# Example 5: Observer Detachment
# ========================================
puts '--- Example 5: Observer Detachment ---'
puts

monitor = Observer::StockMonitor.new
display = Observer::StockDisplay.new('Temp Display')

monitor.attach(display)
puts 'Display attached:'
monitor.update_price('NFLX', 500.0)
puts

monitor.detach(display)
puts 'Display detached (no output):'
monitor.update_price('NFLX', 505.0)

puts
puts '=' * 60
puts 'End of Observer Pattern Demo'
puts '=' * 60
