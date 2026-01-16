#!/usr/bin/env ruby
# frozen_string_literal: true

# Command Pattern Example
# =======================
# コマンドパターン: リクエストをオブジェクトとしてカプセル化し、
#                   実行、取り消し、再実行を可能にする
#
# Usage: ruby examples/behavioral/command_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Command = GofPatterns::Behavioral::Command

puts '=' * 60
puts 'Command Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Text Editor with Undo/Redo
# ========================================
puts '--- Example 1: Text Editor ---'
puts

editor = Command::TextEditor.new
document = editor.document

puts "Initial content: '#{document.content}'"

# Execute commands using editor methods
editor.insert('Hello')
puts "After insert 'Hello': '#{document.content}'"

editor.insert(' World')
puts "After insert ' World': '#{document.content}'"

editor.insert('!')
puts "After insert '!': '#{document.content}'"

# Undo
editor.undo
puts "After undo: '#{document.content}'"

editor.undo
puts "After undo again: '#{document.content}'"

# Redo
editor.redo
puts "After redo: '#{document.content}'"

puts

# ========================================
# Example 2: Delete and Replace Commands
# ========================================
puts '--- Example 2: Delete and Replace ---'
puts

editor = Command::TextEditor.new('The quick brown fox')
document = editor.document

puts "Initial: '#{document.content}'"

# Delete
editor.delete(10, 5)
puts "After delete: '#{document.content}'"

# Replace
editor.replace(4, 5, 'slow')
puts "After replace: '#{document.content}'"

# Undo all
editor.undo
puts "After undo: '#{document.content}'"
editor.undo
puts "After undo again: '#{document.content}'"

puts

# ========================================
# Example 3: Macro Commands
# ========================================
puts '--- Example 3: Macro Commands ---'
puts

editor = Command::TextEditor.new
document = editor.document

# Create a macro
macro = Command::MacroCommand.new('Write greeting')
macro.add(Command::InsertCommand.new(document, 'Dear Customer,'))
macro.add(Command::InsertCommand.new(document, "\n"))
macro.add(Command::InsertCommand.new(document, 'Thank you for your order.'))

editor.history.execute(macro)
puts 'After macro execution:'
puts document.content
puts

# Undo the entire macro
editor.undo
puts "After undoing macro: '#{document.content}'"

puts

# ========================================
# Example 4: Command History
# ========================================
puts '--- Example 4: Command History ---'
puts

editor = Command::TextEditor.new
document = editor.document

commands = [
  Command::InsertCommand.new(document, 'First line'),
  Command::InsertCommand.new(document, "\n"),
  Command::InsertCommand.new(document, 'Second line'),
  Command::InsertCommand.new(document, "\n"),
  Command::InsertCommand.new(document, 'Third line')
]

commands.each { |cmd| editor.history.execute(cmd) }

puts 'Document content:'
puts document.content
puts

# ========================================
# Example 5: Banking Commands
# ========================================
puts '--- Example 5: Banking Commands ---'
puts

account = Command::BankAccount.new('ACC-001', 10_000)
history = Command::CommandHistory.new

puts "Initial balance: ¥#{account.balance}"

history.execute(Command::DepositCommand.new(account, 5000))
puts "After deposit ¥5000: ¥#{account.balance}"

history.execute(Command::WithdrawCommand.new(account, 3000))
puts "After withdraw ¥3000: ¥#{account.balance}"

account2 = Command::BankAccount.new('ACC-002', 0)
history.execute(Command::TransferCommand.new(account, account2, 2000))
puts "After transfer ¥2000: ¥#{account.balance}"

puts "\nTransaction history:"
history.history.each do |description|
  puts "  #{description}"
end

# Undo last transaction
history.undo
puts "\nAfter undo: ¥#{account.balance}"

puts
puts '=' * 60
puts 'End of Command Pattern Demo'
puts '=' * 60
