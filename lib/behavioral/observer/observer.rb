# frozen_string_literal: true

require 'observer'

module GofPatterns
  module Behavioral
    # Observer Pattern (オブザーバパターン)
    # ====================================
    # 目的: オブジェクト間の一対多の依存関係を定義し、
    #       一つのオブジェクトの状態変化を依存オブジェクトに自動通知する
    #
    # DDD Context:
    # - Domain Event の発行と購読
    # - Aggregate 間の疎結合な連携

    module Observer
      # Observer Interface
      class Observer
        def update(_subject, *_args)
          raise NotImplementedError
        end
      end

      # Subject Interface
      class Subject
        def initialize
          @observers = []
        end

        def attach(observer)
          @observers << observer unless @observers.include?(observer)
        end

        def detach(observer)
          @observers.delete(observer)
        end

        def notify(*)
          @observers.each { |observer| observer.update(self, *) }
        end

        def observers_count
          @observers.size
        end
      end

      # Value Object: 株価
      class StockPrice
        attr_reader :symbol, :price, :timestamp

        def initialize(symbol:, price:)
          @symbol = symbol.upcase.freeze
          @price = price.round(2)
          @timestamp = Time.now
          freeze
        end

        def ==(other)
          return false unless other.is_a?(StockPrice)

          symbol == other.symbol && price == other.price
        end
        alias eql? ==

        def hash
          [symbol, price].hash
        end

        def to_s
          "#{symbol}: ¥#{price} (#{timestamp.strftime('%H:%M:%S')})"
        end
      end

      # Concrete Subject: 株価モニター
      class StockMonitor < Subject
        attr_reader :prices

        def initialize
          super
          @prices = {}
        end

        def update_price(symbol, price)
          stock_price = StockPrice.new(symbol: symbol, price: price)
          old_price = @prices[symbol]
          @prices[symbol] = stock_price

          change = old_price ? ((price - old_price.price) / old_price.price * 100).round(2) : 0
          notify(stock_price, change)
        end

        def get_price(symbol)
          @prices[symbol.upcase]
        end
      end

      # Concrete Observer: 株価表示
      class StockDisplay < Observer
        attr_reader :displayed_prices

        def initialize(name)
          @name = name
          @displayed_prices = []
        end

        def update(subject, stock_price, change)
          @displayed_prices << {
            price: stock_price,
            change: change,
            source: subject.class.name
          }
        end

        def last_display
          @displayed_prices.last
        end
      end

      # Concrete Observer: 株価アラート
      class StockAlert < Observer
        attr_reader :alerts

        def initialize(threshold_percent: 5.0)
          @threshold_percent = threshold_percent
          @alerts = []
        end

        def update(_subject, stock_price, change)
          return unless change.abs >= @threshold_percent

          direction = change.positive? ? 'UP' : 'DOWN'
          @alerts << {
            symbol: stock_price.symbol,
            price: stock_price.price,
            change: change,
            direction: direction,
            timestamp: Time.now
          }
        end
      end

      # Concrete Observer: 株価ロガー
      class StockLogger < Observer
        attr_reader :logs

        def initialize(log_file = nil)
          @log_file = log_file
          @logs = []
        end

        def update(_subject, stock_price, change)
          log_entry = "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] " \
                      "#{stock_price.symbol}: ¥#{stock_price.price} (#{'+' if change >= 0}#{change}%)"
          @logs << log_entry

          File.open(@log_file, 'a') { |f| f.puts(log_entry) } if @log_file
        end
      end

      # ===== Ruby標準ライブラリ Observable を使用した例 =====

      # Concrete Subject: 天気ステーション（Ruby Observable使用）
      class WeatherStation
        include ::Observable

        attr_reader :temperature, :humidity, :pressure

        def initialize
          @temperature = 0.0
          @humidity = 0.0
          @pressure = 1013.25
        end

        def set_measurements(temperature, humidity, pressure)
          @temperature = temperature
          @humidity = humidity
          @pressure = pressure

          changed
          notify_observers(
            temperature: @temperature,
            humidity: @humidity,
            pressure: @pressure
          )
        end

        def measurements
          {
            temperature: @temperature,
            humidity: @humidity,
            pressure: @pressure
          }
        end
      end

      # Concrete Observer: 現在の気象表示
      class CurrentConditionsDisplay
        attr_reader :temperature, :humidity, :last_update

        def initialize(weather_station)
          @weather_station = weather_station
          @weather_station.add_observer(self)
        end

        def update(data)
          @temperature = data[:temperature]
          @humidity = data[:humidity]
          @last_update = Time.now
        end

        def display
          "Current: #{@temperature}°C, #{@humidity}% humidity"
        end

        def unsubscribe
          @weather_station.delete_observer(self)
        end
      end

      # Concrete Observer: 気象統計表示
      class StatisticsDisplay
        attr_reader :readings

        def initialize(weather_station)
          @weather_station = weather_station
          @weather_station.add_observer(self)
          @readings = []
        end

        def update(data)
          @readings << data.merge(timestamp: Time.now)
        end

        def average_temperature
          return 0 if @readings.empty?

          @readings.sum { |r| r[:temperature] } / @readings.size.to_f
        end

        def max_temperature
          @readings.map { |r| r[:temperature] }.max || 0
        end

        def min_temperature
          @readings.map { |r| r[:temperature] }.min || 0
        end

        def display
          "Stats: Avg=#{average_temperature.round(1)}°C, " \
            "Max=#{max_temperature}°C, Min=#{min_temperature}°C"
        end

        def unsubscribe
          @weather_station.delete_observer(self)
        end
      end

      # Concrete Observer: 予報表示
      class ForecastDisplay
        attr_reader :forecast

        def initialize(weather_station)
          @weather_station = weather_station
          @weather_station.add_observer(self)
          @last_pressure = 1013.25
          @forecast = 'No forecast yet'
        end

        def update(data)
          current_pressure = data[:pressure]
          @forecast = if current_pressure > @last_pressure
                        'Improving weather on the way!'
                      elsif current_pressure < @last_pressure
                        'Watch out for cooler, rainy weather'
                      else
                        'More of the same'
                      end
          @last_pressure = current_pressure
        end

        def display
          "Forecast: #{@forecast}"
        end

        def unsubscribe
          @weather_station.delete_observer(self)
        end
      end

      # ===== イベントベース実装 =====

      # Event Emitter: イベントベースのSubject
      class EventEmitter
        def initialize
          @listeners = Hash.new { |h, k| h[k] = [] }
        end

        def on(event, &block)
          @listeners[event] << block
        end

        def off(event, &block)
          @listeners[event].delete(block)
        end

        def emit(event, *)
          @listeners[event].each { |listener| listener.call(*) }
        end

        def once(event, &block)
          wrapper = lambda do |*args|
            block.call(*args)
            off(event, &wrapper)
          end
          on(event, &wrapper)
        end

        def listeners_count(event)
          @listeners[event].size
        end

        def clear(event = nil)
          if event
            @listeners.delete(event)
          else
            @listeners.clear
          end
        end
      end

      # Domain Service: ニュース発行者
      class NewsPublisher < EventEmitter
        def publish(category, headline, content)
          emit(category, {
                 category: category,
                 headline: headline,
                 content: content,
                 published_at: Time.now
               })
          emit(:all, {
                 category: category,
                 headline: headline,
                 content: content,
                 published_at: Time.now
               })
        end
      end
    end
  end
end
