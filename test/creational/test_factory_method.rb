# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/creational/factory_method/factory_method'

class TestFactoryMethod < GofPatternTest
  def test_pdf_document_creator
    creator = GofPatterns::Creational::FactoryMethod::PdfDocumentCreator.new
    doc = creator.create_document('Hello World')

    assert_instance_of GofPatterns::Creational::FactoryMethod::PdfDocument, doc
    assert_equal '[PDF] Hello World', doc.render
    assert_equal '.pdf', doc.extension
  end

  def test_html_document_creator
    creator = GofPatterns::Creational::FactoryMethod::HtmlDocumentCreator.new
    doc = creator.create_document('Hello World')

    assert_instance_of GofPatterns::Creational::FactoryMethod::HtmlDocument, doc
    assert_equal '<html><body>Hello World</body></html>', doc.render
    assert_equal '.html', doc.extension
  end

  def test_plain_text_document_creator
    creator = GofPatterns::Creational::FactoryMethod::PlainTextDocumentCreator.new
    doc = creator.create_document('Hello World')

    assert_instance_of GofPatterns::Creational::FactoryMethod::PlainTextDocument, doc
    assert_equal 'Hello World', doc.render
    assert_equal '.txt', doc.extension
  end

  def test_markdown_document_creator
    creator = GofPatterns::Creational::FactoryMethod::MarkdownDocumentCreator.new
    doc = creator.create_document('Hello World')

    assert_instance_of GofPatterns::Creational::FactoryMethod::MarkdownDocument, doc
    assert_equal "# Document\n\nHello World", doc.render
    assert_equal '.md', doc.extension
  end

  def test_document_ids_are_unique
    creator = GofPatterns::Creational::FactoryMethod::PdfDocumentCreator.new
    doc1 = creator.create_document('First')
    doc2 = creator.create_document('Second')

    refute_equal doc1.id, doc2.id
  end

  def test_document_content_is_value_object
    content1 = GofPatterns::Creational::FactoryMethod::DocumentContent.new('Test', :pdf)
    content2 = GofPatterns::Creational::FactoryMethod::DocumentContent.new('Test', :pdf)

    assert_equal content1, content2
    assert_equal content1.hash, content2.hash
    assert_predicate content1, :frozen?
  end

  def test_document_creator_registry
    registry = GofPatterns::Creational::FactoryMethod::DocumentCreatorRegistry

    assert_includes registry.supported_formats, :pdf
    assert_includes registry.supported_formats, :html
    assert_includes registry.supported_formats, :text
    assert_includes registry.supported_formats, :markdown
  end

  def test_registry_creates_correct_creator
    registry = GofPatterns::Creational::FactoryMethod::DocumentCreatorRegistry

    creator = registry.creator_for(:pdf)

    assert_instance_of GofPatterns::Creational::FactoryMethod::PdfDocumentCreator, creator
  end

  def test_registry_raises_for_unknown_format
    registry = GofPatterns::Creational::FactoryMethod::DocumentCreatorRegistry

    assert_raises(ArgumentError) do
      registry.creator_for(:unknown)
    end
  end

  def test_document_equality_by_id
    creator = GofPatterns::Creational::FactoryMethod::PdfDocumentCreator.new
    doc1 = creator.create_document('Test')
    doc2 = creator.create_document('Test')

    refute_equal doc1, doc2 # Different IDs
  end
end
