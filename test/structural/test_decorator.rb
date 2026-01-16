# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/decorator/decorator'

class TestDecorator < GofPatternTest
  def test_espresso_base
    coffee = GofPatterns::Structural::Decorator::Espresso.new

    assert_equal 300, coffee.cost
    assert_equal 'エスプレッソ', coffee.description
  end

  def test_drip_coffee_base
    coffee = GofPatterns::Structural::Decorator::DripCoffee.new

    assert_equal 250, coffee.cost
    assert_equal 'ドリップコーヒー', coffee.description
  end

  def test_latte_base
    coffee = GofPatterns::Structural::Decorator::Latte.new

    assert_equal 400, coffee.cost
    assert_equal 'カフェラテ', coffee.description
  end

  def test_milk_decorator
    coffee = GofPatterns::Structural::Decorator::Espresso.new
    with_milk = GofPatterns::Structural::Decorator::MilkDecorator.new(coffee)

    assert_equal 350, with_milk.cost
    assert_equal 'エスプレッソ + ミルク', with_milk.description
  end

  def test_whip_cream_decorator
    coffee = GofPatterns::Structural::Decorator::Latte.new
    with_whip = GofPatterns::Structural::Decorator::WhipCreamDecorator.new(coffee)

    assert_equal 500, with_whip.cost
    assert_match(/ホイップ/, with_whip.description)
  end

  def test_caramel_decorator
    coffee = GofPatterns::Structural::Decorator::DripCoffee.new
    with_caramel = GofPatterns::Structural::Decorator::CaramelDecorator.new(coffee)

    assert_equal 330, with_caramel.cost
    assert_match(/キャラメル/, with_caramel.description)
  end

  def test_extra_shot_decorator
    coffee = GofPatterns::Structural::Decorator::Espresso.new
    with_shot = GofPatterns::Structural::Decorator::ExtraShotDecorator.new(coffee)

    assert_equal 400, with_shot.cost
    assert_match(/エスプレッソショット/, with_shot.description)
  end

  def test_size_up_decorator
    coffee = GofPatterns::Structural::Decorator::Latte.new
    grande = GofPatterns::Structural::Decorator::SizeUpDecorator.new(coffee, size: :grande)
    venti = GofPatterns::Structural::Decorator::SizeUpDecorator.new(coffee, size: :venti)

    assert_equal 450, grande.cost
    assert_equal 500, venti.cost
    assert_match(/grande/, grande.description)
  end

  def test_multiple_decorators
    coffee = GofPatterns::Structural::Decorator::Espresso.new
    decorated = GofPatterns::Structural::Decorator::MilkDecorator.new(coffee)
    decorated = GofPatterns::Structural::Decorator::WhipCreamDecorator.new(decorated)
    decorated = GofPatterns::Structural::Decorator::CaramelDecorator.new(decorated)

    # 300 + 50 + 100 + 80 = 530
    assert_equal 530, decorated.cost
    assert_match(/ミルク/, decorated.description)
    assert_match(/ホイップ/, decorated.description)
    assert_match(/キャラメル/, decorated.description)
  end

  def test_coffee_builder
    coffee = GofPatterns::Structural::Decorator::CoffeeBuilder.new(
      GofPatterns::Structural::Decorator::Latte.new
    )
                                                              .with_milk
                                                              .with_whip
                                                              .with_extra_shot
                                                              .size(:venti)
                                                              .build

    # 400 + 50 + 100 + 100 + 100 = 750
    assert_equal 750, coffee.cost
  end

  def test_text_content_basic
    content = GofPatterns::Structural::Decorator::TextContent.new('Hello World')

    assert_equal 'Hello World', content.render
  end

  def test_html_tag_decorator
    content = GofPatterns::Structural::Decorator::TextContent.new('Hello')
    decorated = GofPatterns::Structural::Decorator::HtmlTagDecorator.new(content, tag: 'h1')

    assert_equal '<h1>Hello</h1>', decorated.render
  end

  def test_uppercase_decorator
    content = GofPatterns::Structural::Decorator::TextContent.new('hello')
    decorated = GofPatterns::Structural::Decorator::UppercaseDecorator.new(content)

    assert_equal 'HELLO', decorated.render
  end

  def test_trim_decorator
    content = GofPatterns::Structural::Decorator::TextContent.new('  hello  ')
    decorated = GofPatterns::Structural::Decorator::TrimDecorator.new(content)

    assert_equal 'hello', decorated.render
  end

  def test_prefix_decorator
    content = GofPatterns::Structural::Decorator::TextContent.new('World')
    decorated = GofPatterns::Structural::Decorator::PrefixDecorator.new(content, prefix: 'Hello ')

    assert_equal 'Hello World', decorated.render
  end

  def test_suffix_decorator
    content = GofPatterns::Structural::Decorator::TextContent.new('Hello')
    decorated = GofPatterns::Structural::Decorator::SuffixDecorator.new(content, suffix: ' World')

    assert_equal 'Hello World', decorated.render
  end

  def test_combined_text_decorators
    content = GofPatterns::Structural::Decorator::TextContent.new('  hello  ')
    decorated = GofPatterns::Structural::Decorator::TrimDecorator.new(content)
    decorated = GofPatterns::Structural::Decorator::UppercaseDecorator.new(decorated)
    decorated = GofPatterns::Structural::Decorator::HtmlTagDecorator.new(decorated, tag: 'strong')

    assert_equal '<strong>HELLO</strong>', decorated.render
  end

  def test_file_data_source
    source = GofPatterns::Structural::Decorator::FileDataSource.new
    source.write('test data')

    assert_equal 'test data', source.read
  end

  def test_encryption_decorator
    source = GofPatterns::Structural::Decorator::FileDataSource.new
    encrypted = GofPatterns::Structural::Decorator::EncryptionDecorator.new(source, key: 3)

    encrypted.write('hello')
    raw_data = source.read

    refute_equal 'hello', raw_data
    assert_equal 'hello', encrypted.read
  end

  def test_compression_decorator
    source = GofPatterns::Structural::Decorator::FileDataSource.new
    compressed = GofPatterns::Structural::Decorator::CompressionDecorator.new(source)

    compressed.write('hello world')

    assert_equal 'hello world', compressed.read
  end

  def test_logging_decorator
    logs = []
    logger = ->(msg) { logs << msg }

    source = GofPatterns::Structural::Decorator::FileDataSource.new
    logged = GofPatterns::Structural::Decorator::LoggingDecorator.new(source, logger: logger)

    logged.write('test')
    logged.read

    assert(logs.any? { |l| l.include?('Writing') })
    assert(logs.any? { |l| l.include?('Reading') })
  end

  def test_combined_data_decorators
    source = GofPatterns::Structural::Decorator::FileDataSource.new
    encrypted = GofPatterns::Structural::Decorator::EncryptionDecorator.new(source)
    compressed = GofPatterns::Structural::Decorator::CompressionDecorator.new(encrypted)

    original = 'sensitive data'
    compressed.write(original)

    assert_equal original, compressed.read
  end
end
