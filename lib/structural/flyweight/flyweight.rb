# frozen_string_literal: true

module GofPatterns
  module Structural
    # Flyweight Pattern (フライウェイトパターン)
    # ========================================
    # 目的: 多数のオブジェクト間で共通の状態を共有し、メモリ使用量を削減する
    #
    # DDD Context:
    # - Value Object の共有インスタンス
    # - 大量のエンティティの効率的な管理

    module Flyweight
      # Flyweight Interface: 文字フォント
      class CharacterStyle
        attr_reader :font_family, :font_size, :bold, :italic, :color

        def initialize(font_family:, font_size:, bold: false, italic: false, color: '#000000')
          @font_family = font_family.freeze
          @font_size = font_size
          @bold = bold
          @italic = italic
          @color = color.freeze
          freeze
        end

        def render(character)
          style_desc = []
          style_desc << 'bold' if bold
          style_desc << 'italic' if italic
          style_str = style_desc.empty? ? '' : " (#{style_desc.join(', ')})"
          "[#{font_family} #{font_size}px#{style_str}] #{character}"
        end

        def ==(other)
          return false unless other.is_a?(CharacterStyle)

          font_family == other.font_family &&
            font_size == other.font_size &&
            bold == other.bold &&
            italic == other.italic &&
            color == other.color
        end
        alias eql? ==

        def hash
          [font_family, font_size, bold, italic, color].hash
        end

        def key
          "#{font_family}_#{font_size}_#{bold}_#{italic}_#{color}"
        end
      end

      # Flyweight Factory: スタイルファクトリ
      class CharacterStyleFactory
        def initialize
          @styles = {}
          @mutex = Mutex.new
        end

        def get_style(font_family:, font_size:, bold: false, italic: false, color: '#000000')
          key = "#{font_family}_#{font_size}_#{bold}_#{italic}_#{color}"

          @mutex.synchronize do
            @styles[key] ||= CharacterStyle.new(
              font_family: font_family,
              font_size: font_size,
              bold: bold,
              italic: italic,
              color: color
            )
          end
        end

        def styles_count
          @mutex.synchronize { @styles.size }
        end

        def clear
          @mutex.synchronize { @styles.clear }
        end
      end

      # Context: 文字（外部状態を持つ）
      class Character
        attr_reader :char, :position_x, :position_y
        attr_accessor :style

        def initialize(char, position_x:, position_y:, style:)
          @char = char
          @position_x = position_x
          @position_y = position_y
          @style = style
        end

        def render
          "#{style.render(char)} at (#{position_x}, #{position_y})"
        end

        def move(dx, dy)
          @position_x += dx
          @position_y += dy
        end
      end

      # ===== ゲームの木のタイプ例 =====

      # Flyweight: 木のタイプ（共有される内部状態）
      class TreeType
        attr_reader :name, :color, :texture

        def initialize(name:, color:, texture:)
          @name = name.freeze
          @color = color.freeze
          @texture = texture.freeze
          freeze
        end

        def draw(x, y)
          "Drawing #{name} tree (#{color}, #{texture}) at (#{x}, #{y})"
        end

        def ==(other)
          return false unless other.is_a?(TreeType)

          name == other.name && color == other.color && texture == other.texture
        end
        alias eql? ==

        def hash
          [name, color, texture].hash
        end
      end

      # Flyweight Factory: 木タイプファクトリ
      class TreeTypeFactory
        def initialize
          @tree_types = {}
          @mutex = Mutex.new
        end

        def get_tree_type(name:, color:, texture:)
          key = "#{name}_#{color}_#{texture}"

          @mutex.synchronize do
            @tree_types[key] ||= TreeType.new(name: name, color: color, texture: texture)
          end
        end

        def types_count
          @mutex.synchronize { @tree_types.size }
        end

        def memory_saved(total_trees)
          # 各TreeTypeオブジェクトが約100バイトと仮定
          type_size = 100
          saved = (total_trees - @tree_types.size) * type_size
          { types_count: @tree_types.size, total_trees: total_trees, bytes_saved: saved }
        end
      end

      # Context: 木（外部状態を持つ）
      class Tree
        attr_reader :x, :y, :type

        def initialize(x:, y:, type:)
          @x = x
          @y = y
          @type = type
        end

        def draw
          type.draw(x, y)
        end
      end

      # ===== アイコンキャッシュ例 =====

      # Flyweight: アイコン
      class Icon
        attr_reader :name, :image_data, :width, :height

        def initialize(name:, width: 32, height: 32)
          @name = name.freeze
          @width = width
          @height = height
          # シミュレートされた画像データ
          @image_data = "#{name}_#{width}x#{height}_data".freeze
          freeze
        end

        def render(x, y)
          "Rendering icon '#{name}' (#{width}x#{height}) at (#{x}, #{y})"
        end

        def ==(other)
          return false unless other.is_a?(Icon)

          name == other.name && width == other.width && height == other.height
        end
        alias eql? ==

        def hash
          [name, width, height].hash
        end
      end

      # Flyweight Factory: アイコンキャッシュ
      class IconCache
        def initialize
          @icons = {}
          @mutex = Mutex.new
        end

        def get_icon(name, width: 32, height: 32)
          key = "#{name}_#{width}x#{height}"

          @mutex.synchronize do
            @icons[key] ||= Icon.new(name: name, width: width, height: height)
          end
        end

        def preload(icon_names, width: 32, height: 32)
          icon_names.each { |name| get_icon(name, width: width, height: height) }
        end

        def cached_count
          @mutex.synchronize { @icons.size }
        end

        def clear
          @mutex.synchronize { @icons.clear }
        end
      end

      # ===== Domain Service: テキストエディタ =====

      class TextEditor
        def initialize
          @style_factory = CharacterStyleFactory.new
          @characters = []
        end

        def add_character(char, x:, y:, font_family: 'Arial', font_size: 12, **style_options)
          style = @style_factory.get_style(
            font_family: font_family,
            font_size: font_size,
            **style_options
          )
          @characters << Character.new(char, position_x: x, position_y: y, style: style)
        end

        def add_text(text, start_x:, start_y:, font_family: 'Arial', font_size: 12, **style_options)
          text.each_char.with_index do |char, i|
            add_character(
              char,
              x: start_x + (i * font_size * 0.6),
              y: start_y,
              font_family: font_family,
              font_size: font_size,
              **style_options
            )
          end
        end

        def render
          @characters.map(&:render)
        end

        def character_count
          @characters.size
        end

        def unique_styles_count
          @style_factory.styles_count
        end

        def memory_stats
          {
            total_characters: @characters.size,
            unique_styles: @style_factory.styles_count,
            memory_saved_ratio: 1.0 - (@style_factory.styles_count.to_f / @characters.size)
          }
        end
      end

      # Domain Service: 森林シミュレーター
      class Forest
        def initialize
          @type_factory = TreeTypeFactory.new
          @trees = []
        end

        def plant_tree(x:, y:, name:, color:, texture:)
          type = @type_factory.get_tree_type(name: name, color: color, texture: texture)
          @trees << Tree.new(x: x, y: y, type: type)
        end

        def draw
          @trees.map(&:draw)
        end

        def trees_count
          @trees.size
        end

        def types_count
          @type_factory.types_count
        end

        def memory_report
          @type_factory.memory_saved(@trees.size)
        end
      end
    end
  end
end
