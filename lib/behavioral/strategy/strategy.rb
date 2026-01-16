# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Strategy Pattern (ストラテジパターン)
    # ====================================
    # 目的: アルゴリズムをカプセル化し、
    #       実行時に交換可能にする
    #
    # DDD Context:
    # - ビジネスルールの実装切り替え
    # - 計算ロジックの差し替え

    module Strategy
      # Strategy Interface
      class Strategy
        def execute(*_args)
          raise NotImplementedError
        end
      end

      # ===== 支払い戦略の例 =====

      # Value Object: 支払い結果
      class PaymentResult
        attr_reader :success, :transaction_id, :amount, :fee, :message

        def initialize(success:, transaction_id: nil, amount: 0, fee: 0, message: nil)
          @success = success
          @transaction_id = transaction_id&.freeze
          @amount = amount
          @fee = fee
          @message = message&.freeze
          freeze
        end

        def success?
          success
        end

        def total
          amount + fee
        end

        def ==(other)
          return false unless other.is_a?(PaymentResult)

          success == other.success && transaction_id == other.transaction_id
        end
        alias eql? ==

        def hash
          [success, transaction_id].hash
        end
      end

      # Strategy Interface: 支払い戦略
      class PaymentStrategy < Strategy
        def pay(_amount)
          raise NotImplementedError
        end

        def name
          raise NotImplementedError
        end

        def fee_for(_amount)
          raise NotImplementedError
        end
      end

      # Concrete Strategy: クレジットカード支払い
      class CreditCardPayment < PaymentStrategy
        def initialize(card_number:, expiry:, cvv:)
          @card_number = card_number
          @expiry = expiry
          @cvv = cvv
        end

        def pay(amount)
          fee = fee_for(amount)
          # 支払い処理のシミュレーション
          PaymentResult.new(
            success: true,
            transaction_id: "CC-#{SecureRandom.hex(6).upcase}",
            amount: amount,
            fee: fee,
            message: "Credit card payment of ¥#{amount} processed"
          )
        end

        def name
          'Credit Card'
        end

        def fee_for(amount)
          (amount * 0.03).round # 3% 手数料
        end

        def masked_card_number
          "****-****-****-#{@card_number[-4..]}"
        end
      end

      # Concrete Strategy: PayPal支払い
      class PayPalPayment < PaymentStrategy
        def initialize(email:)
          @email = email
        end

        def pay(amount)
          fee = fee_for(amount)
          PaymentResult.new(
            success: true,
            transaction_id: "PP-#{SecureRandom.hex(6).upcase}",
            amount: amount,
            fee: fee,
            message: "PayPal payment of ¥#{amount} to #{@email}"
          )
        end

        def name
          'PayPal'
        end

        def fee_for(amount)
          (amount * 0.04).round + 40 # 4% + ¥40
        end
      end

      # Concrete Strategy: 銀行振込
      class BankTransferPayment < PaymentStrategy
        def initialize(bank_code:, account_number:)
          @bank_code = bank_code
          @account_number = account_number
        end

        def pay(amount)
          fee = fee_for(amount)
          PaymentResult.new(
            success: true,
            transaction_id: "BT-#{SecureRandom.hex(6).upcase}",
            amount: amount,
            fee: fee,
            message: "Bank transfer of ¥#{amount} initiated"
          )
        end

        def name
          'Bank Transfer'
        end

        def fee_for(_amount)
          330 # 固定手数料
        end
      end

      # Concrete Strategy: 代金引換
      class CashOnDeliveryPayment < PaymentStrategy
        def pay(amount)
          fee = fee_for(amount)
          PaymentResult.new(
            success: true,
            transaction_id: "COD-#{SecureRandom.hex(6).upcase}",
            amount: amount,
            fee: fee,
            message: "Cash on delivery order of ¥#{amount} created"
          )
        end

        def name
          'Cash on Delivery'
        end

        def fee_for(amount)
          case amount
          when 0..9999 then 330
          when 10_000..29_999 then 440
          else 660
          end
        end
      end

      # Context: 支払い処理
      class PaymentProcessor
        attr_accessor :strategy

        def initialize(strategy = nil)
          @strategy = strategy
        end

        def process_payment(amount)
          raise 'Payment strategy not set' unless @strategy

          @strategy.pay(amount)
        end

        def calculate_fee(amount)
          raise 'Payment strategy not set' unless @strategy

          @strategy.fee_for(amount)
        end

        def payment_method_name
          @strategy&.name
        end
      end

      # ===== ソート戦略の例 =====

      # Strategy Interface: ソート戦略
      class SortStrategy < Strategy
        def sort(_array)
          raise NotImplementedError
        end

        def name
          raise NotImplementedError
        end
      end

      # Concrete Strategy: バブルソート
      class BubbleSort < SortStrategy
        def sort(array)
          arr = array.dup
          n = arr.length
          (n - 1).times do |i|
            (n - 1 - i).times do |j|
              arr[j], arr[j + 1] = arr[j + 1], arr[j] if arr[j] > arr[j + 1]
            end
          end
          arr
        end

        def name
          'Bubble Sort'
        end
      end

      # Concrete Strategy: クイックソート
      class QuickSort < SortStrategy
        def sort(array)
          return array if array.length <= 1

          pivot = array[array.length / 2]
          left = array.select { |x| x < pivot }
          middle = array.select { |x| x == pivot }
          right = array.select { |x| x > pivot }
          sort(left) + middle + sort(right)
        end

        def name
          'Quick Sort'
        end
      end

      # Concrete Strategy: マージソート
      class MergeSort < SortStrategy
        def sort(array)
          return array if array.length <= 1

          mid = array.length / 2
          left = sort(array[0...mid])
          right = sort(array[mid..])
          merge(left, right)
        end

        def name
          'Merge Sort'
        end

        private

        def merge(left, right)
          result = []
          result << (left.first <= right.first ? left.shift : right.shift) until left.empty? || right.empty?
          result + left + right
        end
      end

      # Concrete Strategy: 標準ソート（Ruby組み込み）
      class StandardSort < SortStrategy
        def sort(array)
          array.sort
        end

        def name
          'Standard Sort'
        end
      end

      # Context: ソーター
      class Sorter
        attr_accessor :strategy

        def initialize(strategy = StandardSort.new)
          @strategy = strategy
        end

        def sort(array)
          @strategy.sort(array)
        end

        def algorithm_name
          @strategy.name
        end
      end

      # ===== 圧縮戦略の例 =====

      # Strategy Interface: 圧縮戦略
      class CompressionStrategy < Strategy
        def compress(_data)
          raise NotImplementedError
        end

        def decompress(_data)
          raise NotImplementedError
        end

        def name
          raise NotImplementedError
        end
      end

      # Concrete Strategy: Base64エンコード（簡易圧縮）
      class Base64Compression < CompressionStrategy
        def compress(data)
          [data].pack('m0')
        end

        def decompress(data)
          data.unpack1('m0')
        end

        def name
          'Base64'
        end
      end

      # Concrete Strategy: Run-Length Encoding
      class RLECompression < CompressionStrategy
        def compress(data)
          data.chars.chunk(&:itself).map { |char, arr| "#{arr.length}#{char}" }.join
        end

        def decompress(data)
          data.scan(/(\d+)(.)/).map { |count, char| char * count.to_i }.join
        end

        def name
          'RLE'
        end
      end

      # Context: データ圧縮器
      class DataCompressor
        attr_accessor :strategy

        def initialize(strategy = Base64Compression.new)
          @strategy = strategy
        end

        def compress(data)
          @strategy.compress(data)
        end

        def decompress(data)
          @strategy.decompress(data)
        end

        def compression_name
          @strategy.name
        end
      end

      # Domain Service: 支払いファクトリ
      class PaymentStrategyFactory
        def self.create(method, **options)
          case method.to_sym
          when :credit_card
            CreditCardPayment.new(
              card_number: options[:card_number],
              expiry: options[:expiry],
              cvv: options[:cvv]
            )
          when :paypal
            PayPalPayment.new(email: options[:email])
          when :bank_transfer
            BankTransferPayment.new(
              bank_code: options[:bank_code],
              account_number: options[:account_number]
            )
          when :cod
            CashOnDeliveryPayment.new
          else
            raise ArgumentError, "Unknown payment method: #{method}"
          end
        end
      end
    end
  end
end

require 'securerandom'
