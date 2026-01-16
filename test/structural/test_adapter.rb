# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/adapter/adapter'

class TestAdapter < GofPatternTest
  def test_money_value_object
    m1 = GofPatterns::Structural::Adapter::Money.new(100, 'JPY')
    m2 = GofPatterns::Structural::Adapter::Money.new(100, 'JPY')

    assert_equal m1, m2
    assert_equal 10_000, m1.to_cents
    assert_equal 'JPY 100.00', m1.to_s
    assert_predicate m1, :frozen?
  end

  def test_money_currency_uppercase
    money = GofPatterns::Structural::Adapter::Money.new(50, 'usd')

    assert_equal 'USD', money.currency
  end

  def test_legacy_payment_adapter_process_payment
    adapter = GofPatterns::Structural::Adapter::LegacyPaymentAdapter.new
    money = GofPatterns::Structural::Adapter::Money.new(1000, 'JPY')

    result = adapter.process_payment(money, 'JPY')

    assert_instance_of GofPatterns::Structural::Adapter::TransactionResult, result
    assert_predicate result, :success?
    assert_match(/^LEG-/, result.transaction_id)
  end

  def test_legacy_payment_adapter_refund
    adapter = GofPatterns::Structural::Adapter::LegacyPaymentAdapter.new
    money = GofPatterns::Structural::Adapter::Money.new(500, 'JPY')

    result = adapter.refund('LEG-12345678', money)

    assert_predicate result, :success?
  end

  def test_legacy_payment_adapter_get_status
    adapter = GofPatterns::Structural::Adapter::LegacyPaymentAdapter.new

    result = adapter.get_status('LEG-12345678')

    assert_predicate result, :success?
  end

  def test_external_api_adapter_process_payment
    adapter = GofPatterns::Structural::Adapter::ExternalApiAdapter.new
    money = GofPatterns::Structural::Adapter::Money.new(2000, 'JPY')

    result = adapter.process_payment(money, 'JPY')

    assert_predicate result, :success?
    assert_match(/^EXT-/, result.transaction_id)
  end

  def test_external_api_adapter_refund
    adapter = GofPatterns::Structural::Adapter::ExternalApiAdapter.new
    money = GofPatterns::Structural::Adapter::Money.new(1000, 'JPY')

    result = adapter.refund('EXT-12345678', money)

    assert_predicate result, :success?
    assert_match(/^REF-/, result.transaction_id)
  end

  def test_external_api_adapter_get_status
    adapter = GofPatterns::Structural::Adapter::ExternalApiAdapter.new

    result = adapter.get_status('EXT-12345678')

    assert_predicate result, :success?
  end

  def test_payment_service_with_external_adapter
    service = GofPatterns::Structural::Adapter::PaymentService.new(adapter_type: :external)

    result = service.pay(5000)

    assert_predicate result, :success?
  end

  def test_payment_service_with_legacy_adapter
    service = GofPatterns::Structural::Adapter::PaymentService.new(adapter_type: :legacy)

    result = service.pay(3000)

    assert_predicate result, :success?
  end

  def test_transaction_result_value_object
    result1 = GofPatterns::Structural::Adapter::TransactionResult.new(
      transaction_id: 'TXN-001',
      status: :success,
      message: 'OK'
    )
    result2 = GofPatterns::Structural::Adapter::TransactionResult.new(
      transaction_id: 'TXN-001',
      status: :success,
      message: 'OK'
    )

    assert_equal result1, result2
    assert_predicate result1, :success?
    assert_predicate result1, :frozen?
  end

  def test_transaction_result_failed_status
    result = GofPatterns::Structural::Adapter::TransactionResult.new(
      transaction_id: 'TXN-002',
      status: :failed,
      message: 'Error'
    )

    refute_predicate result, :success?
  end
end
