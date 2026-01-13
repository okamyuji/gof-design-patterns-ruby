# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Iterator Pattern (イテレータパターン)
    # ====================================
    # 目的: コレクションの要素に順次アクセスする方法を提供し、
    #       コレクションの内部構造を公開しない
    #
    # DDD Context:
    # - Aggregate のトラバーサル
    # - Repository の結果セット

    module Iterator
      # Iterator Interface
      class Iterator
        def has_next?
          raise NotImplementedError
        end

        def next
          raise NotImplementedError
        end

        def current
          raise NotImplementedError
        end

        def reset
          raise NotImplementedError
        end
      end

      # Aggregate Interface
      class Aggregate
        def create_iterator
          raise NotImplementedError
        end
      end

      # Value Object: 書籍
      class Book
        attr_reader :isbn, :title, :author, :year

        def initialize(isbn:, title:, author:, year:)
          @isbn = isbn.freeze
          @title = title.freeze
          @author = author.freeze
          @year = year
          freeze
        end

        def ==(other)
          return false unless other.is_a?(Book)

          isbn == other.isbn
        end
        alias eql? ==

        def hash
          isbn.hash
        end

        def to_s
          "#{title} by #{author} (#{year})"
        end
      end

      # Concrete Aggregate: 本棚
      class Bookshelf < Aggregate
        include Enumerable

        def initialize
          @books = []
        end

        def add(book)
          @books << book
          self
        end

        def remove(book)
          @books.delete(book)
          self
        end

        def size
          @books.size
        end

        def [](index)
          @books[index]
        end

        def create_iterator
          BookshelfIterator.new(self)
        end

        def each(&block)
          return to_enum(:each) unless block_given?

          iterator = create_iterator
          while iterator.has_next?
            block.call(iterator.next)
          end
        end
      end

      # Concrete Iterator: 本棚イテレータ
      class BookshelfIterator < Iterator
        def initialize(bookshelf)
          @bookshelf = bookshelf
          @index = 0
        end

        def has_next?
          @index < @bookshelf.size
        end

        def next
          raise StopIteration unless has_next?

          book = @bookshelf[@index]
          @index += 1
          book
        end

        def current
          @bookshelf[@index]
        end

        def reset
          @index = 0
        end
      end

      # Reverse Iterator: 逆順イテレータ
      class ReverseBookshelfIterator < Iterator
        def initialize(bookshelf)
          @bookshelf = bookshelf
          @index = bookshelf.size - 1
        end

        def has_next?
          @index >= 0
        end

        def next
          raise StopIteration unless has_next?

          book = @bookshelf[@index]
          @index -= 1
          book
        end

        def current
          @bookshelf[@index]
        end

        def reset
          @index = @bookshelf.size - 1
        end
      end

      # Filtering Iterator: フィルタリングイテレータ
      class FilteringIterator < Iterator
        def initialize(iterator, &predicate)
          @iterator = iterator
          @predicate = predicate
          @current = nil
          advance_to_next_match
        end

        def has_next?
          !@current.nil?
        end

        def next
          raise StopIteration unless has_next?

          result = @current
          advance_to_next_match
          result
        end

        def current
          @current
        end

        def reset
          @iterator.reset
          @current = nil
          advance_to_next_match
        end

        private

        def advance_to_next_match
          while @iterator.has_next?
            item = @iterator.next
            if @predicate.call(item)
              @current = item
              return
            end
          end
          @current = nil
        end
      end

      # ===== 二分木の例 =====

      # Entity: 二分木ノード
      class TreeNode
        attr_accessor :value, :left, :right

        def initialize(value)
          @value = value
          @left = nil
          @right = nil
        end
      end

      # Concrete Aggregate: 二分木
      class BinaryTree < Aggregate
        attr_accessor :root

        def initialize
          @root = nil
        end

        def insert(value)
          @root = insert_node(@root, value)
          self
        end

        def create_iterator(traversal: :inorder)
          case traversal
          when :inorder
            InorderIterator.new(@root)
          when :preorder
            PreorderIterator.new(@root)
          when :postorder
            PostorderIterator.new(@root)
          else
            raise ArgumentError, "Unknown traversal: #{traversal}"
          end
        end

        private

        def insert_node(node, value)
          return TreeNode.new(value) if node.nil?

          if value < node.value
            node.left = insert_node(node.left, value)
          else
            node.right = insert_node(node.right, value)
          end
          node
        end
      end

      # Concrete Iterator: 中間順（Inorder）
      class InorderIterator < Iterator
        def initialize(root)
          @root = root
          @stack = []
          @current = root
          push_left(@current)
        end

        def has_next?
          !@stack.empty?
        end

        def next
          raise StopIteration unless has_next?

          node = @stack.pop
          push_left(node.right)
          node.value
        end

        def current
          @stack.last&.value
        end

        def reset
          @stack.clear
          @current = @root
          push_left(@current)
        end

        private

        def push_left(node)
          while node
            @stack.push(node)
            node = node.left
          end
        end
      end

      # Concrete Iterator: 前順（Preorder）
      class PreorderIterator < Iterator
        def initialize(root)
          @root = root
          @stack = []
          @stack.push(root) if root
        end

        def has_next?
          !@stack.empty?
        end

        def next
          raise StopIteration unless has_next?

          node = @stack.pop
          @stack.push(node.right) if node.right
          @stack.push(node.left) if node.left
          node.value
        end

        def current
          @stack.last&.value
        end

        def reset
          @stack.clear
          @stack.push(@root) if @root
        end
      end

      # Concrete Iterator: 後順（Postorder）
      class PostorderIterator < Iterator
        def initialize(root)
          @root = root
          @values = []
          build_postorder(root)
          @index = 0
        end

        def has_next?
          @index < @values.size
        end

        def next
          raise StopIteration unless has_next?

          value = @values[@index]
          @index += 1
          value
        end

        def current
          @values[@index]
        end

        def reset
          @index = 0
        end

        private

        def build_postorder(node)
          return if node.nil?

          build_postorder(node.left)
          build_postorder(node.right)
          @values << node.value
        end
      end

      # Domain Service: イテレータユーティリティ
      class IteratorUtils
        def self.to_array(iterator)
          result = []
          while iterator.has_next?
            result << iterator.next
          end
          result
        end

        def self.filter(iterator, &predicate)
          FilteringIterator.new(iterator, &predicate)
        end

        def self.map(iterator, &transformer)
          result = []
          while iterator.has_next?
            result << transformer.call(iterator.next)
          end
          result
        end

        def self.reduce(iterator, initial, &reducer)
          result = initial
          while iterator.has_next?
            result = reducer.call(result, iterator.next)
          end
          result
        end

        def self.count(iterator)
          count = 0
          while iterator.has_next?
            iterator.next
            count += 1
          end
          count
        end
      end
    end
  end
end
