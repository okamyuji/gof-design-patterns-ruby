#!/usr/bin/env ruby
# frozen_string_literal: true

# Flyweight Pattern Example
# =========================
# フライウェイトパターン: 多数のオブジェクト間で共通の状態を共有し、
#                         メモリ使用量を削減する
#
# Usage: ruby examples/structural/flyweight_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Flyweight = GofPatterns::Structural::Flyweight

puts '=' * 60
puts 'Flyweight Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Character Styles (Shared State)
# ========================================
puts '--- Example 1: Character Styles ---'
puts

factory = Flyweight::CharacterStyleFactory.new

# Create characters with shared styles
style1 = factory.get_style(font_family: 'Arial', font_size: 12)
style2 = factory.get_style(font_family: 'Arial', font_size: 12)
style3 = factory.get_style(font_family: 'Arial', font_size: 14, bold: true)

puts "style1 and style2 are the same object? #{style1.equal?(style2)}"
puts "style1 and style3 are the same object? #{style1.equal?(style3)}"
puts "Number of unique styles created: #{factory.styles_count}"

char_h = Flyweight::Character.new('H', position_x: 0, position_y: 0, style: style1)
char_e = Flyweight::Character.new('e', position_x: 10, position_y: 0, style: style1)
char_l1 = Flyweight::Character.new('l', position_x: 20, position_y: 0, style: style1)
char_l2 = Flyweight::Character.new('l', position_x: 30, position_y: 0, style: style1)
char_o = Flyweight::Character.new('o', position_x: 40, position_y: 0, style: style1)

puts "\nRendering 'Hello' with shared style:"
[char_h, char_e, char_l1, char_l2, char_o].each do |char|
  puts "  #{char.render}"
end

puts

# ========================================
# Example 2: Memory Efficiency Demonstration
# ========================================
puts '--- Example 2: Memory Efficiency ---'
puts

factory.clear
text = 'The quick brown fox jumps over the lazy dog'

# Create many characters with shared styles
arial_12 = factory.get_style(font_family: 'Arial', font_size: 12)
times_14 = factory.get_style(font_family: 'Times', font_size: 14)
courier_16 = factory.get_style(font_family: 'Courier', font_size: 16, bold: true)

characters = []
text.chars.each_with_index do |c, i|
  style = case i % 3
          when 0 then arial_12
          when 1 then times_14
          else courier_16
          end
  characters << Flyweight::Character.new(c, position_x: i * 10, position_y: 0, style: style)
end

puts "Created #{characters.size} character objects"
puts "But only #{factory.styles_count} unique style objects"
puts 'Memory saved by sharing styles!'

puts

# ========================================
# Example 3: Tree Forest (Game Example)
# ========================================
puts '--- Example 3: Tree Forest in Game ---'
puts

tree_factory = Flyweight::TreeTypeFactory.new

# Create tree types
oak = tree_factory.get_tree_type(name: 'Oak', color: 'Green', texture: 'rough')
tree_factory.get_tree_type(name: 'Pine', color: 'Dark Green', texture: 'needles')
tree_factory.get_tree_type(name: 'Birch', color: 'White', texture: 'smooth')

# Request same type again - should return shared instance
oak2 = tree_factory.get_tree_type(name: 'Oak', color: 'Green', texture: 'rough')
puts "oak and oak2 are the same object? #{oak.equal?(oak2)}"
puts "Number of tree types: #{tree_factory.types_count}"

# Create many tree instances in forest
forest = Flyweight::Forest.new

100.times do |i|
  x_pos = rand(0..1000)
  y_pos = rand(0..1000)
  tree_attrs = case i % 3
               when 0 then { name: 'Oak', color: 'Green', texture: 'rough' }
               when 1 then { name: 'Pine', color: 'Dark Green', texture: 'needles' }
               else { name: 'Birch', color: 'White', texture: 'smooth' }
               end
  forest.plant_tree(x: x_pos, y: y_pos, **tree_attrs)
end

puts "\nForest statistics:"
puts "  Total trees planted: #{forest.trees_count}"
puts "  Unique tree types: #{tree_factory.types_count}"

puts

puts
puts '=' * 60
puts 'End of Flyweight Pattern Demo'
puts '=' * 60
