#!/usr/bin/env ruby
# frozen_string_literal: true

# Prototype Pattern Example
# =========================
# プロトタイプパターン: 既存のオブジェクトをコピーして新しいオブジェクトを生成し、
#                       オブジェクト生成のコストを削減する
#
# Usage: ruby examples/creational/prototype_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Prototype = GofPatterns::Creational::Prototype

puts '=' * 60
puts 'Prototype Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Basic Shape Cloning
# ========================================
puts '--- Example 1: Basic Shape Cloning ---'
puts

rectangle = Prototype::Rectangle.new(width: 100, height: 50)
rectangle.name = 'Original Rectangle'
rectangle.move_to(10, 20)
rectangle.color = Prototype::Color::BLUE

puts "Original: #{rectangle.draw}"
puts "Area: #{rectangle.area}"
puts

cloned = rectangle.clone_deep
puts "Cloned: #{cloned.draw}"
puts "Same object? #{rectangle.equal?(cloned)}"
puts "Same ID? #{rectangle.id == cloned.id}"

puts

# ========================================
# Example 2: Circle Cloning
# ========================================
puts '--- Example 2: Circle Cloning ---'
puts

circle = Prototype::Circle.new(radius: 25)
circle.name = 'Original Circle'
circle.move_to(50, 50)
circle.color = Prototype::Color::RED

puts "Original: #{circle.draw}"
puts "Area: #{circle.area.round(2)}"
puts

copies = 3.times.map do |i|
  copy = circle.clone_deep
  copy.move_to(50 + (i * 30), 50)
  copy.radius = 25 + (i * 5)
  copy
end

puts "Created #{copies.size} copies:"
copies.each_with_index do |copy, i|
  puts "  Copy #{i + 1}: #{copy.draw}"
end

puts

# ========================================
# Example 3: Composite Shape Cloning
# ========================================
puts '--- Example 3: Composite Shape (Deep Copy) ---'
puts

composite = Prototype::CompositeShape.new
composite.name = 'My Drawing'
composite.add(Prototype::Rectangle.new(width: 50, height: 30))
composite.add(Prototype::Circle.new(radius: 15))

puts 'Original composite:'
puts composite.draw
puts "Total area: #{composite.area.round(2)}"
puts

cloned_composite = composite.clone_deep
puts "\nCloned composite:"
puts cloned_composite.draw
puts "Total area: #{cloned_composite.area.round(2)}"
puts "Same object? #{composite.equal?(cloned_composite)}"
puts "Children are different objects? #{!composite.children[0].equal?(cloned_composite.children[0])}"

puts

# ========================================
# Example 4: Prototype Registry
# ========================================
puts '--- Example 4: Prototype Registry ---'
puts

registry = Prototype::PrototypeRegistry.new

# Register custom templates
large_rectangle = Prototype::Rectangle.new(width: 200, height: 100)
large_rectangle.name = 'Large Rectangle Template'
large_rectangle.color = Prototype::Color::GREEN

registry.register(:large_rect, large_rectangle)

small_circle = Prototype::Circle.new(radius: 10)
small_circle.name = 'Small Circle Template'
small_circle.color = Prototype::Color::BLUE

registry.register(:small_circle, small_circle)

puts "Registered templates: #{registry.list_keys.join(', ')}"
puts

# Create shapes from registry
shape1 = registry.create(:large_rect)
shape1.move_to(100, 100)
puts "Created from template: #{shape1.draw}"

shape2 = registry.create(:small_circle)
shape2.move_to(200, 200)
puts "Created from template: #{shape2.draw}"

puts

# ========================================
# Example 5: Shape Factory with Prototypes
# ========================================
puts '--- Example 5: Shape Factory ---'
puts

factory = Prototype::ShapeFactory.new

# Create shapes with customizations
rect1 = factory.create_rectangle(name: 'Button', width: 120, height: 40, x: 10, y: 10)
rect2 = factory.create_rectangle(name: 'Panel', width: 300, height: 200, x: 50, y: 50)
circle1 = factory.create_circle(name: 'Avatar', radius: 30, x: 100, y: 100)
circle2 = factory.create_circle(name: 'Icon', radius: 15, x: 150, y: 150, color: Prototype::Color::GREEN)

shapes = [rect1, rect2, circle1, circle2]
puts 'Shapes created from factory:'
shapes.each do |shape|
  puts "  #{shape.draw}"
end

puts

# ========================================
# Example 6: Custom Template Registration
# ========================================
puts '--- Example 6: Custom Template Registration ---'
puts

factory = Prototype::ShapeFactory.new

# Create and register a custom template
custom_rect = Prototype::Rectangle.new(width: 80, height: 80)
custom_rect.name = 'Square Template'
custom_rect.color = Prototype::Color::RED
factory.register_template(:square, custom_rect)

# Create shapes from custom template
square1 = factory.create_from_template(:square, name: 'Square 1', x: 0, y: 0)
square2 = factory.create_from_template(:square, name: 'Square 2', x: 100, y: 100)

puts 'Squares created from custom template:'
puts "  #{square1.draw}"
puts "  #{square2.draw}"

puts
puts '=' * 60
puts 'End of Prototype Pattern Demo'
puts '=' * 60
