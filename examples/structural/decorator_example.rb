#!/usr/bin/env ruby
# frozen_string_literal: true

# Decorator Pattern Example
# =========================
# デコレーターパターン: オブジェクトに動的に新しい責務を追加する
#
# Usage: ruby examples/structural/decorator_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Decorator = GofPatterns::Structural::Decorator

puts '=' * 60
puts 'Decorator Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Coffee Shop Orders
# ========================================
puts '--- Example 1: Coffee Shop ---'
puts

espresso = Decorator::Espresso.new
puts "#{espresso.description}: $#{espresso.cost}"

latte = Decorator::Latte.new
puts "#{latte.description}: $#{'%.2f' % latte.cost}"

decorated_coffee = Decorator::MilkDecorator.new(
  Decorator::CaramelDecorator.new(
    Decorator::ExtraShotDecorator.new(
      Decorator::Espresso.new
    )
  )
)

puts "#{decorated_coffee.description}: $#{'%.2f' % decorated_coffee.cost}"

puts

# ========================================
# Example 2: Multiple Decorators
# ========================================
puts '--- Example 2: Multiple Decorators ---'
puts

coffee1 = Decorator::WhipCreamDecorator.new(
  Decorator::MilkDecorator.new(
    Decorator::DripCoffee.new
  )
)

puts "#{coffee1.description}: $#{'%.2f' % coffee1.cost}"

coffee2 = Decorator::SizeUpDecorator.new(
  Decorator::ExtraShotDecorator.new(
    Decorator::CaramelDecorator.new(
      Decorator::Latte.new
    )
  ),
  size: :venti
)

puts "#{coffee2.description}: $#{'%.2f' % coffee2.cost}"

puts

# ========================================
# Example 3: Text Content Decoration with SimpleDelegator
# ========================================
puts '--- Example 3: Text Content Decoration ---'
puts

text = Decorator::TextContent.new('hello world')

html_text = Decorator::HtmlTagDecorator.new(text, tag: 'p')
puts "HTML: #{html_text.render}"

upper_text = Decorator::UppercaseDecorator.new(text)
puts "Uppercase: #{upper_text.render}"

trimmed_text = Decorator::TrimDecorator.new(
  Decorator::TextContent.new('  spaced text  ')
)
puts "Trimmed: '#{trimmed_text.render}'"

# Complex decoration chain
decorated = Decorator::HtmlTagDecorator.new(
  Decorator::UppercaseDecorator.new(
    Decorator::TrimDecorator.new(
      Decorator::TextContent.new('  important  ')
    )
  ),
  tag: 'strong'
)

puts "Complex: #{decorated.render}"

puts

# ========================================
# Example 4: Data Source Decoration
# ========================================
puts '--- Example 4: Data Source with Multiple Decorators ---'
puts

# Create a file data source
file_source = Decorator::FileDataSource.new

# Write plain data
file_source.write('{"setting": "value"}')
plain_data = file_source.read
puts "Plain data: #{plain_data}"

puts

# Add encryption
encrypted_source = Decorator::EncryptionDecorator.new(
  Decorator::FileDataSource.new
)
encrypted_source.write('{"secret": "password123"}')
encrypted_data = encrypted_source.read
puts "Encrypted data read: #{encrypted_data}"

puts

# Add compression
compressed_source = Decorator::CompressionDecorator.new(
  Decorator::FileDataSource.new
)
compressed_source.write("{\"data\": \"#{'x' * 100}\"}")
compressed_data = compressed_source.read
puts "Compressed data length: #{compressed_data.length} (original would be ~108)"

puts

# Combine encryption + compression + logging
secure_source = Decorator::LoggingDecorator.new(
  Decorator::CompressionDecorator.new(
    Decorator::EncryptionDecorator.new(
      Decorator::FileDataSource.new
    )
  )
)

puts "\nWriting with encryption, compression, and logging:"
secure_source.write('{"sensitive": "data"}')

puts "\nReading with decryption, decompression, and logging:"
secure_data = secure_source.read
puts "Final data: #{secure_data}"

puts

# ========================================
# Example 5: Text Formatting Pipeline
# ========================================
puts '--- Example 5: Text Formatting Pipeline ---'
puts

original = Decorator::TextContent.new('ruby design patterns')

# Build a formatting pipeline
formatted = Decorator::SuffixDecorator.new(
  Decorator::PrefixDecorator.new(
    Decorator::UppercaseDecorator.new(original),
    prefix: '>>> '
  ),
  suffix: ' <<<'
)

puts "Original: #{original.render}"
puts "Formatted: #{formatted.render}"

# Another pipeline
title = Decorator::HtmlTagDecorator.new(
  Decorator::UppercaseDecorator.new(
    Decorator::TextContent.new('chapter 1')
  ),
  tag: 'h1'
)

puts "Title: #{title.render}"

puts
puts '=' * 60
puts 'End of Decorator Pattern Demo'
puts '=' * 60
