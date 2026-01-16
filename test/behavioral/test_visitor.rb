# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/visitor/visitor'

class TestVisitor < GofPatternTest
  def test_circle_creation
    circle = GofPatterns::Behavioral::Visitor::Circle.new(10)

    assert_equal 10, circle.radius
  end

  def test_rectangle_creation
    rect = GofPatterns::Behavioral::Visitor::Rectangle.new(20, 10)

    assert_equal 20, rect.width
    assert_equal 10, rect.height
  end

  def test_triangle_creation
    triangle = GofPatterns::Behavioral::Visitor::Triangle.new(10, 5)

    assert_equal 10, triangle.base
    assert_equal 5, triangle.height
  end

  def test_area_calculator_circle
    circle = GofPatterns::Behavioral::Visitor::Circle.new(10)
    calculator = GofPatterns::Behavioral::Visitor::AreaCalculator.new

    area = circle.accept(calculator)
    expected = Math::PI * 100

    assert_in_delta expected, area, 0.001
  end

  def test_area_calculator_rectangle
    rect = GofPatterns::Behavioral::Visitor::Rectangle.new(20, 10)
    calculator = GofPatterns::Behavioral::Visitor::AreaCalculator.new

    area = rect.accept(calculator)

    assert_equal 200, area
  end

  def test_area_calculator_triangle
    triangle = GofPatterns::Behavioral::Visitor::Triangle.new(10, 5)
    calculator = GofPatterns::Behavioral::Visitor::AreaCalculator.new

    area = triangle.accept(calculator)

    assert_equal 25, area
  end

  def test_perimeter_calculator_circle
    circle = GofPatterns::Behavioral::Visitor::Circle.new(10)
    calculator = GofPatterns::Behavioral::Visitor::PerimeterCalculator.new

    perimeter = circle.accept(calculator)
    expected = 2 * Math::PI * 10

    assert_in_delta expected, perimeter, 0.001
  end

  def test_perimeter_calculator_rectangle
    rect = GofPatterns::Behavioral::Visitor::Rectangle.new(20, 10)
    calculator = GofPatterns::Behavioral::Visitor::PerimeterCalculator.new

    perimeter = rect.accept(calculator)

    assert_equal 60, perimeter
  end

  def test_svg_renderer_circle
    circle = GofPatterns::Behavioral::Visitor::Circle.new(10)
    renderer = GofPatterns::Behavioral::Visitor::SvgRenderer.new

    svg = circle.accept(renderer)

    assert_match(/<circle.*r="10"/, svg)
    assert_match(/fill="blue"/, svg)
  end

  def test_svg_renderer_rectangle
    rect = GofPatterns::Behavioral::Visitor::Rectangle.new(100, 50)
    renderer = GofPatterns::Behavioral::Visitor::SvgRenderer.new

    svg = rect.accept(renderer)

    assert_match(/<rect.*width="100".*height="50"/, svg)
  end

  def test_description_generator
    circle = GofPatterns::Behavioral::Visitor::Circle.new(10)
    rect = GofPatterns::Behavioral::Visitor::Rectangle.new(20, 10)
    generator = GofPatterns::Behavioral::Visitor::DescriptionGenerator.new

    assert_match(/Circle.*radius 10/, circle.accept(generator))
    assert_match(/Rectangle.*20x10/, rect.accept(generator))
  end

  def test_file_and_directory
    file = GofPatterns::Behavioral::Visitor::File.new('test.txt', 100)
    dir = GofPatterns::Behavioral::Visitor::Directory.new('docs')

    assert_equal 'test.txt', file.name
    assert_equal 100, file.size
    assert_equal 'docs', dir.name
  end

  def test_size_calculator_file
    file = GofPatterns::Behavioral::Visitor::File.new('test.txt', 100)
    calculator = GofPatterns::Behavioral::Visitor::SizeCalculator.new

    assert_equal 100, file.accept(calculator)
  end

  def test_size_calculator_directory
    dir = GofPatterns::Behavioral::Visitor::Directory.new('root')
    dir.add(GofPatterns::Behavioral::Visitor::File.new('a.txt', 100))
    dir.add(GofPatterns::Behavioral::Visitor::File.new('b.txt', 200))

    calculator = GofPatterns::Behavioral::Visitor::SizeCalculator.new

    assert_equal 300, dir.accept(calculator)
  end

  def test_size_calculator_nested_directory
    root = GofPatterns::Behavioral::Visitor::Directory.new('root')
    sub = GofPatterns::Behavioral::Visitor::Directory.new('sub')
    sub.add(GofPatterns::Behavioral::Visitor::File.new('nested.txt', 50))
    root.add(GofPatterns::Behavioral::Visitor::File.new('root.txt', 100))
    root.add(sub)

    calculator = GofPatterns::Behavioral::Visitor::SizeCalculator.new

    assert_equal 150, root.accept(calculator)
  end

  def test_file_counter
    root = GofPatterns::Behavioral::Visitor::Directory.new('root')
    root.add(GofPatterns::Behavioral::Visitor::File.new('a.txt', 10))
    root.add(GofPatterns::Behavioral::Visitor::File.new('b.txt', 20))

    counter = GofPatterns::Behavioral::Visitor::FileCounter.new

    assert_equal 2, root.accept(counter)
  end

  def test_tree_printer
    root = GofPatterns::Behavioral::Visitor::Directory.new('project')
    root.add(GofPatterns::Behavioral::Visitor::File.new('readme.md', 100))

    printer = GofPatterns::Behavioral::Visitor::TreePrinter.new
    output = root.accept(printer)

    assert_match(/project/, output)
    assert_match(/readme\.md/, output)
  end

  def test_employee_visitor
    emp = GofPatterns::Behavioral::Visitor::Employee.new('Alice', 50_000)
    calculator = GofPatterns::Behavioral::Visitor::SalaryCalculator.new

    assert_equal 50_000, emp.accept(calculator)
  end

  def test_manager_visitor
    manager = GofPatterns::Behavioral::Visitor::Manager.new('Bob', 80_000)
    manager.add_member(GofPatterns::Behavioral::Visitor::Employee.new('Alice', 50_000))
    manager.add_member(GofPatterns::Behavioral::Visitor::Employee.new('Charlie', 60_000))

    calculator = GofPatterns::Behavioral::Visitor::SalaryCalculator.new
    total = manager.accept(calculator)

    assert_equal 190_000, total # 80000 + 50000 + 60000
  end

  def test_salary_raiser
    emp = GofPatterns::Behavioral::Visitor::Employee.new('Alice', 50_000)
    raiser = GofPatterns::Behavioral::Visitor::SalaryRaiser.new(10) # 10% raise

    result = emp.accept(raiser)

    assert_equal 'Alice', result[:name]
    assert_equal 50_000, result[:old_salary]
    assert_equal 5_000, result[:raise]
    assert_equal 55_000, result[:new_salary]
  end

  def test_manager_salary_raiser
    manager = GofPatterns::Behavioral::Visitor::Manager.new('Bob', 100_000)
    manager.add_member(GofPatterns::Behavioral::Visitor::Employee.new('Alice', 50_000))

    raiser = GofPatterns::Behavioral::Visitor::SalaryRaiser.new(10)
    result = manager.accept(raiser)

    # Manager gets 10% + 1000 per team member bonus
    assert_equal 'Bob', result[:name]
    assert_equal 11_000, result[:raise] # 10000 + 1000 bonus
    assert_equal 1, result[:team_raises].size
  end

  def test_org_chart_generator
    manager = GofPatterns::Behavioral::Visitor::Manager.new('CEO', 200_000)
    manager.add_member(GofPatterns::Behavioral::Visitor::Employee.new('Dev', 80_000))

    generator = GofPatterns::Behavioral::Visitor::OrgChartGenerator.new
    chart = manager.accept(generator)

    assert_match(/CEO/, chart)
    assert_match(/Dev/, chart)
  end

  def test_shape_collection
    collection = GofPatterns::Behavioral::Visitor::ShapeCollection.new
    collection.add(GofPatterns::Behavioral::Visitor::Circle.new(10))
    collection.add(GofPatterns::Behavioral::Visitor::Rectangle.new(20, 10))

    # 複数のvisitorを適用
    calculator = GofPatterns::Behavioral::Visitor::AreaCalculator.new
    areas = collection.accept(calculator)

    assert_equal 2, areas.size
  end

  def test_shape_collection_total_area
    collection = GofPatterns::Behavioral::Visitor::ShapeCollection.new
    collection.add(GofPatterns::Behavioral::Visitor::Rectangle.new(10, 10)) # 100
    collection.add(GofPatterns::Behavioral::Visitor::Rectangle.new(5, 5))   # 25

    assert_equal 125, collection.total_area
  end

  def test_shape_collection_render_svg
    collection = GofPatterns::Behavioral::Visitor::ShapeCollection.new
    collection.add(GofPatterns::Behavioral::Visitor::Circle.new(10))

    svg = collection.render_svg

    assert_match(/<svg/, svg)
    assert_match(/<circle/, svg)
  end
end
