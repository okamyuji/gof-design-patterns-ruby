# frozen_string_literal: true

require 'singleton'

module GofPatterns
  module Creational
    # Singleton Pattern (シングルトンパターン)
    # ========================================
    # 目的: クラスのインスタンスが1つだけ存在することを保証し、
    #       グローバルなアクセスポイントを提供する
    #
    # DDD Context:
    # - Domain Service として実装（特定のEntityに属さない共有サービス）
    # - アプリケーション全体で共有される設定やリソース管理に適用

    module Singleton
      # Value Object: 設定値を表す不変オブジェクト
      class ConfigValue
        attr_reader :key, :value, :created_at

        def initialize(key, value)
          @key = key.to_s.freeze
          @value = value.freeze
          @created_at = Time.now.freeze
          freeze
        end

        def ==(other)
          return false unless other.is_a?(ConfigValue)

          key == other.key && value == other.value
        end
        alias eql? ==

        def hash
          [key, value].hash
        end

        def to_s
          "#{key}=#{value}"
        end
      end

      # Domain Service: アプリケーション設定を管理するシングルトン
      # Ruby標準ライブラリの Singleton モジュールを活用
      class Configuration
        include ::Singleton

        def initialize
          @settings = {}
          @mutex = Mutex.new
        end

        def set(key, value)
          @mutex.synchronize do
            @settings[key.to_sym] = ConfigValue.new(key, value)
          end
        end

        def get(key)
          @mutex.synchronize do
            config_value = @settings[key.to_sym]
            config_value&.value
          end
        end

        def fetch(key, default = nil)
          get(key) || default
        end

        def all
          @mutex.synchronize do
            @settings.transform_values(&:value)
          end
        end

        def clear!
          @mutex.synchronize do
            @settings.clear
          end
        end

        def size
          @mutex.synchronize do
            @settings.size
          end
        end
      end

      # 手動実装版シングルトン（Ruby標準モジュール不使用の例）
      # 教育目的: シングルトンパターンの本質を理解するため
      class ManualSingleton
        @instance = nil
        @mutex = Mutex.new

        class << self
          def instance
            return @instance if @instance

            @mutex.synchronize do
              @instance ||= new
            end
          end

          private :new
        end

        def initialize
          @data = {}
        end

        def store(key, value)
          @data[key] = value
        end

        def retrieve(key)
          @data[key]
        end
      end

      # Domain Service: ロガーサービス（シングルトン例）
      class Logger
        include ::Singleton

        LEVELS = { debug: 0, info: 1, warn: 2, error: 3, fatal: 4 }.freeze

        def initialize
          @level = :info
          @output = $stdout
          @mutex = Mutex.new
        end

        attr_reader :level

        def level=(new_level)
          raise ArgumentError, "Invalid log level: #{new_level}" unless LEVELS.key?(new_level)

          @level = new_level
        end

        def output=(io)
          @output = io
        end

        def debug(message)
          log(:debug, message)
        end

        def info(message)
          log(:info, message)
        end

        def warn(message)
          log(:warn, message)
        end

        def error(message)
          log(:error, message)
        end

        def fatal(message)
          log(:fatal, message)
        end

        private

        def log(level, message)
          return if LEVELS[level] < LEVELS[@level]

          @mutex.synchronize do
            timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
            @output.puts "[#{timestamp}] #{level.upcase}: #{message}"
          end
        end
      end
    end
  end
end
