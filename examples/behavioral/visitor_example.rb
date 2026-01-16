#!/usr/bin/env ruby
# frozen_string_literal: true

# Visitor Pattern Example
# =======================
# ビジタパターン: オブジェクト構造を変更せずに、
#                 新しい操作を追加できるようにする
#
# Usage: ruby examples/behavioral/visitor_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Visitor = GofPatterns::Behavioral::Visitor

puts '=' * 60
puts 'Visitor Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Shape Area Calculation
# ========================================
puts '--- Example 1: Shape Area Calculation ---'
puts

shapes = [
  Visitor::Circle.new(5),
  Visitor::Rectangle.new(10, 20),
  Visitor::Triangle.new(8, 12)
]

area_calculator = Visitor::AreaCalculator.new

puts 'Calculating areas:'
shapes.each do |shape|
  area = shape.accept(area_calculator)
  puts "  #{shape.class.name.split('::').last}: #{area.round(2)}"
end

puts

# ========================================
# Example 2: Shape Perimeter Calculation
# ========================================
puts '--- Example 2: Shape Perimeter Calculation ---'
puts

perimeter_calculator = Visitor::PerimeterCalculator.new

puts 'Calculating perimeters:'
shapes.each do |shape|
  perimeter = shape.accept(perimeter_calculator)
  puts "  #{shape.class.name.split('::').last}: #{perimeter.round(2)}"
end

puts

# ========================================
# Example 3: Shape Drawing
# ========================================
puts '--- Example 3: SVG Rendering ---'
puts

renderer = Visitor::SvgRenderer.new

puts 'Rendering shapes as SVG:'
shapes.each do |shape|
  result = shape.accept(renderer)
  puts "  #{result}"
end

puts

# ========================================
# Example 4: File System Visitor
# ========================================
puts '--- Example 4: File System Visitor ---'
puts

root = Visitor::Directory.new('root')
docs = Visitor::Directory.new('documents')
pics = Visitor::Directory.new('pictures')

root.add(Visitor::File.new('readme.txt', 1024))
root.add(docs)
root.add(pics)

docs.add(Visitor::File.new('report.pdf', 50_000))
docs.add(Visitor::File.new('notes.txt', 2048))

pics.add(Visitor::File.new('photo1.jpg', 200_000))
pics.add(Visitor::File.new('photo2.jpg', 180_000))

size_calculator = Visitor::SizeCalculator.new
total_size = root.accept(size_calculator)

puts "Total size: #{total_size} bytes (#{(total_size / 1024.0).round(2)} KB)"

puts

# ========================================
# Example 5: File Count Visitor
# ========================================
puts '--- Example 5: File Count ---'
puts

counter = Visitor::FileCounter.new
file_count = root.accept(counter)

puts "Total files: #{file_count}"

puts
puts '=' * 60
puts 'End of Visitor Pattern Demo'
puts '=' * 60
