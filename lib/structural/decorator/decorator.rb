# frozen_string_literal: true

require 'delegate'

module GofPatterns
  module Structural
    # Decorator Pattern (デコレータパターン)
    # ====================================
    # 目的: オブジェクトに動的に新しい責務を追加する
    #
    # DDD Context:
    # - Entity の振る舞い拡張
    # - クロスカッティング関心事（ログ、キャッシュ）の追加

    module Decorator
      # Component Interface: コーヒー
      class Coffee
        def cost
          raise NotImplementedError
        end

        def description
          raise NotImplementedError
        end

        def to_s
          "#{description}: ¥#{cost}"
        end
      end

      # Concrete Component: エスプレッソ
      class Espresso < Coffee
        def cost
          300
        end

        def description
          'エスプレッソ'
        end
      end

      # Concrete Component: ドリップコーヒー
      class DripCoffee < Coffee
        def cost
          250
        end

        def description
          'ドリップコーヒー'
        end
      end

      # Concrete Component: カフェラテ
      class Latte < Coffee
        def cost
          400
        end

        def description
          'カフェラテ'
        end
      end

      # Decorator Base: コーヒーデコレータ
      class CoffeeDecorator < Coffee
        def initialize(coffee)
          @coffee = coffee
        end

        def cost
          @coffee.cost
        end

        def description
          @coffee.description
        end

        protected

        attr_reader :coffee
      end

      # Concrete Decorator: ミルク追加
      class MilkDecorator < CoffeeDecorator
        def cost
          super + 50
        end

        def description
          "#{super} + ミルク"
        end
      end

      # Concrete Decorator: ホイップクリーム追加
      class WhipCreamDecorator < CoffeeDecorator
        def cost
          super + 100
        end

        def description
          "#{super} + ホイップ"
        end
      end

      # Concrete Decorator: キャラメルソース追加
      class CaramelDecorator < CoffeeDecorator
        def cost
          super + 80
        end

        def description
          "#{super} + キャラメル"
        end
      end

      # Concrete Decorator: エスプレッソショット追加
      class ExtraShotDecorator < CoffeeDecorator
        def cost
          super + 100
        end

        def description
          "#{super} + エスプレッソショット"
        end
      end

      # Concrete Decorator: サイズアップ
      class SizeUpDecorator < CoffeeDecorator
        SIZES = { tall: 0, grande: 50, venti: 100 }.freeze

        def initialize(coffee, size: :grande)
          super(coffee)
          @size = size
        end

        def cost
          super + SIZES.fetch(@size, 0)
        end

        def description
          "#{super} (#{@size})"
        end
      end

      # ===== SimpleDelegator を使用した実装 =====

      # Entity: テキストコンテンツ
      class TextContent
        attr_reader :text

        def initialize(text)
          @text = text
        end

        def render
          text
        end
      end

      # Decorator: テキストデコレータ（SimpleDelegator使用）
      class TextDecorator < SimpleDelegator
        def render
          __getobj__.render
        end
      end

      # Concrete Decorator: HTMLタグ追加
      class HtmlTagDecorator < TextDecorator
        def initialize(content, tag: 'p')
          super(content)
          @tag = tag
        end

        def render
          "<#{@tag}>#{super}</#{@tag}>"
        end
      end

      # Concrete Decorator: 大文字変換
      class UppercaseDecorator < TextDecorator
        def render
          super.upcase
        end
      end

      # Concrete Decorator: 空白トリム
      class TrimDecorator < TextDecorator
        def render
          super.strip
        end
      end

      # Concrete Decorator: プレフィックス追加
      class PrefixDecorator < TextDecorator
        def initialize(content, prefix:)
          super(content)
          @prefix = prefix
        end

        def render
          "#{@prefix}#{super}"
        end
      end

      # Concrete Decorator: サフィックス追加
      class SuffixDecorator < TextDecorator
        def initialize(content, suffix:)
          super(content)
          @suffix = suffix
        end

        def render
          "#{super}#{@suffix}"
        end
      end

      # ===== Domain Service 例 =====

      # Entity: データソース
      class DataSource
        def write(data)
          raise NotImplementedError
        end

        def read
          raise NotImplementedError
        end
      end

      # Concrete Component: ファイルデータソース
      class FileDataSource < DataSource
        def initialize
          @data = ''
        end

        def write(data)
          @data = data
        end

        def read
          @data
        end
      end

      # Decorator Base: データソースデコレータ
      class DataSourceDecorator < DataSource
        def initialize(source)
          @source = source
        end

        def write(data)
          @source.write(data)
        end

        def read
          @source.read
        end
      end

      # Concrete Decorator: 暗号化デコレータ（簡易実装）
      class EncryptionDecorator < DataSourceDecorator
        def initialize(source, key: 3)
          super(source)
          @key = key
        end

        def write(data)
          encrypted = data.chars.map { |c| (c.ord + @key).chr }.join
          @source.write(encrypted)
        end

        def read
          encrypted = @source.read
          encrypted.chars.map { |c| (c.ord - @key).chr }.join
        end
      end

      # Concrete Decorator: 圧縮デコレータ（簡易実装）
      class CompressionDecorator < DataSourceDecorator
        def write(data)
          # 簡易圧縮：Base64エンコード
          compressed = [data].pack('m0')
          @source.write(compressed)
        end

        def read
          compressed = @source.read
          compressed.unpack1('m0')
        end
      end

      # Concrete Decorator: ログデコレータ
      class LoggingDecorator < DataSourceDecorator
        def initialize(source, logger: nil)
          super(source)
          @logger = logger || ->(msg) { puts "[LOG] #{msg}" }
        end

        def write(data)
          @logger.call("Writing #{data.bytesize} bytes")
          result = @source.write(data)
          @logger.call('Write complete')
          result
        end

        def read
          @logger.call('Reading data')
          data = @source.read
          @logger.call("Read #{data.bytesize} bytes")
          data
        end
      end

      # Domain Service: コーヒービルダー
      class CoffeeBuilder
        def initialize(base_coffee)
          @coffee = base_coffee
        end

        def with_milk
          @coffee = MilkDecorator.new(@coffee)
          self
        end

        def with_whip
          @coffee = WhipCreamDecorator.new(@coffee)
          self
        end

        def with_caramel
          @coffee = CaramelDecorator.new(@coffee)
          self
        end

        def with_extra_shot
          @coffee = ExtraShotDecorator.new(@coffee)
          self
        end

        def size(size_name)
          @coffee = SizeUpDecorator.new(@coffee, size: size_name)
          self
        end

        def build
          @coffee
        end
      end
    end
  end
end
