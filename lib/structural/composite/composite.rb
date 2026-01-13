# frozen_string_literal: true

module GofPatterns
  module Structural
    # Composite Pattern (コンポジットパターン)
    # ======================================
    # 目的: オブジェクトをツリー構造に組み立て、
    #       個々のオブジェクトと合成を同一視して扱う
    #
    # DDD Context:
    # - 階層的なエンティティ構造（組織、カテゴリ）
    # - Aggregate内の構造表現

    module Composite
      # Component Interface: ファイルシステムコンポーネント
      class FileSystemComponent
        attr_reader :name
        attr_accessor :parent

        def initialize(name)
          @name = name
          @parent = nil
        end

        def size
          raise NotImplementedError
        end

        def display(indent = 0)
          raise NotImplementedError
        end

        def find(name)
          raise NotImplementedError
        end

        def path
          parts = []
          current = self
          while current
            parts.unshift(current.name)
            current = current.parent
          end
          parts.join('/')
        end

        def leaf?
          raise NotImplementedError
        end

        def composite?
          !leaf?
        end
      end

      # Leaf: ファイル
      class File < FileSystemComponent
        attr_reader :content_size, :extension

        def initialize(name, content_size: 0)
          super(name)
          @content_size = content_size
          @extension = ::File.extname(name)
        end

        def size
          content_size
        end

        def display(indent = 0)
          "#{' ' * indent}📄 #{name} (#{size} bytes)"
        end

        def find(search_name)
          name == search_name ? self : nil
        end

        def leaf?
          true
        end

        def read
          "Content of #{name}"
        end
      end

      # Composite: ディレクトリ
      class Directory < FileSystemComponent
        def initialize(name)
          super(name)
          @children = []
        end

        def add(component)
          raise TypeError, 'Can only add FileSystemComponent' unless component.is_a?(FileSystemComponent)

          component.parent = self
          @children << component
          self
        end

        def remove(component)
          component.parent = nil if @children.delete(component)
          self
        end

        def children
          @children.dup
        end

        def size
          @children.sum(&:size)
        end

        def display(indent = 0)
          lines = ["#{' ' * indent}📁 #{name}/ (#{size} bytes)"]
          @children.each do |child|
            lines << child.display(indent + 2)
          end
          lines.join("\n")
        end

        def find(search_name)
          return self if name == search_name

          @children.each do |child|
            result = child.find(search_name)
            return result if result
          end
          nil
        end

        def leaf?
          false
        end

        def empty?
          @children.empty?
        end

        def count
          @children.size
        end

        def files
          @children.select(&:leaf?)
        end

        def directories
          @children.reject(&:leaf?)
        end

        def deep_files
          result = []
          @children.each do |child|
            if child.leaf?
              result << child
            else
              result.concat(child.deep_files)
            end
          end
          result
        end

        def deep_count
          @children.sum do |child|
            child.leaf? ? 1 : 1 + child.deep_count
          end
        end
      end

      # Entity: 組織構造（別の例）
      class OrganizationUnit
        attr_reader :id, :name, :unit_type
        attr_accessor :parent

        def initialize(id:, name:, unit_type:)
          @id = id
          @name = name
          @unit_type = unit_type.to_sym
          @parent = nil
        end

        def total_members
          raise NotImplementedError
        end

        def display(indent = 0)
          raise NotImplementedError
        end

        def ==(other)
          return false unless other.is_a?(OrganizationUnit)

          id == other.id
        end
        alias eql? ==

        def hash
          id.hash
        end
      end

      # Leaf: 従業員
      class Employee < OrganizationUnit
        attr_reader :position, :salary

        def initialize(id:, name:, position:, salary: 0)
          super(id: id, name: name, unit_type: :employee)
          @position = position
          @salary = salary
        end

        def total_members
          1
        end

        def total_salary
          salary
        end

        def display(indent = 0)
          "#{' ' * indent}👤 #{name} (#{position})"
        end
      end

      # Composite: 部門
      class Department < OrganizationUnit
        def initialize(id:, name:)
          super(id: id, name: name, unit_type: :department)
          @members = []
        end

        def add(unit)
          raise TypeError, 'Can only add OrganizationUnit' unless unit.is_a?(OrganizationUnit)

          unit.parent = self
          @members << unit
          self
        end

        def remove(unit)
          unit.parent = nil if @members.delete(unit)
          self
        end

        def members
          @members.dup
        end

        def total_members
          @members.sum(&:total_members)
        end

        def total_salary
          @members.sum do |member|
            member.respond_to?(:total_salary) ? member.total_salary : 0
          end
        end

        def display(indent = 0)
          lines = ["#{' ' * indent}🏢 #{name} (#{total_members} members)"]
          @members.each do |member|
            lines << member.display(indent + 2)
          end
          lines.join("\n")
        end

        def find_employee(employee_id)
          @members.each do |member|
            if member.is_a?(Employee) && member.id == employee_id
              return member
            elsif member.is_a?(Department)
              found = member.find_employee(employee_id)
              return found if found
            end
          end
          nil
        end

        def all_employees
          result = []
          @members.each do |member|
            if member.is_a?(Employee)
              result << member
            elsif member.is_a?(Department)
              result.concat(member.all_employees)
            end
          end
          result
        end
      end

      # Domain Service: ファイルシステムビルダー
      class FileSystemBuilder
        def initialize
          @root = nil
          @current = nil
        end

        def root(name)
          @root = Directory.new(name)
          @current = @root
          self
        end

        def directory(name, &block)
          dir = Directory.new(name)
          @current.add(dir)
          if block_given?
            previous = @current
            @current = dir
            instance_eval(&block)
            @current = previous
          end
          self
        end

        def file(name, size: 0)
          @current.add(File.new(name, content_size: size))
          self
        end

        def build
          @root
        end
      end

      # Domain Service: 組織ビルダー
      class OrganizationBuilder
        def initialize
          @root = nil
          @current = nil
          @id_counter = 0
        end

        def company(name)
          @root = Department.new(id: next_id, name: name)
          @current = @root
          self
        end

        def department(name, &block)
          dept = Department.new(id: next_id, name: name)
          @current.add(dept)
          if block_given?
            previous = @current
            @current = dept
            instance_eval(&block)
            @current = previous
          end
          self
        end

        def employee(name, position:, salary: 0)
          emp = Employee.new(id: next_id, name: name, position: position, salary: salary)
          @current.add(emp)
          self
        end

        def build
          @root
        end

        private

        def next_id
          @id_counter += 1
          "ORG-#{@id_counter.to_s.rjust(4, '0')}"
        end
      end
    end
  end
end
