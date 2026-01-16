# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/creational/singleton/singleton'

class TestSingleton < GofPatternTest
  def setup
    @config = GofPatterns::Creational::Singleton::Configuration.instance
    @config.clear!
  end

  def test_configuration_returns_same_instance
    config1 = GofPatterns::Creational::Singleton::Configuration.instance
    config2 = GofPatterns::Creational::Singleton::Configuration.instance

    assert_same config1, config2
  end

  def test_configuration_cannot_be_instantiated_directly
    assert_raises(NoMethodError) do
      GofPatterns::Creational::Singleton::Configuration.new
    end
  end

  def test_configuration_set_and_get
    @config.set(:app_name, 'TestApp')
    @config.set(:version, '1.0.0')

    assert_equal 'TestApp', @config.get(:app_name)
    assert_equal '1.0.0', @config.get(:version)
  end

  def test_configuration_fetch_with_default
    assert_nil @config.get(:nonexistent)
    assert_equal 'default', @config.fetch(:nonexistent, 'default')
  end

  def test_configuration_all
    @config.set(:key1, 'value1')
    @config.set(:key2, 'value2')

    all = @config.all

    assert_equal 'value1', all[:key1]
    assert_equal 'value2', all[:key2]
  end

  def test_configuration_size
    assert_equal 0, @config.size
    @config.set(:key1, 'value1')

    assert_equal 1, @config.size
  end

  def test_config_value_is_value_object
    cv1 = GofPatterns::Creational::Singleton::ConfigValue.new(:test, 'value')
    cv2 = GofPatterns::Creational::Singleton::ConfigValue.new(:test, 'value')

    assert_equal cv1, cv2
    assert_equal cv1.hash, cv2.hash
    assert_predicate cv1, :frozen?
  end

  def test_manual_singleton_returns_same_instance
    manual1 = GofPatterns::Creational::Singleton::ManualSingleton.instance
    manual2 = GofPatterns::Creational::Singleton::ManualSingleton.instance

    assert_same manual1, manual2
  end

  def test_manual_singleton_store_and_retrieve
    singleton = GofPatterns::Creational::Singleton::ManualSingleton.instance
    singleton.store(:key, 'value')

    assert_equal 'value', singleton.retrieve(:key)
  end

  def test_logger_is_singleton
    logger1 = GofPatterns::Creational::Singleton::Logger.instance
    logger2 = GofPatterns::Creational::Singleton::Logger.instance

    assert_same logger1, logger2
  end

  def test_logger_level_validation
    logger = GofPatterns::Creational::Singleton::Logger.instance

    assert_raises(ArgumentError) do
      logger.level = :invalid_level
    end
  end

  def test_logger_logs_messages
    logger = GofPatterns::Creational::Singleton::Logger.instance
    output = StringIO.new
    logger.output = output
    logger.level = :info

    logger.info('Test message')

    assert_match(/INFO: Test message/, output.string)
  end

  def test_logger_respects_level
    logger = GofPatterns::Creational::Singleton::Logger.instance
    output = StringIO.new
    logger.output = output
    logger.level = :warn

    logger.debug('Debug message')
    logger.info('Info message')
    logger.warn('Warn message')

    refute_match(/DEBUG/, output.string)
    refute_match(/INFO/, output.string)
    assert_match(/WARN/, output.string)
  end
end
