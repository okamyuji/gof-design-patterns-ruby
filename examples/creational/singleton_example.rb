#!/usr/bin/env ruby
# frozen_string_literal: true

# Singleton Pattern Example
# =========================
# シングルトンパターン: クラスのインスタンスが1つだけ存在することを保証し、
#                       グローバルなアクセスポイントを提供する
#
# Usage: ruby examples/creational/singleton_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

SingletonPattern = GofPatterns::Creational::Singleton

puts '=' * 60
puts 'Singleton Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Configuration Singleton
# ========================================
puts '--- Example 1: Configuration Management ---'
puts

config = SingletonPattern::Configuration.instance
config.set(:app_name, 'MyApp')
config.set(:version, '1.0.0')
config.set(:debug_mode, true)
config.set(:max_connections, 100)

puts "App Name: #{config.get(:app_name)}"
puts "Version: #{config.get(:version)}"
puts "Debug Mode: #{config.get(:debug_mode)}"
puts "Max Connections: #{config.get(:max_connections)}"
puts

# Verify same instance
config2 = SingletonPattern::Configuration.instance
puts "Same instance? #{config.equal?(config2)}"
puts "Configuration size: #{config.size} settings"
puts "All settings: #{config.all.inspect}"

puts

# ========================================
# Example 2: Logger Singleton
# ========================================
puts '--- Example 2: Logger Service ---'
puts

logger = SingletonPattern::Logger.instance
logger.level = :debug

logger.debug('Debug message - for developers')
logger.info('Info message - application started')
logger.warn('Warning message - something to watch')
logger.error('Error message - something went wrong')

puts
puts 'Changing log level to :warn...'
logger.level = :warn

logger.debug('This debug message will NOT be shown')
logger.info('This info message will NOT be shown')
logger.warn('This warning message WILL be shown')

puts

# ========================================
# Example 3: Manual Singleton Implementation
# ========================================
puts '--- Example 3: Manual Singleton (without Ruby module) ---'
puts

manual = SingletonPattern::ManualSingleton.instance
manual.store(:user_count, 100)
manual.store(:active_sessions, 25)
manual.store(:cache_size, 512)

puts "User Count: #{manual.retrieve(:user_count)}"
puts "Active Sessions: #{manual.retrieve(:active_sessions)}"
puts "Cache Size: #{manual.retrieve(:cache_size)} MB"

manual2 = SingletonPattern::ManualSingleton.instance
puts "Same instance? #{manual.equal?(manual2)}"

puts

# ========================================
# Example 4: Thread Safety Demonstration
# ========================================
puts '--- Example 4: Thread Safety ---'
puts

config.clear!
config.set(:counter, 0)

threads = 10.times.map do |_i|
  Thread.new do
    sleep(rand * 0.01)
    instance = SingletonPattern::Configuration.instance
    current = instance.get(:counter) || 0
    instance.set(:counter, current + 1)
  end
end

threads.each(&:join)

puts "Final counter value: #{config.get(:counter)}"
puts 'Note: Value may be less than 10 due to race conditions in incrementing,'
puts '      but the singleton instance itself is always the same across threads.'

puts
puts '=' * 60
puts 'End of Singleton Pattern Demo'
puts '=' * 60
