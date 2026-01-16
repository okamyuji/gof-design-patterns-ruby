#!/usr/bin/env ruby
# frozen_string_literal: true

# Factory Method Pattern Example
# ===============================
# ファクトリメソッドパターン: オブジェクト生成のインターフェースを定義し、
#                             サブクラスでインスタンス化するクラスを決定させる
#
# Usage: ruby examples/creational/factory_method_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

FactoryMethod = GofPatterns::Creational::FactoryMethod

puts '=' * 60
puts 'Factory Method Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Creating Documents with Different Formats
# ========================================
puts '--- Example 1: Document Creation ---'
puts

pdf_creator = FactoryMethod::PdfDocumentCreator.new
html_creator = FactoryMethod::HtmlDocumentCreator.new
text_creator = FactoryMethod::PlainTextDocumentCreator.new
markdown_creator = FactoryMethod::MarkdownDocumentCreator.new

pdf_doc = pdf_creator.create_document('This is a PDF document')
html_doc = html_creator.create_document('This is an HTML document')
text_doc = text_creator.create_document('This is a plain text document')
markdown_doc = markdown_creator.create_document('This is a Markdown document')

puts 'PDF Document:'
puts "  ID: #{pdf_doc.id}"
puts "  Extension: #{pdf_doc.extension}"
puts "  Rendered: #{pdf_doc.render}"
puts

puts 'HTML Document:'
puts "  ID: #{html_doc.id}"
puts "  Extension: #{html_doc.extension}"
puts "  Rendered: #{html_doc.render}"
puts

puts 'Plain Text Document:'
puts "  ID: #{text_doc.id}"
puts "  Extension: #{text_doc.extension}"
puts "  Rendered: #{text_doc.render}"
puts

puts 'Markdown Document:'
puts "  ID: #{markdown_doc.id}"
puts "  Extension: #{markdown_doc.extension}"
puts "  Rendered: #{markdown_doc.render}"

puts

# ========================================
# Example 2: Using Document Creator Registry
# ========================================
puts '--- Example 2: Document Creator Registry ---'
puts

puts "Supported formats: #{FactoryMethod::DocumentCreatorRegistry.supported_formats.join(', ')}"
puts

# Create documents using registry
formats = %i[pdf html text markdown]
documents = formats.map do |format|
  creator = FactoryMethod::DocumentCreatorRegistry.creator_for(format)
  creator.create_document("Sample #{format.upcase} content")
end

documents.each do |doc|
  puts "Created #{doc.class.name.split('::').last}: #{doc.id}"
end

puts

# ========================================
# Example 3: Batch Document Processing
# ========================================
puts '--- Example 3: Batch Document Processing ---'
puts

creator = FactoryMethod::HtmlDocumentCreator.new

contents = [
  'First document content',
  'Second document content',
  'Third document content'
]

batch_docs = contents.map { |content| creator.create_document(content) }

puts "Created #{batch_docs.size} HTML documents:"
batch_docs.each do |doc|
  puts "  #{doc.id}: #{doc.content.text[0..30]}..."
end

puts

# ========================================
# Example 4: Error Handling
# ========================================
puts '--- Example 4: Error Handling ---'
puts

begin
  FactoryMethod::DocumentCreatorRegistry.creator_for(:unknown_format)
rescue ArgumentError => e
  puts "Error caught: #{e.message}"
end

puts
puts '=' * 60
puts 'End of Factory Method Pattern Demo'
puts '=' * 60
