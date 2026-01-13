# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/interpreter/interpreter'

class TestInterpreter < GofPatternTest
  def test_context_set_and_get
    context = GofPatterns::Behavioral::Interpreter::Context.new
    context.set(:x, 10)
    context.set(:y, 20)

    assert_equal 10, context.get(:x)
    assert_equal 20, context.get(:y)
  end

  def test_number_expression
    expr = GofPatterns::Behavioral::Interpreter::NumberExpression.new(42)
    context = GofPatterns::Behavioral::Interpreter::Context.new

    assert_equal 42.0, expr.interpret(context)
  end

  def test_variable_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    context.set(:x, 100)
    expr = GofPatterns::Behavioral::Interpreter::VariableExpression.new(:x)

    assert_equal 100, expr.interpret(context)
  end

  def test_variable_expression_undefined
    context = GofPatterns::Behavioral::Interpreter::Context.new
    expr = GofPatterns::Behavioral::Interpreter::VariableExpression.new(:undefined_var)

    assert_raises(RuntimeError) do
      expr.interpret(context)
    end
  end

  def test_add_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(10)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(5)
    expr = GofPatterns::Behavioral::Interpreter::AddExpression.new(left, right)

    assert_equal 15.0, expr.interpret(context)
  end

  def test_subtract_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(10)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(3)
    expr = GofPatterns::Behavioral::Interpreter::SubtractExpression.new(left, right)

    assert_equal 7.0, expr.interpret(context)
  end

  def test_multiply_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(6)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(7)
    expr = GofPatterns::Behavioral::Interpreter::MultiplyExpression.new(left, right)

    assert_equal 42.0, expr.interpret(context)
  end

  def test_divide_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(20)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(4)
    expr = GofPatterns::Behavioral::Interpreter::DivideExpression.new(left, right)

    assert_equal 5.0, expr.interpret(context)
  end

  def test_divide_by_zero
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(10)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(0)
    expr = GofPatterns::Behavioral::Interpreter::DivideExpression.new(left, right)

    assert_raises(RuntimeError) do
      expr.interpret(context)
    end
  end

  def test_complex_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    context.set(:x, 5)

    # (x + 3) * 2
    x = GofPatterns::Behavioral::Interpreter::VariableExpression.new(:x)
    three = GofPatterns::Behavioral::Interpreter::NumberExpression.new(3)
    two = GofPatterns::Behavioral::Interpreter::NumberExpression.new(2)
    add = GofPatterns::Behavioral::Interpreter::AddExpression.new(x, three)
    expr = GofPatterns::Behavioral::Interpreter::MultiplyExpression.new(add, two)

    assert_equal 16.0, expr.interpret(context)
  end

  def test_boolean_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new

    true_expr = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(true)
    false_expr = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(false)

    assert true_expr.interpret(context)
    refute false_expr.interpret(context)
  end

  def test_equals_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(5)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(5)
    expr = GofPatterns::Behavioral::Interpreter::EqualsExpression.new(left, right)

    assert expr.interpret(context)
  end

  def test_greater_than_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(10)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(5)
    expr = GofPatterns::Behavioral::Interpreter::GreaterThanExpression.new(left, right)

    assert expr.interpret(context)
  end

  def test_less_than_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(3)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(7)
    expr = GofPatterns::Behavioral::Interpreter::LessThanExpression.new(left, right)

    assert expr.interpret(context)
  end

  def test_and_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(true)
    right = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(true)
    expr = GofPatterns::Behavioral::Interpreter::AndExpression.new(left, right)

    assert expr.interpret(context)
  end

  def test_or_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    left = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(false)
    right = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(true)
    expr = GofPatterns::Behavioral::Interpreter::OrExpression.new(left, right)

    assert expr.interpret(context)
  end

  def test_not_expression
    context = GofPatterns::Behavioral::Interpreter::Context.new
    inner = GofPatterns::Behavioral::Interpreter::BooleanExpression.new(false)
    expr = GofPatterns::Behavioral::Interpreter::NotExpression.new(inner)

    assert expr.interpret(context)
  end

  def test_expression_parser_simple
    parser = GofPatterns::Behavioral::Interpreter::ExpressionParser.new
    context = GofPatterns::Behavioral::Interpreter::Context.new

    expr = parser.parse('5 + 3')
    assert_equal 8.0, expr.interpret(context)
  end

  def test_expression_parser_multiplication
    parser = GofPatterns::Behavioral::Interpreter::ExpressionParser.new
    context = GofPatterns::Behavioral::Interpreter::Context.new

    expr = parser.parse('2 + 3 * 4')
    # 演算子の優先順位: 2 + (3 * 4) = 14
    assert_equal 14.0, expr.interpret(context)
  end

  def test_expression_parser_with_variables
    parser = GofPatterns::Behavioral::Interpreter::ExpressionParser.new
    context = GofPatterns::Behavioral::Interpreter::Context.new
    context.set(:x, 10)
    context.set(:y, 5)

    expr = parser.parse('x + y * 2')
    assert_equal 20.0, expr.interpret(context)
  end

  def test_expression_evaluator
    evaluator = GofPatterns::Behavioral::Interpreter::ExpressionEvaluator.new
    evaluator.set_variable(:x, 100)
    evaluator.set_variable(:y, 50)

    result = evaluator.evaluate('x + y')
    assert_equal 150.0, result
  end

  def test_expression_builder
    evaluator = GofPatterns::Behavioral::Interpreter::ExpressionEvaluator.new
    evaluator.set_variable(:price, 1000)

    expr = evaluator.build_expression do
      variable(:price).multiply(1.1).add(500)
    end

    result = evaluator.evaluate_expression(expr)
    assert_equal 1600.0, result
  end

  def test_expression_to_string
    left = GofPatterns::Behavioral::Interpreter::NumberExpression.new(5)
    right = GofPatterns::Behavioral::Interpreter::NumberExpression.new(3)
    expr = GofPatterns::Behavioral::Interpreter::AddExpression.new(left, right)

    assert_match(/5.*\+.*3/, expr.to_s)
  end
end
