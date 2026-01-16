#!/usr/bin/env ruby
# frozen_string_literal: true

# Memento Pattern Example
# =======================
# メメントパターン: オブジェクトの内部状態を保存し、
#                   後でその状態に復元できるようにする
#
# Usage: ruby examples/behavioral/memento_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Memento = GofPatterns::Behavioral::Memento

puts '=' * 60
puts 'Memento Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Text Editor with Undo
# ========================================
puts '--- Example 1: Text Editor ---'
puts

editor = Memento::TextEditor.new
history = Memento::History.new

editor.type('Hello')
history.save(editor.create_memento)

editor.type(' World')
history.save(editor.create_memento)

editor.type('!')
history.save(editor.create_memento)

puts "Current content: '#{editor.content}'"
puts

puts 'Undoing...'
memento = history.undo
editor.restore_from_memento(memento) if memento
puts "Content after undo: '#{editor.content}'"

history.undo
editor.restore_from_memento(history.current) if history.current
puts "Content after second undo: '#{editor.content}'"

puts

puts

# ========================================
# Example 2: Multiple Snapshots
# ========================================
puts '--- Example 2: Multiple Snapshots ---'
puts

editor = Memento::TextEditor.new
snapshots = []

['Step 1', 'Step 2', 'Step 3', 'Step 4', 'Step 5'].each do |step|
  editor.type("#{step}. ")
  snapshots << editor.create_memento("Snapshot #{step}")
end

puts "Final content: '#{editor.content}'"
puts

puts 'Available snapshots:'
snapshots.each { |snap| puts "  #{snap.name}" }

puts

puts 'Restoring to Snapshot Step 3...'
editor.restore_from_memento(snapshots[2])
puts "Content after restore: '#{editor.content}'"

puts
puts '=' * 60
puts 'End of Memento Pattern Demo'
puts '=' * 60
