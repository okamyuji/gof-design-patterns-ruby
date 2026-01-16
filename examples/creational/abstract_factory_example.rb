#!/usr/bin/env ruby
# frozen_string_literal: true

# Abstract Factory Pattern Example
# =================================
# 抽象ファクトリパターン: 関連するオブジェクトのファミリーを、
#                         具象クラスを指定せずに生成する
#
# Usage: ruby examples/creational/abstract_factory_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

AbstractFactory = GofPatterns::Creational::AbstractFactory

puts '=' * 60
puts 'Abstract Factory Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Creating UI Components with Light Theme
# ========================================
puts '--- Example 1: Light Theme UI ---'
puts

light_factory = AbstractFactory::LightThemeFactory.new

button = light_factory.create_button('Submit')
checkbox = light_factory.create_checkbox('Remember me', checked: true)
text_field = light_factory.create_text_field('Enter username')

puts "Theme: #{light_factory.theme_name}"
puts button.render
puts checkbox.render
puts text_field.render
puts "Button click: #{button.click}"

puts

# ========================================
# Example 2: Creating UI Components with Dark Theme
# ========================================
puts '--- Example 2: Dark Theme UI ---'
puts

dark_factory = AbstractFactory::DarkThemeFactory.new

button = dark_factory.create_button('Login')
checkbox = dark_factory.create_checkbox('Accept terms')
text_field = dark_factory.create_text_field('Password')

puts "Theme: #{dark_factory.theme_name}"
puts button.render
puts checkbox.render
puts text_field.render

checkbox.toggle
puts "After toggle: #{checkbox.render}"

text_field.input('secret123')
puts "After input: #{text_field.render}"

puts

# ========================================
# Example 3: Using Theme Manager
# ========================================
puts '--- Example 3: Theme Manager ---'
puts

puts "Available themes: #{AbstractFactory::ThemeManager.available_themes.join(', ')}"
puts

%i[light dark].each do |theme_name|
  factory = AbstractFactory::ThemeManager.factory_for(theme_name)
  button = factory.create_button('Click me')
  puts "#{factory.theme_name} theme button: #{button.render}"
end

puts

# ========================================
# Example 4: Building Complete Form with UIBuilder
# ========================================
puts '--- Example 4: Complete Form with UIBuilder ---'
puts

def build_login_form(factory)
  builder = AbstractFactory::UIBuilder.new(factory)
  builder.add_text_field('Username')
         .add_text_field('Password')
         .add_checkbox('Remember me')
         .add_button('Login')
         .add_button('Cancel')
  builder.build
end

puts 'Login Form with Light Theme:'
light_factory = AbstractFactory::LightThemeFactory.new
light_components = build_login_form(light_factory)
light_components.each { |comp| puts "  #{comp.render}" }

puts
puts 'Login Form with Dark Theme:'
dark_factory = AbstractFactory::DarkThemeFactory.new
dark_components = build_login_form(dark_factory)
dark_components.each { |comp| puts "  #{comp.render}" }

puts

# ========================================
# Example 5: Runtime Theme Switching
# ========================================
puts '--- Example 5: Runtime Theme Switching ---'
puts

user_preference = :light
factory = AbstractFactory::ThemeManager.factory_for(user_preference)
builder = AbstractFactory::UIBuilder.new(factory)
builder.add_button('Save')
       .add_button('Cancel')

puts "Current theme: #{factory.theme_name}"
puts builder.render_all
puts

# Switch theme
puts 'Switching to dark theme...'
user_preference = :dark
factory = AbstractFactory::ThemeManager.factory_for(user_preference)
builder = AbstractFactory::UIBuilder.new(factory)
builder.add_button('Save')
       .add_button('Cancel')

puts "Current theme: #{factory.theme_name}"
puts builder.render_all

puts
puts '=' * 60
puts 'End of Abstract Factory Pattern Demo'
puts '=' * 60
