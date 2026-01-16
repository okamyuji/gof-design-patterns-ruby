# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/creational/prototype/prototype'

class TestPrototype < GofPatternTest
  def test_point_clone_deep
    original = GofPatterns::Creational::Prototype::Point.new(10, 20)
    cloned = original.clone_deep

    assert_equal original.x, cloned.x
    assert_equal original.y, cloned.y
    refute_same original, cloned
  end

  def test_point_is_value_object
    p1 = GofPatterns::Creational::Prototype::Point.new(5, 5)
    p2 = GofPatterns::Creational::Prototype::Point.new(5, 5)

    assert_equal p1, p2
    assert_predicate p1, :frozen?
  end

  def test_point_move_returns_new_point
    original = GofPatterns::Creational::Prototype::Point.new(0, 0)
    moved = original.move(10, 20)

    assert_equal 0, original.x
    assert_equal 0, original.y
    assert_equal 10, moved.x
    assert_equal 20, moved.y
  end

  def test_color_clone_deep
    original = GofPatterns::Creational::Prototype::Color.new(128, 64, 32)
    cloned = original.clone_deep

    assert_equal original.r, cloned.r
    assert_equal original.g, cloned.g
    assert_equal original.b, cloned.b
    refute_same original, cloned
  end

  def test_color_with_alpha
    color = GofPatterns::Creational::Prototype::Color.new(255, 0, 0)
    transparent = color.with_alpha(128)

    assert_equal 255, color.a
    assert_equal 128, transparent.a
    assert_equal color.r, transparent.r
  end

  def test_rectangle_clone_deep
    original = GofPatterns::Creational::Prototype::Rectangle.new(width: 100, height: 50)
    original.name = 'Original Rect'
    original.move_to(10, 20)
    original.color = GofPatterns::Creational::Prototype::Color::RED

    cloned = original.clone_deep

    assert_equal 100, cloned.width
    assert_equal 50, cloned.height
    assert_equal 10, cloned.position.x
    assert_equal 20, cloned.position.y
    assert_equal 'Original Rect (copy)', cloned.name
    refute_equal original.id, cloned.id
  end

  def test_circle_clone_deep
    original = GofPatterns::Creational::Prototype::Circle.new(radius: 25)
    original.name = 'Original Circle'

    cloned = original.clone_deep

    assert_equal 25, cloned.radius
    assert_equal 'Original Circle (copy)', cloned.name
    refute_equal original.id, cloned.id
  end

  def test_rectangle_area
    rect = GofPatterns::Creational::Prototype::Rectangle.new(width: 10, height: 5)

    assert_equal 50, rect.area
  end

  def test_circle_area
    circle = GofPatterns::Creational::Prototype::Circle.new(radius: 10)
    expected = Math::PI * 100

    assert_in_delta expected, circle.area, 0.001
  end

  def test_composite_shape_clone_deep
    composite = GofPatterns::Creational::Prototype::CompositeShape.new
    composite.name = 'Group'
    composite.add(GofPatterns::Creational::Prototype::Rectangle.new(width: 20, height: 10))
    composite.add(GofPatterns::Creational::Prototype::Circle.new(radius: 5))

    cloned = composite.clone_deep

    assert_equal 2, cloned.children.size
    assert_equal 'Group (copy)', cloned.name
    refute_same composite.children[0], cloned.children[0]
    refute_same composite.children[1], cloned.children[1]
  end

  def test_composite_shape_area
    composite = GofPatterns::Creational::Prototype::CompositeShape.new
    composite.add(GofPatterns::Creational::Prototype::Rectangle.new(width: 10, height: 10))
    composite.add(GofPatterns::Creational::Prototype::Rectangle.new(width: 5, height: 5))

    assert_equal 125, composite.area
  end

  def test_prototype_registry
    registry = GofPatterns::Creational::Prototype::PrototypeRegistry.new
    template = GofPatterns::Creational::Prototype::Rectangle.new(width: 100, height: 50)
    template.name = 'Template'

    registry.register(:my_rect, template)
    created = registry.create(:my_rect)

    assert_equal 100, created.width
    assert_equal 50, created.height
    refute_equal template.id, created.id
  end

  def test_registry_list_keys
    registry = GofPatterns::Creational::Prototype::PrototypeRegistry.new
    registry.register(:rect, GofPatterns::Creational::Prototype::Rectangle.new)
    registry.register(:circle, GofPatterns::Creational::Prototype::Circle.new)

    keys = registry.list_keys

    assert_includes keys, :rect
    assert_includes keys, :circle
  end

  def test_registry_unregister
    registry = GofPatterns::Creational::Prototype::PrototypeRegistry.new
    registry.register(:rect, GofPatterns::Creational::Prototype::Rectangle.new)
    registry.unregister(:rect)

    assert_raises(KeyError) do
      registry.create(:rect)
    end
  end

  def test_registry_raises_for_non_cloneable
    registry = GofPatterns::Creational::Prototype::PrototypeRegistry.new

    assert_raises(ArgumentError) do
      registry.register(:invalid, 'not cloneable')
    end
  end

  def test_shape_factory
    factory = GofPatterns::Creational::Prototype::ShapeFactory.new

    rect = factory.create_rectangle(name: 'Custom Rect', width: 200, height: 100, x: 50, y: 50)
    circle = factory.create_circle(name: 'Custom Circle', radius: 30, x: 100, y: 100)

    assert_equal 200, rect.width
    assert_equal 100, rect.height
    assert_equal 50, rect.position.x
    assert_equal 'Custom Rect', rect.name

    assert_equal 30, circle.radius
    assert_equal 100, circle.position.x
    assert_equal 'Custom Circle', circle.name
  end

  def test_shape_factory_custom_template
    factory = GofPatterns::Creational::Prototype::ShapeFactory.new

    custom_rect = GofPatterns::Creational::Prototype::Rectangle.new(width: 500, height: 300)
    custom_rect.name = 'Large Template'
    custom_rect.color = GofPatterns::Creational::Prototype::Color::BLUE

    factory.register_template(:large_rect, custom_rect)
    created = factory.create_from_template(:large_rect, name: 'From Template')

    assert_equal 500, created.width
    assert_equal 300, created.height
    assert_equal 'From Template', created.name
  end

  def test_shape_draw
    rect = GofPatterns::Creational::Prototype::Rectangle.new(width: 10, height: 5)
    rect.name = 'Test Rect'
    rect.move_to(1, 2)

    assert_match(/Rectangle\[Test Rect\]/, rect.draw)
    assert_match(/\(1, 2\)/, rect.draw)
    assert_match(/10x5/, rect.draw)
  end
end
