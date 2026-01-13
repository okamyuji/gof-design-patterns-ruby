# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # State Pattern (ステートパターン)
    # ================================
    # 目的: オブジェクトの内部状態が変化したときに、
    #       その振る舞いを変更する
    #
    # DDD Context:
    # - Entity のライフサイクル管理
    # - ワークフローの状態遷移

    module State
      # State Interface
      class State
        def handle(_context)
          raise NotImplementedError
        end

        def name
          self.class.name.split('::').last
        end
      end

      # Context Interface
      class Context
        attr_reader :state

        def initialize(initial_state)
          transition_to(initial_state)
        end

        def transition_to(state)
          @state = state
          @state.context = self if @state.respond_to?(:context=)
        end

        def request
          @state.handle(self)
        end
      end

      # ===== 自動販売機の例 =====

      # Context: 自動販売機
      class VendingMachine < Context
        attr_reader :balance, :inventory, :selected_product

        def initialize
          @balance = 0
          @inventory = {}
          @selected_product = nil
          super(IdleState.new)
        end

        def add_product(name, price, quantity)
          @inventory[name] = { price: price, quantity: quantity }
        end

        def insert_money(amount)
          @state.insert_money(self, amount)
        end

        def select_product(name)
          @state.select_product(self, name)
        end

        def dispense
          @state.dispense(self)
        end

        def refund
          @state.refund(self)
        end

        def add_balance(amount)
          @balance += amount
        end

        def reset_balance
          refunded = @balance
          @balance = 0
          refunded
        end

        def set_selected_product(name)
          @selected_product = name
        end

        def clear_selected_product
          @selected_product = nil
        end

        def product_available?(name)
          @inventory[name] && @inventory[name][:quantity].positive?
        end

        def product_price(name)
          @inventory[name]&.dig(:price)
        end

        def decrease_inventory(name)
          @inventory[name][:quantity] -= 1 if @inventory[name]
        end
      end

      # Base State for Vending Machine
      class VendingState < State
        attr_accessor :context

        def insert_money(_machine, _amount)
          raise NotImplementedError
        end

        def select_product(_machine, _name)
          raise NotImplementedError
        end

        def dispense(_machine)
          raise NotImplementedError
        end

        def refund(_machine)
          raise NotImplementedError
        end
      end

      # Concrete State: 待機状態
      class IdleState < VendingState
        def insert_money(machine, amount)
          machine.add_balance(amount)
          machine.transition_to(HasMoneyState.new)
          { success: true, message: "Inserted ¥#{amount}. Balance: ¥#{machine.balance}" }
        end

        def select_product(_machine, _name)
          { success: false, message: 'Please insert money first' }
        end

        def dispense(_machine)
          { success: false, message: 'Please insert money and select a product' }
        end

        def refund(_machine)
          { success: false, message: 'No money to refund' }
        end
      end

      # Concrete State: 入金済み状態
      class HasMoneyState < VendingState
        def insert_money(machine, amount)
          machine.add_balance(amount)
          { success: true, message: "Added ¥#{amount}. Balance: ¥#{machine.balance}" }
        end

        def select_product(machine, name)
          unless machine.product_available?(name)
            return { success: false, message: "#{name} is out of stock" }
          end

          price = machine.product_price(name)
          if machine.balance < price
            return { success: false, message: "Insufficient balance. Need ¥#{price}, have ¥#{machine.balance}" }
          end

          machine.set_selected_product(name)
          machine.transition_to(ProductSelectedState.new)
          { success: true, message: "Selected #{name}. Press dispense to get your product" }
        end

        def dispense(_machine)
          { success: false, message: 'Please select a product first' }
        end

        def refund(machine)
          amount = machine.reset_balance
          machine.transition_to(IdleState.new)
          { success: true, message: "Refunded ¥#{amount}" }
        end
      end

      # Concrete State: 商品選択済み状態
      class ProductSelectedState < VendingState
        def insert_money(machine, amount)
          machine.add_balance(amount)
          { success: true, message: "Added ¥#{amount}. Balance: ¥#{machine.balance}" }
        end

        def select_product(machine, name)
          unless machine.product_available?(name)
            return { success: false, message: "#{name} is out of stock" }
          end

          price = machine.product_price(name)
          if machine.balance < price
            return { success: false, message: "Insufficient balance for #{name}" }
          end

          machine.set_selected_product(name)
          { success: true, message: "Changed selection to #{name}" }
        end

        def dispense(machine)
          product = machine.selected_product
          price = machine.product_price(product)

          machine.decrease_inventory(product)
          change = machine.balance - price
          machine.reset_balance
          machine.clear_selected_product

          machine.transition_to(IdleState.new)
          { success: true, message: "Dispensed #{product}. Change: ¥#{change}", product: product, change: change }
        end

        def refund(machine)
          amount = machine.reset_balance
          machine.clear_selected_product
          machine.transition_to(IdleState.new)
          { success: true, message: "Refunded ¥#{amount}" }
        end
      end

      # ===== 注文ステータスの例 =====

      # Context: 注文
      class Order < Context
        attr_reader :id, :items, :total, :history

        def initialize(id, items, total)
          @id = id
          @items = items
          @total = total
          @history = []
          super(PendingState.new)
          record_state_change('Order created')
        end

        def confirm
          result = @state.confirm(self)
          record_state_change('Confirmed') if result[:success]
          result
        end

        def ship
          result = @state.ship(self)
          record_state_change('Shipped') if result[:success]
          result
        end

        def deliver
          result = @state.deliver(self)
          record_state_change('Delivered') if result[:success]
          result
        end

        def cancel
          result = @state.cancel(self)
          record_state_change('Cancelled') if result[:success]
          result
        end

        def current_state
          @state.name
        end

        private

        def record_state_change(action)
          @history << { action: action, state: @state.name, timestamp: Time.now }
        end
      end

      # Base State for Order
      class OrderState < State
        attr_accessor :context

        def confirm(_order)
          { success: false, message: "Cannot confirm order in #{name} state" }
        end

        def ship(_order)
          { success: false, message: "Cannot ship order in #{name} state" }
        end

        def deliver(_order)
          { success: false, message: "Cannot deliver order in #{name} state" }
        end

        def cancel(_order)
          { success: false, message: "Cannot cancel order in #{name} state" }
        end
      end

      # Concrete State: 保留中
      class PendingState < OrderState
        def confirm(order)
          order.transition_to(ConfirmedState.new)
          { success: true, message: 'Order confirmed' }
        end

        def cancel(order)
          order.transition_to(CancelledState.new)
          { success: true, message: 'Order cancelled' }
        end
      end

      # Concrete State: 確認済み
      class ConfirmedState < OrderState
        def ship(order)
          order.transition_to(ShippedState.new)
          { success: true, message: 'Order shipped' }
        end

        def cancel(order)
          order.transition_to(CancelledState.new)
          { success: true, message: 'Order cancelled' }
        end
      end

      # Concrete State: 発送済み
      class ShippedState < OrderState
        def deliver(order)
          order.transition_to(DeliveredState.new)
          { success: true, message: 'Order delivered' }
        end
      end

      # Concrete State: 配達済み
      class DeliveredState < OrderState
        # 最終状態 - 変更不可
      end

      # Concrete State: キャンセル済み
      class CancelledState < OrderState
        # 最終状態 - 変更不可
      end

      # Domain Service: 注文サービス
      class OrderService
        def initialize
          @orders = {}
          @next_id = 1
        end

        def create_order(items, total)
          id = "ORD-#{@next_id.to_s.rjust(6, '0')}"
          @next_id += 1
          order = Order.new(id, items, total)
          @orders[id] = order
          order
        end

        def find_order(id)
          @orders[id]
        end

        def all_orders
          @orders.values
        end

        def orders_by_state(state_name)
          @orders.values.select { |o| o.current_state == state_name }
        end
      end
    end
  end
end
