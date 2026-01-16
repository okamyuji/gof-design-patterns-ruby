#!/usr/bin/env ruby
# frozen_string_literal: true

# Proxy Pattern Example
# =====================
# プロキシパターン: 他のオブジェクトへのアクセスを制御する代理を提供する
#
# Usage: ruby examples/structural/proxy_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Proxy = GofPatterns::Structural::Proxy

puts '=' * 60
puts 'Proxy Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Virtual Proxy (Lazy Loading)
# ========================================
puts '--- Example 1: Virtual Proxy (Lazy Loading) ---'
puts

puts 'Creating proxy (image not loaded yet)...'
proxy = Proxy::LazyImageProxy.new('large_photo.jpg')
puts "Proxy created for: #{proxy.filename}"
puts "Image loaded? #{proxy.loaded?}"

puts "\nAccessing image dimensions (triggers loading)..."
puts "Width: #{proxy.width}px"
puts "Height: #{proxy.height}px"
puts "Image loaded? #{proxy.loaded?}"

puts "\nDisplaying image:"
puts proxy.display

puts

# ========================================
# Example 2: Protection Proxy (Access Control)
# ========================================
puts '--- Example 2: Protection Proxy (Access Control) ---'
puts

# Guest user - no access
guest_proxy = Proxy::ProtectedImageProxy.new('secret.jpg', user_role: :guest)
puts 'Guest user trying to access image:'
begin
  guest_proxy.display
rescue SecurityError => e
  puts "  Access denied: #{e.message}"
end

puts

# Regular user - read access
user_proxy = Proxy::ProtectedImageProxy.new('photo.jpg', user_role: :user)
puts 'Regular user accessing image:'
puts "  #{user_proxy.display}"

puts "\nRegular user trying to delete:"
begin
  user_proxy.delete
rescue SecurityError => e
  puts "  Access denied: #{e.message}"
end

puts

# Admin user - full access
admin_proxy = Proxy::ProtectedImageProxy.new('admin_photo.jpg', user_role: :admin)
puts 'Admin user accessing image:'
puts "  #{admin_proxy.display}"
puts "\nAdmin user deleting:"
puts "  #{admin_proxy.delete}"

puts

# ========================================
# Example 3: Caching Proxy
# ========================================
puts '--- Example 3: Caching Proxy ---'
puts

cache = {}
cache_proxy = Proxy::CachingImageProxy.new('cached_image.jpg', cache: cache)

puts 'First access (loads and caches):'
puts "  #{cache_proxy.display}"
puts "  Width: #{cache_proxy.width}px"

puts "\nSecond access (uses cache):"
puts "  #{cache_proxy.display}"
puts "  Width: #{cache_proxy.width}px"

puts

puts

# ========================================
# Example 4: Comparing Direct vs Proxy Access
# ========================================
puts '--- Example 4: Performance Comparison ---'
puts

puts 'Direct image loading (no proxy):'
direct_start = Time.now
direct_images = 3.times.map do |i|
  img = Proxy::RealImage.new("direct_#{i}.jpg")
  img.display
end
direct_time = Time.now - direct_start
puts "  Loaded #{direct_images.size} images in #{(direct_time * 1000).round(2)}ms"

puts "\nLazy proxy (only metadata loaded initially):"
proxy_start = Time.now
lazy_proxies = 3.times.map do |i|
  Proxy::LazyImageProxy.new("proxy_#{i}.jpg")
end
proxy_time = Time.now - proxy_start
puts "  Created #{lazy_proxies.size} proxies in #{(proxy_time * 1000).round(2)}ms"
puts "  Actual images loaded? #{lazy_proxies.first.loaded?}"

puts
puts '=' * 60
puts 'End of Proxy Pattern Demo'
puts '=' * 60
