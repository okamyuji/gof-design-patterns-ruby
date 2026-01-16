# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/observer/observer'

class TestObserver < GofPatternTest
  def test_stock_price_value_object
    price = GofPatterns::Behavioral::Observer::StockPrice.new(symbol: 'aapl', price: 150.5)

    assert_equal 'AAPL', price.symbol
    assert_in_delta(150.5, price.price)
    assert_predicate price, :frozen?
  end

  def test_stock_monitor_update_price
    monitor = GofPatterns::Behavioral::Observer::StockMonitor.new
    monitor.update_price('AAPL', 150.0)

    price = monitor.get_price('AAPL')

    assert_in_delta(150.0, price.price)
  end

  def test_stock_display_observer
    monitor = GofPatterns::Behavioral::Observer::StockMonitor.new
    display = GofPatterns::Behavioral::Observer::StockDisplay.new('Main Display')

    monitor.attach(display)
    monitor.update_price('AAPL', 150.0)

    last = display.last_display

    assert_equal 'AAPL', last[:price].symbol
    assert_in_delta(150.0, last[:price].price)
  end

  def test_stock_alert_observer
    monitor = GofPatterns::Behavioral::Observer::StockMonitor.new
    alert = GofPatterns::Behavioral::Observer::StockAlert.new(threshold_percent: 5.0)

    monitor.attach(alert)

    monitor.update_price('AAPL', 100.0)
    monitor.update_price('AAPL', 110.0) # 10% increase

    assert(alert.alerts.any? { |a| a[:symbol] == 'AAPL' && a[:direction] == 'UP' })
  end

  def test_stock_logger_observer
    monitor = GofPatterns::Behavioral::Observer::StockMonitor.new
    logger = GofPatterns::Behavioral::Observer::StockLogger.new

    monitor.attach(logger)
    monitor.update_price('GOOG', 2500.0)

    assert(logger.logs.any? { |l| l.include?('GOOG') })
  end

  def test_subject_attach_detach
    monitor = GofPatterns::Behavioral::Observer::StockMonitor.new
    display = GofPatterns::Behavioral::Observer::StockDisplay.new('Test')

    monitor.attach(display)

    assert_equal 1, monitor.observers_count

    monitor.detach(display)

    assert_equal 0, monitor.observers_count
  end

  def test_multiple_observers
    monitor = GofPatterns::Behavioral::Observer::StockMonitor.new
    display1 = GofPatterns::Behavioral::Observer::StockDisplay.new('Display 1')
    display2 = GofPatterns::Behavioral::Observer::StockDisplay.new('Display 2')
    alert = GofPatterns::Behavioral::Observer::StockAlert.new

    monitor.attach(display1)
    monitor.attach(display2)
    monitor.attach(alert)

    monitor.update_price('MSFT', 300.0)

    assert display1.last_display
    assert display2.last_display
  end

  def test_weather_station_observable
    station = GofPatterns::Behavioral::Observer::WeatherStation.new
    current = GofPatterns::Behavioral::Observer::CurrentConditionsDisplay.new(station)

    station.set_measurements(25.0, 65.0, 1013.0)

    assert_in_delta(25.0, current.temperature)
    assert_in_delta(65.0, current.humidity)
  end

  def test_statistics_display
    station = GofPatterns::Behavioral::Observer::WeatherStation.new
    stats = GofPatterns::Behavioral::Observer::StatisticsDisplay.new(station)

    station.set_measurements(20.0, 60.0, 1010.0)
    station.set_measurements(25.0, 65.0, 1015.0)
    station.set_measurements(30.0, 70.0, 1020.0)

    assert_in_delta(25.0, stats.average_temperature)
    assert_in_delta(30.0, stats.max_temperature)
    assert_in_delta(20.0, stats.min_temperature)
  end

  def test_forecast_display
    station = GofPatterns::Behavioral::Observer::WeatherStation.new
    forecast = GofPatterns::Behavioral::Observer::ForecastDisplay.new(station)

    station.set_measurements(25.0, 65.0, 1010.0) # 気圧下降

    assert_match(/rainy/, forecast.forecast)

    station.set_measurements(25.0, 65.0, 1020.0) # 気圧上昇

    assert_match(/Improving/, forecast.forecast)
  end

  def test_observer_unsubscribe
    station = GofPatterns::Behavioral::Observer::WeatherStation.new
    current = GofPatterns::Behavioral::Observer::CurrentConditionsDisplay.new(station)

    # First set some initial measurements
    station.set_measurements(25.0, 70.0, 1010.0)

    assert_in_delta(25.0, current.temperature, 0.01)

    # Now unsubscribe
    current.unsubscribe

    # Set new measurements - display should not update
    station.set_measurements(30.0, 80.0, 1000.0)
    # Should still have the old value, not the new one
    assert_in_delta(25.0, current.temperature, 0.01)
  end

  def test_event_emitter_on_and_emit
    emitter = GofPatterns::Behavioral::Observer::EventEmitter.new
    received = []

    emitter.on(:test) { |data| received << data }
    emitter.emit(:test, 'Hello')
    emitter.emit(:test, 'World')

    assert_equal %w[Hello World], received
  end

  def test_event_emitter_off
    emitter = GofPatterns::Behavioral::Observer::EventEmitter.new
    received = []
    handler = ->(data) { received << data }

    emitter.on(:test, &handler)
    emitter.emit(:test, 'First')

    emitter.off(:test, &handler)
    emitter.emit(:test, 'Second')

    assert_equal ['First'], received
  end

  def test_event_emitter_once
    emitter = GofPatterns::Behavioral::Observer::EventEmitter.new
    count = 0

    emitter.once(:test) { count += 1 }
    emitter.emit(:test)
    emitter.emit(:test)
    emitter.emit(:test)

    assert_equal 1, count
  end

  def test_event_emitter_clear
    emitter = GofPatterns::Behavioral::Observer::EventEmitter.new
    emitter.on(:test) {}
    emitter.on(:test) {}

    emitter.clear(:test)

    assert_equal 0, emitter.listeners_count(:test)
  end

  def test_news_publisher
    publisher = GofPatterns::Behavioral::Observer::NewsPublisher.new
    tech_news = []
    all_news = []

    publisher.on(:tech) { |n| tech_news << n }
    publisher.on(:all) { |n| all_news << n }

    publisher.publish(:tech, 'New Ruby version', 'Ruby 3.4 released')
    publisher.publish(:sports, 'World Cup', 'Final match results')

    assert_equal 1, tech_news.size
    assert_equal 2, all_news.size
  end
end
