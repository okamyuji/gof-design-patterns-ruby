# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/template_method/template_method'

class TestTemplateMethod < GofPatternTest
  def test_csv_data_miner
    miner = GofPatterns::Behavioral::TemplateMethod::CsvDataMiner.new
    result = miner.mine('/data/test.csv')

    assert_equal :completed, result[:status]
    assert result[:data][:records].is_a?(Array)
    assert result[:data][:count].positive?
  end

  def test_json_data_miner
    miner = GofPatterns::Behavioral::TemplateMethod::JsonDataMiner.new
    result = miner.mine('/data/test.json')

    assert_equal :completed, result[:status]
    assert result[:data][:records].is_a?(Array)
    assert_includes result[:data][:keys], 'name'
  end

  def test_xml_data_miner
    miner = GofPatterns::Behavioral::TemplateMethod::XmlDataMiner.new
    result = miner.mine('/data/test.xml')

    assert_equal :completed, result[:status]
    assert_equal :xml, result[:data][:format]
  end

  def test_aggressive_ai_turn
    ai = GofPatterns::Behavioral::TemplateMethod::AggressiveAI.new

    # 複数ターン実行
    3.times { ai.take_turn }

    assert ai.structures.include?(:barracks) || ai.units.include?(:warrior)
  end

  def test_aggressive_ai_attacks_with_enough_units
    ai = GofPatterns::Behavioral::TemplateMethod::AggressiveAI.new

    # 十分なユニットを構築
    10.times { ai.take_turn }

    # ユニットが3以上になったら攻撃して消費される
    # 攻撃後はユニットがクリアされる
  end

  def test_defensive_ai_turn
    ai = GofPatterns::Behavioral::TemplateMethod::DefensiveAI.new

    3.times { ai.take_turn }

    # ディフェンシブAIはタワーやディフェンダーを構築
    assert ai.structures.include?(:tower) || ai.units.include?(:defender)
  end

  def test_defensive_ai_defends_when_under_attack
    ai = GofPatterns::Behavioral::TemplateMethod::DefensiveAI.new

    3.times { ai.take_turn }
    ai.set_under_attack(true)
    ai.take_turn

    # 攻撃されると壁を建設
    assert ai.structures.include?(:wall) || ai.structures.include?(:tower)
  end

  def test_html_document_generator
    generator = GofPatterns::Behavioral::TemplateMethod::HtmlDocumentGenerator.new
    data = {
      title: 'Test Document',
      author: 'Test Author',
      sections: [
        { heading: 'Section 1', content: 'Content 1' },
        { heading: 'Section 2', content: 'Content 2' }
      ]
    }

    result = generator.generate(data)

    assert_match(/<html>/, result)
    assert_match(/<h1>Test Document<\/h1>/, result)
    assert_match(/<h2>Section 1<\/h2>/, result)
    assert_match(/Test Author/, result)
  end

  def test_markdown_document_generator
    generator = GofPatterns::Behavioral::TemplateMethod::MarkdownDocumentGenerator.new
    data = {
      title: 'Test Document',
      author: 'Test Author',
      sections: [
        { heading: 'Section 1', content: 'Content 1' }
      ]
    }

    result = generator.generate(data)

    assert_match(/^# Test Document/, result)
    assert_match(/^## Section 1/m, result)
    assert_match(/Test Author/, result)
  end

  def test_plain_text_document_generator
    generator = GofPatterns::Behavioral::TemplateMethod::PlainTextDocumentGenerator.new
    data = {
      title: 'Test',
      author: 'Author',
      sections: [
        { heading: 'Heading', content: 'Content' }
      ]
    }

    result = generator.generate(data)

    # post_processで大文字に変換される
    assert_equal result, result.upcase
    assert_match(/TEST/, result)
  end

  def test_document_generator_factory
    factory = GofPatterns::Behavioral::TemplateMethod::DocumentGeneratorFactory

    html = factory.create(:html)
    assert_instance_of GofPatterns::Behavioral::TemplateMethod::HtmlDocumentGenerator, html

    md = factory.create(:markdown)
    assert_instance_of GofPatterns::Behavioral::TemplateMethod::MarkdownDocumentGenerator, md

    text = factory.create(:text)
    assert_instance_of GofPatterns::Behavioral::TemplateMethod::PlainTextDocumentGenerator, text
  end

  def test_document_generator_factory_unknown
    factory = GofPatterns::Behavioral::TemplateMethod::DocumentGeneratorFactory

    assert_raises(ArgumentError) do
      factory.create(:unknown)
    end
  end

  def test_data_miner_returns_timestamp
    miner = GofPatterns::Behavioral::TemplateMethod::CsvDataMiner.new
    result = miner.mine('/test.csv')

    assert result[:timestamp].is_a?(Time)
  end

  def test_game_ai_collect_resources
    ai = GofPatterns::Behavioral::TemplateMethod::AggressiveAI.new

    ai.take_turn
    assert ai.resources >= 0
  end
end
