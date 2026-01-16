#!/usr/bin/env ruby
# frozen_string_literal: true

# Chain of Responsibility Pattern Example
# ========================================
# 責任の連鎖パターン: リクエストを処理できるオブジェクトのチェーンに沿って渡し、
#                     適切なハンドラに処理させる
#
# Usage: ruby examples/behavioral/chain_of_responsibility_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

ChainOfResponsibility = GofPatterns::Behavioral::ChainOfResponsibility

puts '=' * 60
puts 'Chain of Responsibility Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Simple Request Handler Chain
# ========================================
puts '--- Example 1: Simple Request Chain ---'
puts

auth = ChainOfResponsibility::AuthenticationHandler.new(valid_tokens: ['user_token_12345'])
validation = ChainOfResponsibility::ValidationHandler.new
authorization = ChainOfResponsibility::AuthorizationHandler.new(permissions: { admin: %i[read write] })
logging = ChainOfResponsibility::LoggingHandler.new

auth.set_next(validation).set_next(authorization).set_next(logging)

request1 = ChainOfResponsibility::Request.new(
  type: :authenticate,
  content: 'user_token_12345',
  metadata: { user_id: '001' }
)

response = auth.handle(request1)
puts "Request type: #{request1.type}"
puts "Response: #{response.message}"
puts "Handled by: #{response.handler}"
puts "Success: #{response.success?}"

puts

# ========================================
# Example 2: Different Request Types
# ========================================
puts '--- Example 2: Different Request Types ---'
puts

chain = ChainOfResponsibility::AuthenticationHandler.new(valid_tokens: ['valid_token'])
chain.set_next(ChainOfResponsibility::ValidationHandler.new)
     .set_next(ChainOfResponsibility::AuthorizationHandler.new(permissions: { user: [:read] }))
     .set_next(ChainOfResponsibility::LoggingHandler.new)

requests = [
  ChainOfResponsibility::Request.new(type: :authenticate, content: 'valid_token'),
  ChainOfResponsibility::Request.new(type: :validate, content: { name: 'John', age: 25 }),
  ChainOfResponsibility::Request.new(type: :authorize, content: :read, metadata: { role: :user })
]

requests.each do |req|
  resp = chain.handle(req)
  puts "#{req.type}: #{resp.message} (#{resp.success? ? 'OK' : 'FAILED'})"
end

puts

# ========================================
# Example 3: Request with No Handler
# ========================================
puts '--- Example 3: Unhandled Request ---'
puts

chain = ChainOfResponsibility::AuthenticationHandler.new(valid_tokens: [])
chain.set_next(ChainOfResponsibility::ValidationHandler.new)

unknown_request = ChainOfResponsibility::Request.new(
  type: :unknown_type,
  content: 'some data'
)

response = chain.handle(unknown_request)
puts "Request type: #{unknown_request.type}"
puts "Response: #{response.message}"
puts "Success: #{response.success?}"

puts
puts '=' * 60
puts 'End of Chain of Responsibility Pattern Demo'
puts '=' * 60
