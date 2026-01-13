# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/strategy/strategy'

class TestStrategy < GofPatternTest
  def test_payment_result_value_object
    result = GofPatterns::Behavioral::Strategy::PaymentResult.new(
      success: true,
      transaction_id: 'TXN-001',
      amount: 1000,
      fee: 30,
      message: 'OK'
    )

    assert result.success?
    assert_equal 'TXN-001', result.transaction_id
    assert_equal 1030, result.total
    assert result.frozen?
  end

  def test_credit_card_payment
    strategy = GofPatterns::Behavioral::Strategy::CreditCardPayment.new(
      card_number: '4111111111111234',
      expiry: '12/25',
      cvv: '123'
    )

    result = strategy.pay(10_000)

    assert result.success?
    assert_match(/^CC-/, result.transaction_id)
    assert_equal 300, result.fee # 3%
  end

  def test_credit_card_masked_number
    strategy = GofPatterns::Behavioral::Strategy::CreditCardPayment.new(
      card_number: '4111111111111234',
      expiry: '12/25',
      cvv: '123'
    )

    assert_equal '****-****-****-1234', strategy.masked_card_number
  end

  def test_paypal_payment
    strategy = GofPatterns::Behavioral::Strategy::PayPalPayment.new(
      email: 'test@example.com'
    )

    result = strategy.pay(10_000)

    assert result.success?
    assert_match(/^PP-/, result.transaction_id)
    assert_equal 440, result.fee # 4% + 40
  end

  def test_bank_transfer_payment
    strategy = GofPatterns::Behavioral::Strategy::BankTransferPayment.new(
      bank_code: '0001',
      account_number: '1234567'
    )

    result = strategy.pay(50_000)

    assert result.success?
    assert_match(/^BT-/, result.transaction_id)
    assert_equal 330, result.fee # 固定
  end

  def test_cash_on_delivery_payment
    strategy = GofPatterns::Behavioral::Strategy::CashOnDeliveryPayment.new

    result = strategy.pay(5000)

    assert result.success?
    assert_match(/^COD-/, result.transaction_id)
    assert_equal 330, result.fee # 0-9999: 330
  end

  def test_cash_on_delivery_tiered_fees
    strategy = GofPatterns::Behavioral::Strategy::CashOnDeliveryPayment.new

    assert_equal 330, strategy.fee_for(5000)
    assert_equal 440, strategy.fee_for(15_000)
    assert_equal 660, strategy.fee_for(50_000)
  end

  def test_payment_processor
    processor = GofPatterns::Behavioral::Strategy::PaymentProcessor.new

    card = GofPatterns::Behavioral::Strategy::CreditCardPayment.new(
      card_number: '4111111111111111',
      expiry: '12/25',
      cvv: '123'
    )
    processor.strategy = card

    result = processor.process_payment(1000)
    assert result.success?
    assert_equal 'Credit Card', processor.payment_method_name
  end

  def test_payment_processor_no_strategy
    processor = GofPatterns::Behavioral::Strategy::PaymentProcessor.new

    assert_raises(RuntimeError) do
      processor.process_payment(1000)
    end
  end

  def test_payment_processor_switch_strategy
    processor = GofPatterns::Behavioral::Strategy::PaymentProcessor.new

    processor.strategy = GofPatterns::Behavioral::Strategy::CreditCardPayment.new(
      card_number: '4111111111111111',
      expiry: '12/25',
      cvv: '123'
    )
    assert_equal 30, processor.calculate_fee(1000) # 3%

    processor.strategy = GofPatterns::Behavioral::Strategy::BankTransferPayment.new(
      bank_code: '0001',
      account_number: '1234567'
    )
    assert_equal 330, processor.calculate_fee(1000) # 固定
  end

  def test_bubble_sort
    sorter = GofPatterns::Behavioral::Strategy::Sorter.new(
      GofPatterns::Behavioral::Strategy::BubbleSort.new
    )

    result = sorter.sort([5, 2, 8, 1, 9])
    assert_equal [1, 2, 5, 8, 9], result
    assert_equal 'Bubble Sort', sorter.algorithm_name
  end

  def test_quick_sort
    sorter = GofPatterns::Behavioral::Strategy::Sorter.new(
      GofPatterns::Behavioral::Strategy::QuickSort.new
    )

    result = sorter.sort([5, 2, 8, 1, 9])
    assert_equal [1, 2, 5, 8, 9], result
    assert_equal 'Quick Sort', sorter.algorithm_name
  end

  def test_merge_sort
    sorter = GofPatterns::Behavioral::Strategy::Sorter.new(
      GofPatterns::Behavioral::Strategy::MergeSort.new
    )

    result = sorter.sort([5, 2, 8, 1, 9])
    assert_equal [1, 2, 5, 8, 9], result
    assert_equal 'Merge Sort', sorter.algorithm_name
  end

  def test_standard_sort
    sorter = GofPatterns::Behavioral::Strategy::Sorter.new

    result = sorter.sort([5, 2, 8, 1, 9])
    assert_equal [1, 2, 5, 8, 9], result
  end

  def test_base64_compression
    compressor = GofPatterns::Behavioral::Strategy::DataCompressor.new(
      GofPatterns::Behavioral::Strategy::Base64Compression.new
    )

    original = 'Hello World'
    compressed = compressor.compress(original)
    decompressed = compressor.decompress(compressed)

    refute_equal original, compressed
    assert_equal original, decompressed
  end

  def test_rle_compression
    compressor = GofPatterns::Behavioral::Strategy::DataCompressor.new(
      GofPatterns::Behavioral::Strategy::RLECompression.new
    )

    original = 'AAABBBCCCC'
    compressed = compressor.compress(original)
    decompressed = compressor.decompress(compressed)

    assert_equal '3A3B4C', compressed
    assert_equal original, decompressed
  end

  def test_payment_strategy_factory
    factory = GofPatterns::Behavioral::Strategy::PaymentStrategyFactory

    credit = factory.create(:credit_card, card_number: '4111', expiry: '12/25', cvv: '123')
    assert_instance_of GofPatterns::Behavioral::Strategy::CreditCardPayment, credit

    paypal = factory.create(:paypal, email: 'test@example.com')
    assert_instance_of GofPatterns::Behavioral::Strategy::PayPalPayment, paypal

    bank = factory.create(:bank_transfer, bank_code: '0001', account_number: '123')
    assert_instance_of GofPatterns::Behavioral::Strategy::BankTransferPayment, bank

    cod = factory.create(:cod)
    assert_instance_of GofPatterns::Behavioral::Strategy::CashOnDeliveryPayment, cod
  end

  def test_payment_strategy_factory_unknown
    factory = GofPatterns::Behavioral::Strategy::PaymentStrategyFactory

    assert_raises(ArgumentError) do
      factory.create(:unknown)
    end
  end
end
