# frozen_string_literal: true

module GofPatterns
  module Structural
    # Facade Pattern (ファサードパターン)
    # ==================================
    # 目的: 複雑なサブシステムに対する単純なインターフェースを提供する
    #
    # DDD Context:
    # - Application Service として実装
    # - 複数のドメインサービスを統合するユースケース

    module Facade
      # サブシステム1: 在庫管理
      class InventorySystem
        def initialize
          @stock = Hash.new(0)
        end

        def add_stock(product_id, quantity)
          @stock[product_id] += quantity
          { success: true, product_id: product_id, new_quantity: @stock[product_id] }
        end

        def check_availability(product_id, quantity)
          @stock[product_id] >= quantity
        end

        def reserve(product_id, quantity)
          return { success: false, error: 'Insufficient stock' } unless check_availability(product_id, quantity)

          @stock[product_id] -= quantity
          { success: true, product_id: product_id, reserved: quantity, remaining: @stock[product_id] }
        end

        def release(product_id, quantity)
          @stock[product_id] += quantity
          { success: true, product_id: product_id, released: quantity }
        end

        def get_stock(product_id)
          @stock[product_id]
        end
      end

      # サブシステム2: 支払い処理
      class PaymentSystem
        def initialize
          @transactions = {}
        end

        def process_payment(order_id, amount, payment_method)
          transaction_id = "TXN-#{SecureRandom.hex(4).upcase}"
          @transactions[transaction_id] = {
            order_id: order_id,
            amount: amount,
            method: payment_method,
            status: :completed,
            timestamp: Time.now
          }
          { success: true, transaction_id: transaction_id, amount: amount }
        end

        def refund(transaction_id, amount = nil)
          transaction = @transactions[transaction_id]
          return { success: false, error: 'Transaction not found' } unless transaction

          refund_amount = amount || transaction[:amount]
          { success: true, transaction_id: transaction_id, refunded: refund_amount }
        end

        def get_transaction(transaction_id)
          @transactions[transaction_id]
        end
      end

      # サブシステム3: 配送管理
      class ShippingSystem
        def initialize
          @shipments = {}
        end

        def calculate_shipping(address, weight)
          base_rate = 500
          weight_rate = weight * 10
          { cost: base_rate + weight_rate, estimated_days: 3 }
        end

        def create_shipment(order_id, address, items)
          tracking_number = "SHIP-#{SecureRandom.hex(6).upcase}"
          @shipments[tracking_number] = {
            order_id: order_id,
            address: address,
            items: items,
            status: :pending,
            created_at: Time.now
          }
          { success: true, tracking_number: tracking_number }
        end

        def update_status(tracking_number, status)
          shipment = @shipments[tracking_number]
          return { success: false, error: 'Shipment not found' } unless shipment

          shipment[:status] = status
          { success: true, tracking_number: tracking_number, status: status }
        end

        def get_shipment(tracking_number)
          @shipments[tracking_number]
        end
      end

      # サブシステム4: 通知サービス
      class NotificationService
        def initialize
          @notifications = []
        end

        def send_email(recipient, subject, body)
          notification = {
            type: :email,
            recipient: recipient,
            subject: subject,
            body: body,
            sent_at: Time.now
          }
          @notifications << notification
          { success: true, type: :email, recipient: recipient }
        end

        def send_sms(phone, message)
          notification = {
            type: :sms,
            recipient: phone,
            message: message,
            sent_at: Time.now
          }
          @notifications << notification
          { success: true, type: :sms, recipient: phone }
        end

        def notifications
          @notifications.dup
        end
      end

      # Value Object: 注文アイテム
      class OrderItem
        attr_reader :product_id, :name, :quantity, :unit_price

        def initialize(product_id:, name:, quantity:, unit_price:)
          @product_id = product_id.freeze
          @name = name.freeze
          @quantity = quantity
          @unit_price = unit_price
          freeze
        end

        def total_price
          quantity * unit_price
        end

        def ==(other)
          return false unless other.is_a?(OrderItem)

          product_id == other.product_id && quantity == other.quantity
        end
        alias eql? ==

        def hash
          [product_id, quantity].hash
        end
      end

      # Value Object: 配送先住所
      class ShippingAddress
        attr_reader :name, :postal_code, :address, :phone

        def initialize(name:, postal_code:, address:, phone:)
          @name = name.freeze
          @postal_code = postal_code.freeze
          @address = address.freeze
          @phone = phone.freeze
          freeze
        end

        def full_address
          "〒#{postal_code} #{address}"
        end

        def ==(other)
          return false unless other.is_a?(ShippingAddress)

          postal_code == other.postal_code && address == other.address
        end
        alias eql? ==

        def hash
          [postal_code, address].hash
        end
      end

      # Entity: 注文
      class Order
        attr_reader :id, :items, :shipping_address, :status, :created_at
        attr_accessor :transaction_id, :tracking_number

        def initialize(id:, items:, shipping_address:)
          @id = id
          @items = items.freeze
          @shipping_address = shipping_address
          @status = :pending
          @created_at = Time.now
          @transaction_id = nil
          @tracking_number = nil
        end

        def total_amount
          items.sum(&:total_price)
        end

        def total_weight
          items.sum(&:quantity) * 0.5 # 仮の重量計算
        end

        def update_status(new_status)
          @status = new_status
        end

        def ==(other)
          return false unless other.is_a?(Order)

          id == other.id
        end
        alias eql? ==

        def hash
          id.hash
        end
      end

      # ========================================
      # Facade: ECサービスファサード
      # ========================================
      # 複雑なサブシステムを統合し、シンプルなインターフェースを提供
      class ECommerceService
        def initialize
          @inventory = InventorySystem.new
          @payment = PaymentSystem.new
          @shipping = ShippingSystem.new
          @notification = NotificationService.new
          @orders = {}
        end

        # 在庫追加（管理用）
        def add_inventory(product_id, quantity)
          @inventory.add_stock(product_id, quantity)
        end

        # 注文処理（ファサードメソッド）
        # 複雑なサブシステムの連携をカプセル化
        def place_order(items:, shipping_address:, payment_method:, customer_email:)
          order_id = generate_order_id

          # 1. 在庫確認と予約
          items.each do |item|
            unless @inventory.check_availability(item.product_id, item.quantity)
              return { success: false, error: "Product #{item.product_id} is out of stock" }
            end
          end

          items.each do |item|
            @inventory.reserve(item.product_id, item.quantity)
          end

          # 2. 注文作成
          order = Order.new(id: order_id, items: items, shipping_address: shipping_address)
          @orders[order_id] = order

          # 3. 支払い処理
          payment_result = @payment.process_payment(order_id, order.total_amount, payment_method)
          unless payment_result[:success]
            # 支払い失敗時は在庫を戻す
            items.each { |item| @inventory.release(item.product_id, item.quantity) }
            return { success: false, error: 'Payment failed' }
          end
          order.transaction_id = payment_result[:transaction_id]

          # 4. 配送手配
          shipping_result = @shipping.create_shipment(
            order_id,
            shipping_address.full_address,
            items.map { |i| { product_id: i.product_id, quantity: i.quantity } }
          )
          order.tracking_number = shipping_result[:tracking_number]

          # 5. 注文確認通知
          @notification.send_email(
            customer_email,
            "注文確認 ##{order_id}",
            "ご注文ありがとうございます。追跡番号: #{order.tracking_number}"
          )

          order.update_status(:confirmed)

          {
            success: true,
            order_id: order_id,
            transaction_id: order.transaction_id,
            tracking_number: order.tracking_number,
            total_amount: order.total_amount
          }
        end

        # 注文キャンセル（ファサードメソッド）
        def cancel_order(order_id, customer_email:)
          order = @orders[order_id]
          return { success: false, error: 'Order not found' } unless order
          return { success: false, error: 'Order cannot be cancelled' } if order.status == :shipped

          # 1. 返金処理
          @payment.refund(order.transaction_id)

          # 2. 在庫戻し
          order.items.each do |item|
            @inventory.release(item.product_id, item.quantity)
          end

          # 3. 配送キャンセル
          @shipping.update_status(order.tracking_number, :cancelled)

          # 4. キャンセル通知
          @notification.send_email(
            customer_email,
            "注文キャンセル ##{order_id}",
            'ご注文はキャンセルされました。返金処理を行います。'
          )

          order.update_status(:cancelled)

          { success: true, order_id: order_id, status: :cancelled }
        end

        # 注文状況確認
        def get_order_status(order_id)
          order = @orders[order_id]
          return nil unless order

          shipment = @shipping.get_shipment(order.tracking_number)
          {
            order_id: order.id,
            status: order.status,
            tracking_number: order.tracking_number,
            shipping_status: shipment&.dig(:status),
            total_amount: order.total_amount
          }
        end

        # 配送料金見積もり
        def estimate_shipping(address, items)
          total_weight = items.sum(&:quantity) * 0.5
          @shipping.calculate_shipping(address.full_address, total_weight)
        end

        private

        def generate_order_id
          "ORD-#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
        end
      end
    end
  end
end

require 'securerandom'
