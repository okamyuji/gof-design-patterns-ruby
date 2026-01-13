# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Interpreter Pattern (インタプリタパターン)
    # ========================================
    # 目的: 言語の文法を定義し、その文法に従って文を解釈する
    #
    # DDD Context:
    # - ドメイン固有言語（DSL）の実装
    # - ビジネスルールの表現

    module Interpreter
      # Context: 式の評価コンテキスト
      class Context
        def initialize
          @variables = {}
        end

        def set(name, value)
          @variables[name.to_s] = value
        end

        def get(name)
          @variables[name.to_s]
        end

        def defined?(name)
          @variables.key?(name.to_s)
        end

        def all_variables
          @variables.dup
        end
      end

      # Expression Interface: 式の抽象
      class Expression
        def interpret(_context)
          raise NotImplementedError
        end
      end

      # Terminal Expression: 数値リテラル
      class NumberExpression < Expression
        def initialize(value)
          @value = value.to_f
        end

        def interpret(_context)
          @value
        end

        def to_s
          @value.to_s
        end
      end

      # Terminal Expression: 変数
      class VariableExpression < Expression
        def initialize(name)
          @name = name.to_s
        end

        def interpret(context)
          value = context.get(@name)
          raise "Undefined variable: #{@name}" if value.nil?

          value
        end

        def to_s
          @name
        end
      end

      # Non-terminal Expression: 加算
      class AddExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) + @right.interpret(context)
        end

        def to_s
          "(#{@left} + #{@right})"
        end
      end

      # Non-terminal Expression: 減算
      class SubtractExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) - @right.interpret(context)
        end

        def to_s
          "(#{@left} - #{@right})"
        end
      end

      # Non-terminal Expression: 乗算
      class MultiplyExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) * @right.interpret(context)
        end

        def to_s
          "(#{@left} * #{@right})"
        end
      end

      # Non-terminal Expression: 除算
      class DivideExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          right_val = @right.interpret(context)
          raise 'Division by zero' if right_val.zero?

          @left.interpret(context) / right_val
        end

        def to_s
          "(#{@left} / #{@right})"
        end
      end

      # ===== Boolean Expression =====

      # Terminal Expression: 真偽値リテラル
      class BooleanExpression < Expression
        def initialize(value)
          @value = !!value
        end

        def interpret(_context)
          @value
        end

        def to_s
          @value.to_s
        end
      end

      # Non-terminal Expression: 比較（等しい）
      class EqualsExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) == @right.interpret(context)
        end

        def to_s
          "(#{@left} == #{@right})"
        end
      end

      # Non-terminal Expression: 比較（より大きい）
      class GreaterThanExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) > @right.interpret(context)
        end

        def to_s
          "(#{@left} > #{@right})"
        end
      end

      # Non-terminal Expression: 比較（より小さい）
      class LessThanExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) < @right.interpret(context)
        end

        def to_s
          "(#{@left} < #{@right})"
        end
      end

      # Non-terminal Expression: AND
      class AndExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) && @right.interpret(context)
        end

        def to_s
          "(#{@left} AND #{@right})"
        end
      end

      # Non-terminal Expression: OR
      class OrExpression < Expression
        def initialize(left, right)
          @left = left
          @right = right
        end

        def interpret(context)
          @left.interpret(context) || @right.interpret(context)
        end

        def to_s
          "(#{@left} OR #{@right})"
        end
      end

      # Non-terminal Expression: NOT
      class NotExpression < Expression
        def initialize(expression)
          @expression = expression
        end

        def interpret(context)
          !@expression.interpret(context)
        end

        def to_s
          "(NOT #{@expression})"
        end
      end

      # ===== Simple Expression Parser =====

      class ExpressionParser
        OPERATORS = {
          '+' => AddExpression,
          '-' => SubtractExpression,
          '*' => MultiplyExpression,
          '/' => DivideExpression
        }.freeze

        def parse(expression_string)
          tokens = tokenize(expression_string)
          build_expression(tokens)
        end

        private

        def tokenize(str)
          str.scan(/\d+\.?\d*|[+\-*\/()]|\w+/)
        end

        def build_expression(tokens)
          return nil if tokens.empty?

          parse_additive(tokens)
        end

        def parse_additive(tokens)
          left = parse_multiplicative(tokens)
          while ['+', '-'].include?(tokens.first)
            op = tokens.shift
            right = parse_multiplicative(tokens)
            left = OPERATORS[op].new(left, right)
          end
          left
        end

        def parse_multiplicative(tokens)
          left = parse_primary(tokens)
          while ['*', '/'].include?(tokens.first)
            op = tokens.shift
            right = parse_primary(tokens)
            left = OPERATORS[op].new(left, right)
          end
          left
        end

        def parse_primary(tokens)
          token = tokens.shift
          if token == '('
            expr = parse_additive(tokens)
            tokens.shift # consume ')'
            expr
          elsif token.match?(/\A\d+\.?\d*\z/)
            NumberExpression.new(token.to_f)
          else
            VariableExpression.new(token)
          end
        end
      end

      # Domain Service: 式評価サービス
      class ExpressionEvaluator
        def initialize
          @context = Context.new
          @parser = ExpressionParser.new
        end

        def set_variable(name, value)
          @context.set(name, value)
        end

        def evaluate(expression_string)
          expression = @parser.parse(expression_string)
          expression.interpret(@context)
        end

        def build_expression(&block)
          builder = ExpressionBuilder.new
          builder.instance_eval(&block)
          builder.result
        end

        def evaluate_expression(expression)
          expression.interpret(@context)
        end
      end

      # DSL Builder: 式構築ヘルパー
      class ExpressionBuilder
        attr_reader :result

        def number(value)
          @result = NumberExpression.new(value)
          self
        end

        def variable(name)
          @result = VariableExpression.new(name)
          self
        end

        def add(other)
          @result = AddExpression.new(@result, to_expression(other))
          self
        end

        def subtract(other)
          @result = SubtractExpression.new(@result, to_expression(other))
          self
        end

        def multiply(other)
          @result = MultiplyExpression.new(@result, to_expression(other))
          self
        end

        def divide(other)
          @result = DivideExpression.new(@result, to_expression(other))
          self
        end

        def greater_than(other)
          @result = GreaterThanExpression.new(@result, to_expression(other))
          self
        end

        def less_than(other)
          @result = LessThanExpression.new(@result, to_expression(other))
          self
        end

        def equals(other)
          @result = EqualsExpression.new(@result, to_expression(other))
          self
        end

        def and_expr(other)
          @result = AndExpression.new(@result, to_expression(other))
          self
        end

        def or_expr(other)
          @result = OrExpression.new(@result, to_expression(other))
          self
        end

        def not_expr
          @result = NotExpression.new(@result)
          self
        end

        private

        def to_expression(value)
          case value
          when Expression
            value
          when Numeric
            NumberExpression.new(value)
          when String, Symbol
            VariableExpression.new(value)
          else
            raise ArgumentError, "Cannot convert #{value.class} to expression"
          end
        end
      end
    end
  end
end
