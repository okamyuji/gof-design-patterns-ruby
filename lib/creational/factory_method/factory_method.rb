# frozen_string_literal: true

module GofPatterns
  module Creational
    # Factory Method Pattern (ファクトリメソッドパターン)
    # ================================================
    # 目的: オブジェクト生成のインターフェースを定義し、
    #       サブクラスでインスタンス化するクラスを決定させる
    #
    # DDD Context:
    # - Entity の生成ロジックをカプセル化
    # - Repository の具象実装選択に適用

    module FactoryMethod
      # Value Object: ドキュメントの内容
      class DocumentContent
        attr_reader :text, :format

        def initialize(text, format)
          @text = text.freeze
          @format = format.to_sym
          freeze
        end

        def ==(other)
          return false unless other.is_a?(DocumentContent)

          text == other.text && format == other.format
        end
        alias eql? ==

        def hash
          [text, format].hash
        end
      end

      # Entity: ドキュメント基底クラス（抽象）
      class Document
        attr_reader :id, :content, :created_at

        def initialize(id, content)
          @id = id
          @content = content
          @created_at = Time.now
        end

        def render
          raise NotImplementedError, "#{self.class} must implement #render"
        end

        def extension
          raise NotImplementedError, "#{self.class} must implement #extension"
        end

        def ==(other)
          return false unless other.is_a?(Document)

          id == other.id
        end
        alias eql? ==

        def hash
          id.hash
        end
      end

      # Entity: PDFドキュメント
      class PdfDocument < Document
        def render
          "[PDF] #{content.text}"
        end

        def extension
          '.pdf'
        end
      end

      # Entity: HTMLドキュメント
      class HtmlDocument < Document
        def render
          "<html><body>#{content.text}</body></html>"
        end

        def extension
          '.html'
        end
      end

      # Entity: プレーンテキストドキュメント
      class PlainTextDocument < Document
        def render
          content.text
        end

        def extension
          '.txt'
        end
      end

      # Entity: Markdownドキュメント
      class MarkdownDocument < Document
        def render
          "# Document\n\n#{content.text}"
        end

        def extension
          '.md'
        end
      end

      # Domain Service: ドキュメント生成ファクトリ（抽象）
      class DocumentCreator
        def initialize
          @next_id = 0
          @mutex = Mutex.new
        end

        # Factory Method - サブクラスでオーバーライド
        def create_document(text)
          id = generate_id
          content = DocumentContent.new(text, document_format)
          build_document(id, content)
        end

        protected

        # Hook method for document format
        def document_format
          raise NotImplementedError, "#{self.class} must implement #document_format"
        end

        # Factory method - サブクラスで実装
        def build_document(_id, _content)
          raise NotImplementedError, "#{self.class} must implement #build_document"
        end

        private

        def generate_id
          @mutex.synchronize do
            @next_id += 1
            "DOC-#{@next_id.to_s.rjust(6, '0')}"
          end
        end
      end

      # Concrete Creator: PDFドキュメントクリエイター
      class PdfDocumentCreator < DocumentCreator
        protected

        def document_format
          :pdf
        end

        def build_document(id, content)
          PdfDocument.new(id, content)
        end
      end

      # Concrete Creator: HTMLドキュメントクリエイター
      class HtmlDocumentCreator < DocumentCreator
        protected

        def document_format
          :html
        end

        def build_document(id, content)
          HtmlDocument.new(id, content)
        end
      end

      # Concrete Creator: プレーンテキストドキュメントクリエイター
      class PlainTextDocumentCreator < DocumentCreator
        protected

        def document_format
          :text
        end

        def build_document(id, content)
          PlainTextDocument.new(id, content)
        end
      end

      # Concrete Creator: Markdownドキュメントクリエイター
      class MarkdownDocumentCreator < DocumentCreator
        protected

        def document_format
          :markdown
        end

        def build_document(id, content)
          MarkdownDocument.new(id, content)
        end
      end

      # Domain Service: ファクトリ選択サービス
      class DocumentCreatorRegistry
        CREATORS = {
          pdf: PdfDocumentCreator,
          html: HtmlDocumentCreator,
          text: PlainTextDocumentCreator,
          markdown: MarkdownDocumentCreator
        }.freeze

        def self.creator_for(format)
          creator_class = CREATORS[format.to_sym]
          raise ArgumentError, "Unknown document format: #{format}" unless creator_class

          creator_class.new
        end

        def self.supported_formats
          CREATORS.keys
        end
      end
    end
  end
end
