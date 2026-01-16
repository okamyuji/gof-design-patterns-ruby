# frozen_string_literal: true

module GofPatterns
  module Creational
    # Prototype Pattern (プロトタイプパターン)
    # ======================================
    # 目的: 既存のオブジェクトをコピーして新しいオブジェクトを生成し、
    #       オブジェクト生成のコストを削減する
    #
    # DDD Context:
    # - Entity のスナップショット作成
    # - Value Object のコピー生成
    # - Aggregate のテンプレート複製

    module Prototype
      # Prototype Interface
      module Cloneable
        def clone_deep
          raise NotImplementedError, "#{self.class} must implement #clone_deep"
        end

        def clone_shallow
          dup
        end
      end

      # Value Object: 座標（不変）
      class Point
        include Cloneable

        attr_reader :x, :y

        def initialize(x, y)
          @x = x
          @y = y
          freeze
        end

        def clone_deep
          Point.new(x, y)
        end

        def move(dx, dy)
          Point.new(x + dx, y + dy)
        end

        def ==(other)
          return false unless other.is_a?(Point)

          x == other.x && y == other.y
        end
        alias eql? ==

        def hash
          [x, y].hash
        end

        def to_s
          "(#{x}, #{y})"
        end
      end

      # Value Object: 色（不変）
      class Color
        include Cloneable

        attr_reader :r, :g, :b, :a

        def initialize(r, g, b, a = 255)
          @r = r.clamp(0, 255)
          @g = g.clamp(0, 255)
          @b = b.clamp(0, 255)
          @a = a.clamp(0, 255)
          freeze
        end

        def clone_deep
          Color.new(r, g, b, a)
        end

        def with_alpha(new_alpha)
          Color.new(r, g, b, new_alpha)
        end

        def ==(other)
          return false unless other.is_a?(Color)

          r == other.r && g == other.g && b == other.b && a == other.a
        end
        alias eql? ==

        def hash
          [r, g, b, a].hash
        end

        def to_hex
          format('#%02X%02X%02X', r, g, b)
        end

        # Predefined colors
        RED = new(255, 0, 0)
        GREEN = new(0, 255, 0)
        BLUE = new(0, 0, 255)
        BLACK = new(0, 0, 0)
        WHITE = new(255, 255, 255)
      end

      # Entity: 図形（プロトタイプ）
      class Shape
        include Cloneable

        attr_reader :id
        attr_accessor :position, :color, :name

        def initialize(id: nil)
          @id = id || generate_id
          @position = Point.new(0, 0)
          @color = Color::BLACK
          @name = 'Unnamed'
        end

        def clone_deep
          cloned = self.class.new(id: generate_id)
          cloned.position = position.clone_deep
          cloned.color = color.clone_deep
          cloned.name = "#{name} (copy)"
          cloned
        end

        def move_to(x, y)
          @position = Point.new(x, y)
          self
        end

        def draw
          raise NotImplementedError, "#{self.class} must implement #draw"
        end

        def area
          raise NotImplementedError, "#{self.class} must implement #area"
        end

        def ==(other)
          return false unless other.is_a?(Shape)

          id == other.id
        end
        alias eql? ==

        def hash
          id.hash
        end

        private

        def generate_id
          "SHAPE-#{SecureRandom.hex(4).upcase}"
        end
      end

      # Entity: 矩形
      class Rectangle < Shape
        attr_accessor :width, :height

        def initialize(width: 10, height: 10, **)
          super(**)
          @width = width
          @height = height
        end

        def clone_deep
          cloned = super
          cloned.width = width
          cloned.height = height
          cloned
        end

        def draw
          "Rectangle[#{name}] at #{position} size #{width}x#{height} color #{color.to_hex}"
        end

        def area
          width * height
        end
      end

      # Entity: 円
      class Circle < Shape
        attr_accessor :radius

        def initialize(radius: 5, **)
          super(**)
          @radius = radius
        end

        def clone_deep
          cloned = super
          cloned.radius = radius
          cloned
        end

        def draw
          "Circle[#{name}] at #{position} radius #{radius} color #{color.to_hex}"
        end

        def area
          Math::PI * radius * radius
        end
      end

      # Entity: 複合図形（Composite + Prototype）
      class CompositeShape < Shape
        def initialize(**)
          super
          @children = []
        end

        def add(shape)
          @children << shape
          self
        end

        def remove(shape)
          @children.delete(shape)
          self
        end

        def children
          @children.dup
        end

        def clone_deep
          cloned = super
          @children.each do |child|
            cloned.add(child.clone_deep)
          end
          cloned
        end

        def draw
          child_drawings = @children.map(&:draw).join(', ')
          "CompositeShape[#{name}] at #{position}: [#{child_drawings}]"
        end

        def area
          @children.sum(&:area)
        end
      end

      # Domain Service: プロトタイプレジストリ
      # 頻繁に使用されるオブジェクトのテンプレートを管理
      class PrototypeRegistry
        def initialize
          @prototypes = {}
          @mutex = Mutex.new
        end

        def register(key, prototype)
          raise ArgumentError, 'Prototype must include Cloneable' unless prototype.is_a?(Cloneable)

          @mutex.synchronize do
            @prototypes[key.to_sym] = prototype
          end
        end

        def unregister(key)
          @mutex.synchronize do
            @prototypes.delete(key.to_sym)
          end
        end

        def create(key)
          @mutex.synchronize do
            prototype = @prototypes[key.to_sym]
            raise KeyError, "Prototype '#{key}' not found" unless prototype

            prototype.clone_deep
          end
        end

        def list_keys
          @mutex.synchronize do
            @prototypes.keys
          end
        end

        def clear
          @mutex.synchronize do
            @prototypes.clear
          end
        end
      end

      # Domain Service: 図形ファクトリ（プロトタイプベース）
      class ShapeFactory
        def initialize
          @registry = PrototypeRegistry.new
          setup_default_prototypes
        end

        def create_rectangle(name: 'Rectangle', width: nil, height: nil, x: 0, y: 0, color: nil)
          shape = @registry.create(:rectangle)
          customize_shape(shape, name: name, x: x, y: y, color: color)
          shape.width = width if width
          shape.height = height if height
          shape
        end

        def create_circle(name: 'Circle', radius: nil, x: 0, y: 0, color: nil)
          shape = @registry.create(:circle)
          customize_shape(shape, name: name, x: x, y: y, color: color)
          shape.radius = radius if radius
          shape
        end

        def create_from_template(key, **customizations)
          shape = @registry.create(key)
          customize_shape(shape, **customizations)
          shape
        end

        def register_template(key, prototype)
          @registry.register(key, prototype)
        end

        private

        def setup_default_prototypes
          @registry.register(:rectangle, Rectangle.new(width: 100, height: 50))
          @registry.register(:circle, Circle.new(radius: 25))
        end

        def customize_shape(shape, name: nil, x: nil, y: nil, color: nil)
          shape.name = name if name
          shape.move_to(x, y) if x && y
          shape.color = color if color
          shape
        end
      end
    end
  end
end

require 'securerandom'
