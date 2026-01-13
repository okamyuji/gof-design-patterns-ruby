# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/facade/facade'

class TestFacade < GofPatternTest
  def setup
    @service = GofPatterns::Structural::Facade::ECommerceService.new
    # 在庫を追加
    @service.add_inventory('PROD-001', 100)
    @service.add_inventory('PROD-002', 50)
  end

  def test_order_item_value_object
    item = GofPatterns::Structural::Facade::OrderItem.new(
      product_id: 'PROD-001',
      name: 'Widget',
      quantity: 2,
      unit_price: 1000
    )

    assert_equal 'PROD-001', item.product_id
    assert_equal 2000, item.total_price
    assert item.frozen?
  end

  def test_shipping_address_value_object
    address = GofPatterns::Structural::Facade::ShippingAddress.new(
      name: 'John Doe',
      postal_code: '100-0001',
      address: 'Tokyo, Chiyoda',
      phone: '03-1234-5678'
    )

    assert_equal '〒100-0001 Tokyo, Chiyoda', address.full_address
    assert address.frozen?
  end

  def test_place_order_success
    items = [
      GofPatterns::Structural::Facade::OrderItem.new(
        product_id: 'PROD-001',
        name: 'Widget',
        quantity: 2,
        unit_price: 1000
      )
    ]
    address = GofPatterns::Structural::Facade::ShippingAddress.new(
      name: 'John',
      postal_code: '100-0001',
      address: 'Tokyo',
      phone: '03-1234-5678'
    )

    result = @service.place_order(
      items: items,
      shipping_address: address,
      payment_method: :credit_card,
      customer_email: 'john@example.com'
    )

    assert result[:success]
    assert_match(/^ORD-/, result[:order_id])
    assert_match(/^TXN-/, result[:transaction_id])
    assert_match(/^SHIP-/, result[:tracking_number])
    assert_equal 2000, result[:total_amount]
  end

  def test_place_order_out_of_stock
    items = [
      GofPatterns::Structural::Facade::OrderItem.new(
        product_id: 'PROD-001',
        name: 'Widget',
        quantity: 200, # 在庫以上
        unit_price: 1000
      )
    ]
    address = GofPatterns::Structural::Facade::ShippingAddress.new(
      name: 'John',
      postal_code: '100-0001',
      address: 'Tokyo',
      phone: '03-1234-5678'
    )

    result = @service.place_order(
      items: items,
      shipping_address: address,
      payment_method: :credit_card,
      customer_email: 'john@example.com'
    )

    refute result[:success]
    assert_match(/out of stock/, result[:error])
  end

  def test_cancel_order
    # まず注文を作成
    items = [
      GofPatterns::Structural::Facade::OrderItem.new(
        product_id: 'PROD-002',
        name: 'Gadget',
        quantity: 5,
        unit_price: 500
      )
    ]
    address = GofPatterns::Structural::Facade::ShippingAddress.new(
      name: 'Jane',
      postal_code: '200-0002',
      address: 'Osaka',
      phone: '06-1234-5678'
    )

    order_result = @service.place_order(
      items: items,
      shipping_address: address,
      payment_method: :credit_card,
      customer_email: 'jane@example.com'
    )

    # 注文をキャンセル
    cancel_result = @service.cancel_order(
      order_result[:order_id],
      customer_email: 'jane@example.com'
    )

    assert cancel_result[:success]
    assert_equal :cancelled, cancel_result[:status]
  end

  def test_cancel_nonexistent_order
    result = @service.cancel_order(
      'ORD-NONEXISTENT',
      customer_email: 'test@example.com'
    )

    refute result[:success]
    assert_match(/not found/, result[:error])
  end

  def test_get_order_status
    # 注文を作成
    items = [
      GofPatterns::Structural::Facade::OrderItem.new(
        product_id: 'PROD-001',
        name: 'Widget',
        quantity: 1,
        unit_price: 1000
      )
    ]
    address = GofPatterns::Structural::Facade::ShippingAddress.new(
      name: 'Test',
      postal_code: '300-0003',
      address: 'Nagoya',
      phone: '052-1234-5678'
    )

    order_result = @service.place_order(
      items: items,
      shipping_address: address,
      payment_method: :credit_card,
      customer_email: 'test@example.com'
    )

    # ステータス確認
    status = @service.get_order_status(order_result[:order_id])

    assert_equal order_result[:order_id], status[:order_id]
    assert_equal :confirmed, status[:status]
    assert_equal order_result[:tracking_number], status[:tracking_number]
  end

  def test_estimate_shipping
    items = [
      GofPatterns::Structural::Facade::OrderItem.new(
        product_id: 'PROD-001',
        name: 'Widget',
        quantity: 10,
        unit_price: 100
      )
    ]
    address = GofPatterns::Structural::Facade::ShippingAddress.new(
      name: 'Test',
      postal_code: '100-0001',
      address: 'Tokyo',
      phone: '03-1234-5678'
    )

    estimate = @service.estimate_shipping(address, items)

    assert estimate[:cost].positive?
    assert estimate[:estimated_days].positive?
  end

  def test_inventory_system_direct
    inventory = GofPatterns::Structural::Facade::InventorySystem.new
    inventory.add_stock('ITEM-001', 50)

    assert inventory.check_availability('ITEM-001', 30)
    refute inventory.check_availability('ITEM-001', 60)
  end

  def test_payment_system_direct
    payment = GofPatterns::Structural::Facade::PaymentSystem.new
    result = payment.process_payment('ORD-001', 5000, :credit_card)

    assert result[:success]
    assert_match(/^TXN-/, result[:transaction_id])
  end

  def test_shipping_system_direct
    shipping = GofPatterns::Structural::Facade::ShippingSystem.new
    result = shipping.create_shipment('ORD-001', 'Tokyo', [{ product_id: 'P1', quantity: 1 }])

    assert result[:success]
    assert_match(/^SHIP-/, result[:tracking_number])
  end

  def test_notification_service_direct
    notification = GofPatterns::Structural::Facade::NotificationService.new
    result = notification.send_email('test@example.com', 'Test', 'Body')

    assert result[:success]
    assert_equal :email, result[:type]
  end
end
