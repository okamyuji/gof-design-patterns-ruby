# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/flyweight/flyweight'

class TestFlyweight < GofPatternTest
  def test_character_style_creation
    style = GofPatterns::Structural::Flyweight::CharacterStyle.new(
      font_family: 'Arial',
      font_size: 12,
      bold: true,
      italic: false,
      color: '#000000'
    )

    assert_equal 'Arial', style.font_family
    assert_equal 12, style.font_size
    assert style.bold
    refute style.italic
    assert_predicate style, :frozen?
  end

  def test_character_style_equality
    style1 = GofPatterns::Structural::Flyweight::CharacterStyle.new(
      font_family: 'Arial',
      font_size: 12
    )
    style2 = GofPatterns::Structural::Flyweight::CharacterStyle.new(
      font_family: 'Arial',
      font_size: 12
    )

    assert_equal style1, style2
    assert_equal style1.hash, style2.hash
  end

  def test_character_style_render
    style = GofPatterns::Structural::Flyweight::CharacterStyle.new(
      font_family: 'Times',
      font_size: 14,
      bold: true
    )

    rendered = style.render('A')

    assert_match(/Times/, rendered)
    assert_match(/14px/, rendered)
    assert_match(/bold/, rendered)
    assert_match(/A/, rendered)
  end

  def test_character_style_factory_sharing
    factory = GofPatterns::Structural::Flyweight::CharacterStyleFactory.new

    style1 = factory.get_style(font_family: 'Arial', font_size: 12)
    style2 = factory.get_style(font_family: 'Arial', font_size: 12)
    style3 = factory.get_style(font_family: 'Arial', font_size: 14)

    assert_same style1, style2
    refute_same style1, style3
    assert_equal 2, factory.styles_count
  end

  def test_character_creation
    factory = GofPatterns::Structural::Flyweight::CharacterStyleFactory.new
    style = factory.get_style(font_family: 'Arial', font_size: 12)

    char = GofPatterns::Structural::Flyweight::Character.new('X', position_x: 10, position_y: 20, style: style)

    assert_equal 'X', char.char
    assert_equal 10, char.position_x
    assert_equal 20, char.position_y
  end

  def test_character_move
    factory = GofPatterns::Structural::Flyweight::CharacterStyleFactory.new
    style = factory.get_style(font_family: 'Arial', font_size: 12)

    char = GofPatterns::Structural::Flyweight::Character.new('Y', position_x: 0, position_y: 0, style: style)
    char.move(5, 10)

    assert_equal 5, char.position_x
    assert_equal 10, char.position_y
  end

  def test_tree_type_flyweight
    type = GofPatterns::Structural::Flyweight::TreeType.new(
      name: 'Oak',
      color: 'Green',
      texture: 'Rough'
    )

    assert_equal 'Oak', type.name
    assert_predicate type, :frozen?
  end

  def test_tree_type_factory_sharing
    factory = GofPatterns::Structural::Flyweight::TreeTypeFactory.new

    type1 = factory.get_tree_type(name: 'Pine', color: 'Green', texture: 'Smooth')
    type2 = factory.get_tree_type(name: 'Pine', color: 'Green', texture: 'Smooth')
    type3 = factory.get_tree_type(name: 'Oak', color: 'Brown', texture: 'Rough')

    assert_same type1, type2
    refute_same type1, type3
    assert_equal 2, factory.types_count
  end

  def test_tree_with_type
    factory = GofPatterns::Structural::Flyweight::TreeTypeFactory.new
    type = factory.get_tree_type(name: 'Maple', color: 'Red', texture: 'Smooth')

    tree = GofPatterns::Structural::Flyweight::Tree.new(x: 100, y: 200, type: type)

    assert_equal 100, tree.x
    assert_equal 200, tree.y
    assert_match(/Maple/, tree.draw)
  end

  def test_icon_creation
    icon = GofPatterns::Structural::Flyweight::Icon.new(name: 'folder', width: 32, height: 32)

    assert_equal 'folder', icon.name
    assert_equal 32, icon.width
    assert_predicate icon, :frozen?
  end

  def test_icon_cache_sharing
    cache = GofPatterns::Structural::Flyweight::IconCache.new

    icon1 = cache.get_icon('file', width: 16, height: 16)
    icon2 = cache.get_icon('file', width: 16, height: 16)
    icon3 = cache.get_icon('file', width: 32, height: 32)

    assert_same icon1, icon2
    refute_same icon1, icon3
    assert_equal 2, cache.cached_count
  end

  def test_icon_cache_preload
    cache = GofPatterns::Structural::Flyweight::IconCache.new
    cache.preload(%w[folder file document])

    assert_equal 3, cache.cached_count
  end

  def test_text_editor
    editor = GofPatterns::Structural::Flyweight::TextEditor.new
    editor.add_text('Hello', start_x: 0, start_y: 0, font_family: 'Arial', font_size: 12)
    editor.add_text('World', start_x: 0, start_y: 20, font_family: 'Arial', font_size: 12, bold: true)

    assert_equal 10, editor.character_count
    assert_equal 2, editor.unique_styles_count
  end

  def test_text_editor_memory_stats
    editor = GofPatterns::Structural::Flyweight::TextEditor.new

    # 同じスタイルで大量の文字を追加
    100.times do |i|
      editor.add_character('A', x: i, y: 0, font_family: 'Arial', font_size: 12)
    end

    stats = editor.memory_stats

    assert_equal 100, stats[:total_characters]
    assert_equal 1, stats[:unique_styles]
    assert_operator stats[:memory_saved_ratio], :>, 0.9
  end

  def test_forest_simulation
    forest = GofPatterns::Structural::Flyweight::Forest.new

    # 多数の木を植える
    50.times do |i|
      forest.plant_tree(x: i * 10, y: 0, name: 'Pine', color: 'Green', texture: 'Rough')
      forest.plant_tree(x: i * 10, y: 50, name: 'Oak', color: 'Brown', texture: 'Rough')
    end

    assert_equal 100, forest.trees_count
    assert_equal 2, forest.types_count
  end

  def test_forest_memory_report
    forest = GofPatterns::Structural::Flyweight::Forest.new

    100.times do
      forest.plant_tree(x: rand(1000), y: rand(1000), name: 'Tree', color: 'Green', texture: 'Normal')
    end

    report = forest.memory_report

    assert_equal 1, report[:types_count]
    assert_equal 100, report[:total_trees]
    assert_predicate report[:bytes_saved], :positive?
  end

  def test_factory_clear
    factory = GofPatterns::Structural::Flyweight::CharacterStyleFactory.new
    factory.get_style(font_family: 'Arial', font_size: 12)
    factory.get_style(font_family: 'Times', font_size: 14)

    assert_equal 2, factory.styles_count

    factory.clear

    assert_equal 0, factory.styles_count
  end
end
