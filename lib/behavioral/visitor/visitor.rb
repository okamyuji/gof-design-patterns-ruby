# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Visitor Pattern (ビジタパターン)
    # ================================
    # 目的: オブジェクト構造を変更せずに、
    #       新しい操作を追加できるようにする
    #
    # DDD Context:
    # - Entity の横断的な処理
    # - レポート生成、シリアライズ

    module Visitor
      # Visitor Interface
      class Visitor
        def visit(_element)
          raise NotImplementedError
        end
      end

      # Element Interface
      class Element
        def accept(_visitor)
          raise NotImplementedError
        end
      end

      # ===== 図形の例 =====

      # Concrete Element: 円
      class Circle < Element
        attr_reader :radius

        def initialize(radius)
          @radius = radius
        end

        def accept(visitor)
          visitor.visit_circle(self)
        end
      end

      # Concrete Element: 四角形
      class Rectangle < Element
        attr_reader :width, :height

        def initialize(width, height)
          @width = width
          @height = height
        end

        def accept(visitor)
          visitor.visit_rectangle(self)
        end
      end

      # Concrete Element: 三角形
      class Triangle < Element
        attr_reader :base, :height

        def initialize(base, height)
          @base = base
          @height = height
        end

        def accept(visitor)
          visitor.visit_triangle(self)
        end
      end

      # Concrete Visitor: 面積計算
      class AreaCalculator < Visitor
        def visit_circle(circle)
          Math::PI * circle.radius**2
        end

        def visit_rectangle(rectangle)
          rectangle.width * rectangle.height
        end

        def visit_triangle(triangle)
          0.5 * triangle.base * triangle.height
        end
      end

      # Concrete Visitor: 周囲長計算
      class PerimeterCalculator < Visitor
        def visit_circle(circle)
          2 * Math::PI * circle.radius
        end

        def visit_rectangle(rectangle)
          2 * (rectangle.width + rectangle.height)
        end

        def visit_triangle(triangle)
          # 二等辺三角形と仮定
          side = Math.sqrt((triangle.base / 2.0)**2 + triangle.height**2)
          triangle.base + (2 * side)
        end
      end

      # Concrete Visitor: SVG描画
      class SvgRenderer < Visitor
        def visit_circle(circle)
          %(<circle r="#{circle.radius}" cx="50" cy="50" fill="blue"/>)
        end

        def visit_rectangle(rectangle)
          %(<rect width="#{rectangle.width}" height="#{rectangle.height}" fill="red"/>)
        end

        def visit_triangle(triangle)
          points = "0,#{triangle.height} #{triangle.base / 2.0},0 #{triangle.base},#{triangle.height}"
          %(<polygon points="#{points}" fill="green"/>)
        end
      end

      # Concrete Visitor: 説明文生成
      class DescriptionGenerator < Visitor
        def visit_circle(circle)
          "Circle with radius #{circle.radius}"
        end

        def visit_rectangle(rectangle)
          "Rectangle #{rectangle.width}x#{rectangle.height}"
        end

        def visit_triangle(triangle)
          "Triangle with base #{triangle.base} and height #{triangle.height}"
        end
      end

      # ===== ファイルシステムの例 =====

      # Concrete Element: ファイル
      class File < Element
        attr_reader :name, :size

        def initialize(name, size)
          @name = name
          @size = size
        end

        def accept(visitor)
          visitor.visit_file(self)
        end
      end

      # Concrete Element: ディレクトリ
      class Directory < Element
        attr_reader :name, :children

        def initialize(name)
          @name = name
          @children = []
        end

        def add(child)
          @children << child
          self
        end

        def accept(visitor)
          visitor.visit_directory(self)
        end
      end

      # Concrete Visitor: サイズ計算
      class SizeCalculator < Visitor
        def visit_file(file)
          file.size
        end

        def visit_directory(directory)
          directory.children.sum { |child| child.accept(self) }
        end
      end

      # Concrete Visitor: ファイル数カウント
      class FileCounter < Visitor
        def visit_file(_file)
          1
        end

        def visit_directory(directory)
          directory.children.sum { |child| child.accept(self) }
        end
      end

      # Concrete Visitor: ツリー表示
      class TreePrinter < Visitor
        def initialize
          @indent = 0
        end

        def visit_file(file)
          "#{' ' * @indent}📄 #{file.name} (#{file.size} bytes)"
        end

        def visit_directory(directory)
          result = "#{' ' * @indent}📁 #{directory.name}/\n"
          @indent += 2
          directory.children.each do |child|
            result += "#{child.accept(self)}\n"
          end
          @indent -= 2
          result.chomp
        end
      end

      # ===== 従業員の例 =====

      # Concrete Element: 一般社員
      class Employee < Element
        attr_reader :name, :salary

        def initialize(name, salary)
          @name = name
          @salary = salary
        end

        def accept(visitor)
          visitor.visit_employee(self)
        end
      end

      # Concrete Element: マネージャー
      class Manager < Element
        attr_reader :name, :salary, :team

        def initialize(name, salary)
          @name = name
          @salary = salary
          @team = []
        end

        def add_member(employee)
          @team << employee
          self
        end

        def accept(visitor)
          visitor.visit_manager(self)
        end
      end

      # Concrete Visitor: 給与計算
      class SalaryCalculator < Visitor
        def visit_employee(employee)
          employee.salary
        end

        def visit_manager(manager)
          manager.salary + manager.team.sum { |member| member.accept(self) }
        end
      end

      # Concrete Visitor: 昇給処理
      class SalaryRaiser < Visitor
        def initialize(percentage)
          @percentage = percentage
        end

        def visit_employee(employee)
          raise = (employee.salary * @percentage / 100.0).round
          { name: employee.name, old_salary: employee.salary, raise: raise, new_salary: employee.salary + raise }
        end

        def visit_manager(manager)
          # マネージャーは追加ボーナス
          base_raise = (manager.salary * @percentage / 100.0).round
          bonus = (manager.team.size * 1000)
          total_raise = base_raise + bonus

          team_raises = manager.team.map { |member| member.accept(self) }

          {
            name: manager.name,
            old_salary: manager.salary,
            raise: total_raise,
            new_salary: manager.salary + total_raise,
            team_raises: team_raises
          }
        end
      end

      # Concrete Visitor: 組織図生成
      class OrgChartGenerator < Visitor
        def visit_employee(employee)
          "👤 #{employee.name} (¥#{employee.salary})"
        end

        def visit_manager(manager)
          result = "👔 #{manager.name} (¥#{manager.salary})\n"
          manager.team.each do |member|
            result += "   └─ #{member.accept(self)}\n"
          end
          result.chomp
        end
      end

      # Domain Service: 図形コレクション
      class ShapeCollection
        def initialize
          @shapes = []
        end

        def add(shape)
          @shapes << shape
          self
        end

        def accept(visitor)
          @shapes.map { |shape| shape.accept(visitor) }
        end

        def total_area
          calculator = AreaCalculator.new
          @shapes.sum { |shape| shape.accept(calculator) }
        end

        def total_perimeter
          calculator = PerimeterCalculator.new
          @shapes.sum { |shape| shape.accept(calculator) }
        end

        def render_svg
          renderer = SvgRenderer.new
          elements = @shapes.map { |shape| shape.accept(renderer) }.join("\n  ")
          <<~SVG
            <svg width="200" height="200">
              #{elements}
            </svg>
          SVG
        end
      end
    end
  end
end
