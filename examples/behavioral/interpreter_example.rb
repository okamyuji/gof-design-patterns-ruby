#!/usr/bin/env ruby
# frozen_string_literal: true

# Interpreter Pattern Example
# ===========================
# インタプリタパターン: 言語の文法を定義し、その文法に従って文を解釈する
#
# Usage: ruby examples/behavioral/interpreter_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Interpreter = GofPatterns::Behavioral::Interpreter

puts '=' * 60
puts 'Interpreter Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Simple Math Expressions
# ========================================
puts '--- Example 1: Math Expressions ---'
puts

context = Interpreter::Context.new

# Expression: 5 + 3
expr1 = Interpreter::AddExpression.new(
  Interpreter::NumberExpression.new(5),
  Interpreter::NumberExpression.new(3)
)

puts "5 + 3 = #{expr1.interpret(context)}"

# Expression: 10 - 4
expr2 = Interpreter::SubtractExpression.new(
  Interpreter::NumberExpression.new(10),
  Interpreter::NumberExpression.new(4)
)

puts "10 - 4 = #{expr2.interpret(context)}"

# Expression: 6 * 7
expr3 = Interpreter::MultiplyExpression.new(
  Interpreter::NumberExpression.new(6),
  Interpreter::NumberExpression.new(7)
)

puts "6 * 7 = #{expr3.interpret(context)}"

# Expression: 20 / 4
expr4 = Interpreter::DivideExpression.new(
  Interpreter::NumberExpression.new(20),
  Interpreter::NumberExpression.new(4)
)

puts "20 / 4 = #{expr4.interpret(context)}"

puts

# ========================================
# Example 2: Complex Expressions
# ========================================
puts '--- Example 2: Complex Expressions ---'
puts

# Expression: (5 + 3) * 2
expr5 = Interpreter::MultiplyExpression.new(
  Interpreter::AddExpression.new(
    Interpreter::NumberExpression.new(5),
    Interpreter::NumberExpression.new(3)
  ),
  Interpreter::NumberExpression.new(2)
)

puts "(5 + 3) * 2 = #{expr5.interpret(context)}"

# Expression: 10 + (4 * 3)
expr6 = Interpreter::AddExpression.new(
  Interpreter::NumberExpression.new(10),
  Interpreter::MultiplyExpression.new(
    Interpreter::NumberExpression.new(4),
    Interpreter::NumberExpression.new(3)
  )
)

puts "10 + (4 * 3) = #{expr6.interpret(context)}"

# Expression: (20 - 5) / 3
expr7 = Interpreter::DivideExpression.new(
  Interpreter::SubtractExpression.new(
    Interpreter::NumberExpression.new(20),
    Interpreter::NumberExpression.new(5)
  ),
  Interpreter::NumberExpression.new(3)
)

puts "(20 - 5) / 3 = #{expr7.interpret(context).round(2)}"

puts

# ========================================
# Example 3: Variables
# ========================================
puts '--- Example 3: Using Variables ---'
puts

context = Interpreter::Context.new
context.set('x', 10)
context.set('y', 5)

# Expression: x + y
expr8 = Interpreter::AddExpression.new(
  Interpreter::VariableExpression.new('x'),
  Interpreter::VariableExpression.new('y')
)

puts "x + y where x=#{context.get('x')}, y=#{context.get('y')}"
puts "Result: #{expr8.interpret(context)}"

# Expression: x * 2 + y
expr9 = Interpreter::AddExpression.new(
  Interpreter::MultiplyExpression.new(
    Interpreter::VariableExpression.new('x'),
    Interpreter::NumberExpression.new(2)
  ),
  Interpreter::VariableExpression.new('y')
)

puts "x * 2 + y = #{expr9.interpret(context)}"

puts

# ========================================
# Example 4: Boolean Expressions
# ========================================
puts '--- Example 4: Boolean Expressions ---'
puts

# Expression: true AND false
bool_expr1 = Interpreter::AndExpression.new(
  Interpreter::BooleanExpression.new(true),
  Interpreter::BooleanExpression.new(false)
)

puts "true AND false = #{bool_expr1.interpret(context)}"

# Expression: true OR false
bool_expr2 = Interpreter::OrExpression.new(
  Interpreter::BooleanExpression.new(true),
  Interpreter::BooleanExpression.new(false)
)

puts "true OR false = #{bool_expr2.interpret(context)}"

# Expression: NOT true
bool_expr3 = Interpreter::NotExpression.new(
  Interpreter::BooleanExpression.new(true)
)

puts "NOT true = #{bool_expr3.interpret(context)}"

puts

# ========================================
# Example 5: Expression Parser
# ========================================
puts '--- Example 5: Expression Parser ---'
puts

parser = Interpreter::ExpressionParser.new
context = Interpreter::Context.new
context.set('a', 15)
context.set('b', 3)

expressions = [
  '2 + 3',
  '10 - 4',
  '5 * 6',
  '20 / 4',
  'a + b',
  'a * 2'
]

puts 'Parsing and evaluating expressions:'
expressions.each do |expr_str|
  expr = parser.parse(expr_str)
  result = expr.interpret(context)
  puts "  #{expr_str} = #{result}"
rescue StandardError => e
  puts "  #{expr_str} => Error: #{e.message}"
end

puts
puts '=' * 60
puts 'End of Interpreter Pattern Demo'
puts '=' * 60
