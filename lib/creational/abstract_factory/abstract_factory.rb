# frozen_string_literal: true

module GofPatterns
  module Creational
    # Abstract Factory Pattern (抽象ファクトリパターン)
    # ================================================
    # 目的: 関連するオブジェクトのファミリーを、
    #       具象クラスを指定せずに生成する
    #
    # DDD Context:
    # - 関連するEntity群の一貫した生成を保証
    # - 異なるBounded Context間での整合性維持

    module AbstractFactory
      # Value Object: カラー
      class Color
        attr_reader :r, :g, :b

        def initialize(r, g, b)
          @r = r.clamp(0, 255)
          @g = g.clamp(0, 255)
          @b = b.clamp(0, 255)
          freeze
        end

        def to_hex
          format('#%02X%02X%02X', r, g, b)
        end

        def ==(other)
          return false unless other.is_a?(Color)

          r == other.r && g == other.g && b == other.b
        end
        alias eql? ==

        def hash
          [r, g, b].hash
        end

        # 定義済みカラー
        WHITE = new(255, 255, 255)
        BLACK = new(0, 0, 0)
        DARK_GRAY = new(45, 45, 45)
        LIGHT_GRAY = new(240, 240, 240)
        BLUE = new(0, 120, 215)
        DARK_BLUE = new(0, 90, 180)
      end

      # Entity: ボタン（抽象）
      class Button
        attr_reader :label, :style

        def initialize(label)
          @label = label
          @style = default_style
        end

        def render
          raise NotImplementedError
        end

        def click
          raise NotImplementedError
        end

        protected

        def default_style
          raise NotImplementedError
        end
      end

      # Entity: チェックボックス（抽象）
      class Checkbox
        attr_reader :label, :checked

        def initialize(label, checked: false)
          @label = label
          @checked = checked
        end

        def toggle
          @checked = !@checked
        end

        def render
          raise NotImplementedError
        end

        protected

        def default_style
          raise NotImplementedError
        end
      end

      # Entity: テキストフィールド（抽象）
      class TextField
        attr_reader :placeholder, :value

        def initialize(placeholder = '')
          @placeholder = placeholder
          @value = ''
        end

        def input(text)
          @value = text
        end

        def clear
          @value = ''
        end

        def render
          raise NotImplementedError
        end
      end

      # Concrete Products: ライトテーマUI
      module LightTheme
        class Button < AbstractFactory::Button
          def render
            "[Light Button: #{label}]"
          end

          def click
            "Light button '#{label}' clicked"
          end

          protected

          def default_style
            { background: Color::LIGHT_GRAY, text: Color::BLACK, border: Color::DARK_GRAY }
          end
        end

        class Checkbox < AbstractFactory::Checkbox
          def render
            mark = checked ? '[x]' : '[ ]'
            "Light #{mark} #{label}"
          end

          protected

          def default_style
            { background: Color::WHITE, check: Color::BLUE }
          end
        end

        class TextField < AbstractFactory::TextField
          def render
            display = value.empty? ? placeholder : value
            "Light [#{display}]"
          end

          protected

          def default_style
            { background: Color::WHITE, text: Color::BLACK, border: Color::DARK_GRAY }
          end
        end
      end

      # Concrete Products: ダークテーマUI
      module DarkTheme
        class Button < AbstractFactory::Button
          def render
            "[[Dark Button: #{label}]]"
          end

          def click
            "Dark button '#{label}' clicked"
          end

          protected

          def default_style
            { background: Color::DARK_GRAY, text: Color::WHITE, border: Color::DARK_BLUE }
          end
        end

        class Checkbox < AbstractFactory::Checkbox
          def render
            mark = checked ? '[*]' : '[-]'
            "Dark #{mark} #{label}"
          end

          protected

          def default_style
            { background: Color::DARK_GRAY, check: Color::BLUE }
          end
        end

        class TextField < AbstractFactory::TextField
          def render
            display = value.empty? ? placeholder : value
            "Dark [[#{display}]]"
          end

          protected

          def default_style
            { background: Color::DARK_GRAY, text: Color::WHITE, border: Color::DARK_BLUE }
          end
        end
      end

      # Abstract Factory: UIコンポーネントファクトリ（抽象）
      class UIFactory
        def create_button(_label)
          raise NotImplementedError
        end

        def create_checkbox(_label, checked: false)
          raise NotImplementedError
        end

        def create_text_field(_placeholder = '')
          raise NotImplementedError
        end

        def theme_name
          raise NotImplementedError
        end
      end

      # Concrete Factory: ライトテーマファクトリ
      class LightThemeFactory < UIFactory
        def create_button(label)
          LightTheme::Button.new(label)
        end

        def create_checkbox(label, checked: false)
          LightTheme::Checkbox.new(label, checked: checked)
        end

        def create_text_field(placeholder = '')
          LightTheme::TextField.new(placeholder)
        end

        def theme_name
          'Light'
        end
      end

      # Concrete Factory: ダークテーマファクトリ
      class DarkThemeFactory < UIFactory
        def create_button(label)
          DarkTheme::Button.new(label)
        end

        def create_checkbox(label, checked: false)
          DarkTheme::Checkbox.new(label, checked: checked)
        end

        def create_text_field(placeholder = '')
          DarkTheme::TextField.new(placeholder)
        end

        def theme_name
          'Dark'
        end
      end

      # Domain Service: テーマ切り替えサービス
      class ThemeManager
        THEMES = {
          light: LightThemeFactory,
          dark: DarkThemeFactory
        }.freeze

        def self.factory_for(theme)
          factory_class = THEMES[theme.to_sym]
          raise ArgumentError, "Unknown theme: #{theme}" unless factory_class

          factory_class.new
        end

        def self.available_themes
          THEMES.keys
        end
      end

      # Application Service: UIコンポーネントビルダー
      class UIBuilder
        def initialize(factory)
          @factory = factory
          @components = []
        end

        def add_button(label)
          @components << @factory.create_button(label)
          self
        end

        def add_checkbox(label, checked: false)
          @components << @factory.create_checkbox(label, checked: checked)
          self
        end

        def add_text_field(placeholder = '')
          @components << @factory.create_text_field(placeholder)
          self
        end

        def build
          @components.dup
        end

        def render_all
          @components.map(&:render).join("\n")
        end
      end
    end
  end
end
