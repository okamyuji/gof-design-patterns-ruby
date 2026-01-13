# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Template Method Pattern (テンプレートメソッドパターン)
    # ====================================================
    # 目的: アルゴリズムの骨格を定義し、
    #       一部のステップをサブクラスで実装させる
    #
    # DDD Context:
    # - Domain Service の共通処理フロー
    # - Repository の基本操作

    module TemplateMethod
      # Abstract Class: データマイナー
      class DataMiner
        # Template Method: アルゴリズムの骨格を定義
        def mine(path)
          file = open_file(path)
          raw_data = extract_data(file)
          data = parse_data(raw_data)
          analyzed = analyze_data(data)
          report = send_report(analyzed)
          close_file(file)
          report
        end

        protected

        # 抽象メソッド（サブクラスで実装必須）
        def open_file(_path)
          raise NotImplementedError
        end

        def extract_data(_file)
          raise NotImplementedError
        end

        def parse_data(_raw_data)
          raise NotImplementedError
        end

        # フックメソッド（オーバーライド可能、デフォルト実装あり）
        def analyze_data(data)
          data
        end

        def send_report(data)
          { status: :completed, data: data, timestamp: Time.now }
        end

        def close_file(_file)
          # デフォルトでは何もしない
        end
      end

      # Concrete Class: CSVデータマイナー
      class CsvDataMiner < DataMiner
        protected

        def open_file(path)
          { path: path, type: :csv, content: "header1,header2\nvalue1,value2\nvalue3,value4" }
        end

        def extract_data(file)
          file[:content]
        end

        def parse_data(raw_data)
          lines = raw_data.split("\n")
          headers = lines.first.split(',')
          lines[1..].map do |line|
            values = line.split(',')
            headers.zip(values).to_h
          end
        end

        def analyze_data(data)
          {
            records: data,
            count: data.size,
            columns: data.first&.keys || []
          }
        end
      end

      # Concrete Class: JSONデータマイナー
      class JsonDataMiner < DataMiner
        protected

        def open_file(path)
          { path: path, type: :json, content: '[{"name":"Alice","age":30},{"name":"Bob","age":25}]' }
        end

        def extract_data(file)
          file[:content]
        end

        def parse_data(raw_data)
          require 'json'
          JSON.parse(raw_data)
        end

        def analyze_data(data)
          {
            records: data,
            count: data.size,
            keys: data.first&.keys || []
          }
        end
      end

      # Concrete Class: XMLデータマイナー
      class XmlDataMiner < DataMiner
        protected

        def open_file(path)
          {
            path: path,
            type: :xml,
            content: '<users><user name="Alice" age="30"/><user name="Bob" age="25"/></users>'
          }
        end

        def extract_data(file)
          file[:content]
        end

        def parse_data(raw_data)
          # 簡易XMLパース
          raw_data.scan(/<user\s+name="([^"]+)"\s+age="(\d+)"/).map do |name, age|
            { 'name' => name, 'age' => age.to_i }
          end
        end

        def analyze_data(data)
          {
            records: data,
            count: data.size,
            format: :xml
          }
        end
      end

      # ===== ゲームAIの例 =====

      # Abstract Class: ゲームAI
      class GameAI
        # Template Method
        def take_turn
          collect_resources
          build_structures
          build_units
          attack if should_attack?
          defend if under_attack?
          end_turn
        end

        # Public accessor for testing
        def resources
          @resources || 0
        end

        protected

        def collect_resources
          # 基本実装
          @resources ||= 0
          @resources += 100
        end

        def build_structures
          raise NotImplementedError
        end

        def build_units
          raise NotImplementedError
        end

        # フックメソッド
        def should_attack?
          false
        end

        def under_attack?
          false
        end

        def attack
          # デフォルト: 何もしない
        end

        def defend
          # デフォルト: 何もしない
        end

        def end_turn
          { resources: @resources, turn_completed: true }
        end
      end

      # Concrete Class: 攻撃的AI
      class AggressiveAI < GameAI
        attr_reader :units, :structures

        def initialize
          @units = []
          @structures = []
          @resources = 0
        end

        protected

        def build_structures
          return unless @resources >= 50

          @structures << :barracks
          @resources -= 50
        end

        def build_units
          return unless @resources >= 30

          @units << :warrior
          @resources -= 30
        end

        def should_attack?
          @units.size >= 3
        end

        def attack
          @units.clear # 攻撃後にユニットを消費
        end
      end

      # Concrete Class: 防御的AI
      class DefensiveAI < GameAI
        attr_reader :units, :structures

        def initialize
          @units = []
          @structures = []
          @resources = 0
          @under_attack = false
        end

        def set_under_attack(value)
          @under_attack = value
        end

        protected

        def build_structures
          return unless @resources >= 80

          @structures << :tower
          @resources -= 80
        end

        def build_units
          return unless @resources >= 20

          @units << :defender
          @resources -= 20
        end

        def under_attack?
          @under_attack
        end

        def defend
          @structures << :wall if @resources >= 30
          @resources -= 30 if @resources >= 30
        end
      end

      # ===== ドキュメント生成の例 =====

      # Abstract Class: ドキュメントジェネレータ
      class DocumentGenerator
        # Template Method
        def generate(data)
          content = ''
          content += header(data)
          content += body(data)
          content += footer(data)
          post_process(content)
        end

        protected

        def header(_data)
          raise NotImplementedError
        end

        def body(_data)
          raise NotImplementedError
        end

        def footer(_data)
          ''
        end

        def post_process(content)
          content
        end
      end

      # Concrete Class: HTMLドキュメント生成
      class HtmlDocumentGenerator < DocumentGenerator
        protected

        def header(data)
          <<~HTML
            <!DOCTYPE html>
            <html>
            <head><title>#{data[:title]}</title></head>
            <body>
            <h1>#{data[:title]}</h1>
          HTML
        end

        def body(data)
          content = '<div class="content">'
          data[:sections].each do |section|
            content += "<h2>#{section[:heading]}</h2>"
            content += "<p>#{section[:content]}</p>"
          end
          content += '</div>'
          content
        end

        def footer(data)
          <<~HTML
            <footer>
            <p>Generated at #{Time.now}</p>
            <p>Author: #{data[:author]}</p>
            </footer>
            </body>
            </html>
          HTML
        end
      end

      # Concrete Class: Markdownドキュメント生成
      class MarkdownDocumentGenerator < DocumentGenerator
        protected

        def header(data)
          "# #{data[:title]}\n\n"
        end

        def body(data)
          content = ''
          data[:sections].each do |section|
            content += "## #{section[:heading]}\n\n"
            content += "#{section[:content]}\n\n"
          end
          content
        end

        def footer(data)
          "---\n*Generated at #{Time.now} by #{data[:author]}*\n"
        end
      end

      # Concrete Class: プレーンテキストドキュメント生成
      class PlainTextDocumentGenerator < DocumentGenerator
        protected

        def header(data)
          "#{data[:title]}\n#{'=' * data[:title].length}\n\n"
        end

        def body(data)
          content = ''
          data[:sections].each do |section|
            content += "#{section[:heading]}\n#{'-' * section[:heading].length}\n"
            content += "#{section[:content]}\n\n"
          end
          content
        end

        def footer(data)
          "Generated: #{Time.now}\nAuthor: #{data[:author]}\n"
        end

        def post_process(content)
          content.upcase # すべて大文字に変換
        end
      end

      # Domain Service: ドキュメント生成ファクトリ
      class DocumentGeneratorFactory
        GENERATORS = {
          html: HtmlDocumentGenerator,
          markdown: MarkdownDocumentGenerator,
          text: PlainTextDocumentGenerator
        }.freeze

        def self.create(format)
          generator_class = GENERATORS[format.to_sym]
          raise ArgumentError, "Unknown format: #{format}" unless generator_class

          generator_class.new
        end
      end
    end
  end
end
