#!/usr/bin/env ruby
# frozen_string_literal: true

# Builder Pattern Example
# =======================
# ビルダーパターン: 複雑なオブジェクトの構築を段階的に行い、
#                   構築プロセスと表現を分離する
#
# Usage: ruby examples/creational/builder_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Builder = GofPatterns::Creational::Builder

puts '=' * 60
puts 'Builder Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Basic Builder Usage
# ========================================
puts '--- Example 1: Basic Builder ---'
puts

builder = Builder::UserProfileBuilder.new
profile = builder.set_id('USER-001')
                 .set_name('Taro Yamada')
                 .set_age(30)
                 .set_address(
                   postal_code: '100-0001',
                   prefecture: 'Tokyo',
                   city: 'Chiyoda-ku',
                   street: '1-1-1 Marunouchi'
                 )
                 .set_contact(
                   email: 'taro@example.com',
                   phone: '03-1234-5678'
                 )
                 .add_preference(:language, 'ja')
                 .add_preference(:timezone, 'Asia/Tokyo')
                 .build

puts "Profile created: #{profile.name}"
puts "ID: #{profile.id}"
puts "Age: #{profile.age}"
puts "Address: #{profile.address.full_address}"
puts "Email: #{profile.contact.email}"
puts "Phone: #{profile.contact.phone}"
puts "Preferences: #{profile.preferences.inspect}"

puts

# ========================================
# Example 2: Fluent Builder with DSL
# ========================================
puts '--- Example 2: Fluent Builder with DSL ---'
puts

profile = Builder::FluentUserProfileBuilder.new
                                           .id('USER-002')
                                           .name('Hanako Suzuki')
                                           .age(28)
                                           .address do
                                             postal_code '150-0001'
                                             prefecture 'Tokyo'
                                             city 'Shibuya-ku'
                                             street '2-2-2 Dogenzaka'
                                             building 'Tower Building 10F'
                                           end
                                           .contact do
                                             email 'hanako@example.com'
                                             phone '03-9876-5432'
                                           end
                                           .preference(:theme, 'dark')
                                           .preference(:notifications, true)
                                           .build

puts "Profile created: #{profile.name}"
puts "ID: #{profile.id}"
puts "Address: #{profile.address.full_address}"
puts "Email: #{profile.contact.email}"
puts "Preferences: #{profile.preferences.inspect}"

puts

# ========================================
# Example 3: Using Director for Common Patterns
# ========================================
puts '--- Example 3: Director Pattern ---'
puts

builder = Builder::UserProfileBuilder.new
director = Builder::UserProfileDirector.new(builder)

# Minimal profile
minimal = director.build_minimal_profile(
  id: 'USER-003',
  name: 'Jiro Tanaka'
)
puts 'Minimal Profile:'
puts "  Name: #{minimal.name}"
puts "  ID: #{minimal.id}"
puts

# Full profile
full = director.build_full_profile(
  id: 'USER-004',
  name: 'Yuki Sato',
  age: 35,
  address_params: {
    postal_code: '530-0001',
    prefecture: 'Osaka',
    city: 'Kita-ku',
    street: '3-3-3 Umeda'
  },
  contact_params: {
    email: 'yuki@example.com',
    phone: '06-1111-2222'
  },
  preferences: {
    language: 'en',
    currency: 'JPY'
  }
)
puts 'Full Profile:'
puts "  Name: #{full.name}"
puts "  Age: #{full.age}"
puts "  Address: #{full.address.full_address}"
puts "  Contact: #{full.contact.email}"
puts

# Business profile
business = director.build_business_profile(
  id: 'USER-005',
  name: 'Kenji Watanabe',
  company_email: 'kenji.watanabe@company.com',
  company_phone: '03-5555-6666'
)
puts 'Business Profile:'
puts "  Name: #{business.name}"
puts "  Email: #{business.contact.email}"
puts "  Account type: #{business.preferences[:account_type]}"

puts

# ========================================
# Example 4: ProfileFactory with Block
# ========================================
puts '--- Example 4: ProfileFactory with Block ---'
puts

profile = Builder::ProfileFactory.create do
  id 'USER-006'
  name 'Misaki Kobayashi'
  age 26
  address do
    postal_code '810-0001'
    prefecture 'Fukuoka'
    city 'Chuo-ku'
    street '4-4-4 Tenjin'
  end
  contact do
    email 'misaki@example.com'
    phone '092-3333-4444'
  end
  preference :newsletter, true
  preference :marketing, false
end

puts "Profile created: #{profile.name}"
puts 'Full profile data:'
puts profile.to_h.inspect

puts

# ========================================
# Example 5: Builder Reset and Reuse
# ========================================
puts '--- Example 5: Builder Reset and Reuse ---'
puts

builder = Builder::UserProfileBuilder.new

profiles = 3.times.map do |i|
  builder.reset
         .set_id("USER-#{100 + i}")
         .set_name("User #{i + 1}")
         .set_age(20 + (i * 5))
         .build
end

puts "Created #{profiles.size} profiles:"
profiles.each do |p|
  puts "  #{p.id}: #{p.name}, age #{p.age}"
end

puts
puts '=' * 60
puts 'End of Builder Pattern Demo'
puts '=' * 60
