# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/state/state'

class TestState < GofPatternTest
  def test_vending_machine_initial_state
    machine = GofPatterns::Behavioral::State::VendingMachine.new

    assert_instance_of GofPatterns::Behavioral::State::IdleState, machine.state
    assert_equal 0, machine.balance
  end

  def test_vending_machine_add_product
    machine = GofPatterns::Behavioral::State::VendingMachine.new
    machine.add_product('Cola', 150, 10)

    assert machine.product_available?('Cola')
    assert_equal 150, machine.product_price('Cola')
  end

  def test_vending_machine_insert_money
    machine = GofPatterns::Behavioral::State::VendingMachine.new

    result = machine.insert_money(100)

    assert result[:success]
    assert_equal 100, machine.balance
    assert_instance_of GofPatterns::Behavioral::State::HasMoneyState, machine.state
  end

  def test_vending_machine_select_product_no_money
    machine = GofPatterns::Behavioral::State::VendingMachine.new
    machine.add_product('Cola', 150, 10)

    result = machine.select_product('Cola')

    refute result[:success]
    assert_match(/insert money/, result[:message])
  end

  def test_vending_machine_select_product_success
    machine = GofPatterns::Behavioral::State::VendingMachine.new
    machine.add_product('Cola', 150, 10)

    machine.insert_money(200)
    result = machine.select_product('Cola')

    assert result[:success]
    assert_instance_of GofPatterns::Behavioral::State::ProductSelectedState, machine.state
  end

  def test_vending_machine_select_product_insufficient_balance
    machine = GofPatterns::Behavioral::State::VendingMachine.new
    machine.add_product('Cola', 150, 10)

    machine.insert_money(100)
    result = machine.select_product('Cola')

    refute result[:success]
    assert_match(/Insufficient/, result[:message])
  end

  def test_vending_machine_dispense
    machine = GofPatterns::Behavioral::State::VendingMachine.new
    machine.add_product('Cola', 150, 10)

    machine.insert_money(200)
    machine.select_product('Cola')
    result = machine.dispense

    assert result[:success]
    assert_equal 'Cola', result[:product]
    assert_equal 50, result[:change]
    assert_equal 0, machine.balance
    assert_instance_of GofPatterns::Behavioral::State::IdleState, machine.state
  end

  def test_vending_machine_out_of_stock
    machine = GofPatterns::Behavioral::State::VendingMachine.new
    machine.add_product('Cola', 150, 0) # 在庫0

    machine.insert_money(200)
    result = machine.select_product('Cola')

    refute result[:success]
    assert_match(/out of stock/, result[:message])
  end

  def test_vending_machine_refund
    machine = GofPatterns::Behavioral::State::VendingMachine.new

    machine.insert_money(500)
    result = machine.refund

    assert result[:success]
    assert_equal 500, result[:message].match(/¥(\d+)/)[1].to_i
    assert_equal 0, machine.balance
    assert_instance_of GofPatterns::Behavioral::State::IdleState, machine.state
  end

  def test_order_initial_state
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [{ name: 'Item' }], 1000)

    assert_equal 'PendingState', order.current_state
  end

  def test_order_confirm
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)

    result = order.confirm

    assert result[:success]
    assert_equal 'ConfirmedState', order.current_state
  end

  def test_order_ship
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)

    order.confirm
    result = order.ship

    assert result[:success]
    assert_equal 'ShippedState', order.current_state
  end

  def test_order_deliver
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)

    order.confirm
    order.ship
    result = order.deliver

    assert result[:success]
    assert_equal 'DeliveredState', order.current_state
  end

  def test_order_cannot_ship_from_pending
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)

    result = order.ship

    refute result[:success]
  end

  def test_order_cancel_from_pending
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)

    result = order.cancel

    assert result[:success]
    assert_equal 'CancelledState', order.current_state
  end

  def test_order_cancel_from_confirmed
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)
    order.confirm

    result = order.cancel

    assert result[:success]
    assert_equal 'CancelledState', order.current_state
  end

  def test_order_cannot_cancel_from_shipped
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)
    order.confirm
    order.ship

    result = order.cancel

    refute result[:success]
  end

  def test_order_history
    order = GofPatterns::Behavioral::State::Order.new('ORD-001', [], 1000)
    order.confirm
    order.ship

    assert(order.history.any? { |h| h[:action] == 'Confirmed' })
    assert(order.history.any? { |h| h[:action] == 'Shipped' })
  end

  def test_order_service_create
    service = GofPatterns::Behavioral::State::OrderService.new
    order = service.create_order([{ name: 'Item' }], 1000)

    assert_match(/^ORD-/, order.id)
    assert_equal 1000, order.total
  end

  def test_order_service_find
    service = GofPatterns::Behavioral::State::OrderService.new
    order = service.create_order([], 1000)

    found = service.find_order(order.id)

    assert_equal order, found
  end

  def test_order_service_orders_by_state
    service = GofPatterns::Behavioral::State::OrderService.new

    order1 = service.create_order([], 100)
    order2 = service.create_order([], 200)
    service.create_order([], 300)

    order1.confirm
    order2.confirm
    # order3 remains pending

    pending = service.orders_by_state('PendingState')
    confirmed = service.orders_by_state('ConfirmedState')

    assert_equal 1, pending.size
    assert_equal 2, confirmed.size
  end
end
