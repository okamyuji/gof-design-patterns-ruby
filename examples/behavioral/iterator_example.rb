#!/usr/bin/env ruby
# frozen_string_literal: true

# Iterator Pattern Example
# ========================
# イテレータパターン: コレクションの要素に順次アクセスする方法を提供し、
#                     コレクションの内部構造を公開しない
#
# Usage: ruby examples/behavioral/iterator_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Iterator = GofPatterns::Behavioral::Iterator

puts '=' * 60
puts 'Iterator Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Bookshelf Iterator
# ========================================
puts '--- Example 1: Bookshelf Iterator ---'
puts

bookshelf = Iterator::Bookshelf.new
bookshelf.add(Iterator::Book.new(isbn: '978-1234567890', title: 'Ruby Programming', author: 'John Doe', year: 2020))
bookshelf.add(Iterator::Book.new(isbn: '978-0987654321', title: 'Design Patterns', author: 'Gang of Four', year: 1994))
bookshelf.add(Iterator::Book.new(isbn: '978-1111111111', title: 'Clean Code', author: 'Robert Martin', year: 2008))

puts "Bookshelf has #{bookshelf.size} books"
puts

iterator = bookshelf.create_iterator
while iterator.has_next?
  book = iterator.next
  puts "  #{book}"
end

puts

# ========================================
# Example 2: Using Enumerable
# ========================================
puts '--- Example 2: Using Enumerable ---'
puts

puts 'All books:'
bookshelf.each do |book|
  puts "  #{book.title} (#{book.year})"
end

puts

puts 'Books by year:'
bookshelf.select { |book| book.year > 2000 }.each do |book|
  puts "  #{book.title} - #{book.year}"
end

puts

# ========================================
# Example 3: Filtered Iterator
# ========================================
puts '--- Example 3: Filtered Iterator ---'
puts

filtered = bookshelf.select { |book| book.author.include?('Martin') }
puts 'Books by authors containing "Martin":'
filtered.each do |book|
  puts "  #{book}"
end

puts
# ========================================
puts '--- Example 6: Binary Tree Iterator ---'
puts

tree = Iterator::BinaryTree.new
[50, 30, 70, 20, 40, 60, 80].each { |value| tree.insert(value) }

puts 'In-order traversal (sorted):'
iter = tree.create_iterator(traversal: :inorder)
print "#{iter.next} " while iter.has_next?
puts

puts 'Pre-order traversal:'
iter = tree.create_iterator(traversal: :preorder)
print "#{iter.next} " while iter.has_next?
puts

puts 'Post-order traversal:'
iter = tree.create_iterator(traversal: :postorder)
print "#{iter.next} " while iter.has_next?
puts

puts
puts '=' * 60
puts 'End of Iterator Pattern Demo'
puts '=' * 60
