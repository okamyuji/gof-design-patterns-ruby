#!/usr/bin/env ruby
# frozen_string_literal: true

# Mediator Pattern Example
# ========================
# メディエータパターン: オブジェクト間の通信を仲介し、
#                       オブジェクト同士の直接的な参照を避ける
#
# Usage: ruby examples/behavioral/mediator_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Mediator = GofPatterns::Behavioral::Mediator

puts '=' * 60
puts 'Mediator Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Chat Room
# ========================================
puts '--- Example 1: Chat Room ---'
puts

chat_room = Mediator::ChatRoom.new

alice = Mediator::ChatUser.new('Alice')
bob = Mediator::ChatUser.new('Bob')
charlie = Mediator::ChatUser.new('Charlie')

chat_room.register(alice)
chat_room.register(bob)
chat_room.register(charlie)

puts

alice.send_message('Hello everyone!')
puts

charlie.send_message('Hey all!')

puts

puts
puts '=' * 60
puts 'End of Mediator Pattern Demo'
puts '=' * 60
