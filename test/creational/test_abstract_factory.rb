# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/creational/abstract_factory/abstract_factory'

class TestAbstractFactory < GofPatternTest
  def setup
    @light_factory = GofPatterns::Creational::AbstractFactory::LightThemeFactory.new
    @dark_factory = GofPatterns::Creational::AbstractFactory::DarkThemeFactory.new
  end

  def test_light_factory_creates_light_components
    button = @light_factory.create_button('Submit')
    checkbox = @light_factory.create_checkbox('Accept')
    text_field = @light_factory.create_text_field('Enter name')

    assert_instance_of GofPatterns::Creational::AbstractFactory::LightTheme::Button, button
    assert_instance_of GofPatterns::Creational::AbstractFactory::LightTheme::Checkbox, checkbox
    assert_instance_of GofPatterns::Creational::AbstractFactory::LightTheme::TextField, text_field
  end

  def test_dark_factory_creates_dark_components
    button = @dark_factory.create_button('Submit')
    checkbox = @dark_factory.create_checkbox('Accept')
    text_field = @dark_factory.create_text_field('Enter name')

    assert_instance_of GofPatterns::Creational::AbstractFactory::DarkTheme::Button, button
    assert_instance_of GofPatterns::Creational::AbstractFactory::DarkTheme::Checkbox, checkbox
    assert_instance_of GofPatterns::Creational::AbstractFactory::DarkTheme::TextField, text_field
  end

  def test_light_button_render
    button = @light_factory.create_button('Click Me')

    assert_equal '[Light Button: Click Me]', button.render
    assert_equal "Light button 'Click Me' clicked", button.click
  end

  def test_dark_button_render
    button = @dark_factory.create_button('Click Me')

    assert_equal '[[Dark Button: Click Me]]', button.render
    assert_equal "Dark button 'Click Me' clicked", button.click
  end

  def test_checkbox_toggle
    checkbox = @light_factory.create_checkbox('Option', checked: false)

    assert_equal false, checkbox.checked
    checkbox.toggle
    assert_equal true, checkbox.checked
    checkbox.toggle
    assert_equal false, checkbox.checked
  end

  def test_light_checkbox_render
    unchecked = @light_factory.create_checkbox('Option', checked: false)
    checked = @light_factory.create_checkbox('Option', checked: true)

    assert_equal 'Light [ ] Option', unchecked.render
    assert_equal 'Light [x] Option', checked.render
  end

  def test_dark_checkbox_render
    unchecked = @dark_factory.create_checkbox('Option', checked: false)
    checked = @dark_factory.create_checkbox('Option', checked: true)

    assert_equal 'Dark [-] Option', unchecked.render
    assert_equal 'Dark [*] Option', checked.render
  end

  def test_text_field_input
    text_field = @light_factory.create_text_field('Enter text')

    assert_equal '', text_field.value
    text_field.input('Hello')
    assert_equal 'Hello', text_field.value
    text_field.clear
    assert_equal '', text_field.value
  end

  def test_light_text_field_render
    text_field = @light_factory.create_text_field('Placeholder')
    assert_equal 'Light [Placeholder]', text_field.render

    text_field.input('Typed text')
    assert_equal 'Light [Typed text]', text_field.render
  end

  def test_dark_text_field_render
    text_field = @dark_factory.create_text_field('Placeholder')
    assert_equal 'Dark [[Placeholder]]', text_field.render

    text_field.input('Typed text')
    assert_equal 'Dark [[Typed text]]', text_field.render
  end

  def test_theme_manager
    manager = GofPatterns::Creational::AbstractFactory::ThemeManager

    assert_includes manager.available_themes, :light
    assert_includes manager.available_themes, :dark
  end

  def test_theme_manager_factory_for
    manager = GofPatterns::Creational::AbstractFactory::ThemeManager

    light = manager.factory_for(:light)
    dark = manager.factory_for(:dark)

    assert_instance_of GofPatterns::Creational::AbstractFactory::LightThemeFactory, light
    assert_instance_of GofPatterns::Creational::AbstractFactory::DarkThemeFactory, dark
  end

  def test_theme_manager_raises_for_unknown_theme
    manager = GofPatterns::Creational::AbstractFactory::ThemeManager

    assert_raises(ArgumentError) do
      manager.factory_for(:unknown)
    end
  end

  def test_ui_builder
    builder = GofPatterns::Creational::AbstractFactory::UIBuilder.new(@light_factory)
    components = builder
                 .add_button('Submit')
                 .add_checkbox('Accept', checked: true)
                 .add_text_field('Name')
                 .build

    assert_equal 3, components.size
    assert_instance_of GofPatterns::Creational::AbstractFactory::LightTheme::Button, components[0]
    assert_instance_of GofPatterns::Creational::AbstractFactory::LightTheme::Checkbox, components[1]
    assert_instance_of GofPatterns::Creational::AbstractFactory::LightTheme::TextField, components[2]
  end

  def test_color_value_object
    color1 = GofPatterns::Creational::AbstractFactory::Color.new(255, 128, 0)
    color2 = GofPatterns::Creational::AbstractFactory::Color.new(255, 128, 0)

    assert_equal color1, color2
    assert_equal '#FF8000', color1.to_hex
    assert color1.frozen?
  end

  def test_color_clamping
    color = GofPatterns::Creational::AbstractFactory::Color.new(300, -10, 128)

    assert_equal 255, color.r
    assert_equal 0, color.g
    assert_equal 128, color.b
  end
end
