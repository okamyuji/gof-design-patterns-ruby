# frozen_string_literal: true

module GofPatterns
  module Structural
    # Adapter Pattern (アダプタパターン)
    # ==================================
    # 目的: 互換性のないインターフェースを持つクラスを連携させる
    #
    # DDD Context:
    # - 外部サービスとの統合（Anti-Corruption Layer）
    # - レガシーシステムとの連携

    module Adapter
      # Target Interface: 支払い処理インターフェース
      class PaymentProcessor
        def process_payment(amount, currency)
          raise NotImplementedError
        end

        def refund(transaction_id, amount)
          raise NotImplementedError
        end

        def get_status(transaction_id)
          raise NotImplementedError
        end
      end

      # Value Object: 金額
      class Money
        attr_reader :amount, :currency

        def initialize(amount, currency = 'JPY')
          @amount = amount.to_f.round(2)
          @currency = currency.upcase.freeze
          freeze
        end

        def to_cents
          (amount * 100).to_i
        end

        def ==(other)
          return false unless other.is_a?(Money)

          amount == other.amount && currency == other.currency
        end
        alias eql? ==

        def hash
          [amount, currency].hash
        end

        def to_s
          "#{currency} #{format('%.2f', amount)}"
        end
      end

      # Value Object: トランザクション結果
      class TransactionResult
        attr_reader :transaction_id, :status, :message, :timestamp

        def initialize(transaction_id:, status:, message: nil)
          @transaction_id = transaction_id.freeze
          @status = status.to_sym
          @message = message&.freeze
          @timestamp = Time.now
          freeze
        end

        def success?
          status == :success
        end

        def ==(other)
          return false unless other.is_a?(TransactionResult)

          transaction_id == other.transaction_id
        end
        alias eql? ==

        def hash
          transaction_id.hash
        end
      end

      # Adaptee 1: レガシー決済システム（XML形式）
      class LegacyPaymentSystem
        def execute_transaction(xml_data)
          # レガシーシステムのシミュレーション
          amount = xml_data.match(/<amount>(\d+)<\/amount>/)[1]
          "<response><status>OK</status><ref>LEG-#{SecureRandom.hex(4).upcase}</ref><processed>#{amount}</processed></response>"
        end

        def cancel_transaction(ref_id)
          "<response><status>CANCELLED</status><ref>#{ref_id}</ref></response>"
        end

        def query_status(ref_id)
          "<response><ref>#{ref_id}</ref><state>COMPLETED</state></response>"
        end
      end

      # Adaptee 2: 外部API決済システム（JSON形式）
      class ExternalPaymentApi
        def charge(params)
          {
            id: "EXT-#{SecureRandom.hex(4).upcase}",
            status: 'succeeded',
            amount: params[:amount],
            currency: params[:currency]
          }
        end

        def create_refund(charge_id:, amount:)
          {
            id: "REF-#{SecureRandom.hex(4).upcase}",
            charge: charge_id,
            status: 'succeeded',
            amount: amount
          }
        end

        def retrieve_charge(charge_id)
          {
            id: charge_id,
            status: 'succeeded'
          }
        end
      end

      # Object Adapter: レガシーシステムアダプタ
      class LegacyPaymentAdapter < PaymentProcessor
        def initialize(legacy_system = LegacyPaymentSystem.new)
          @legacy_system = legacy_system
        end

        def process_payment(amount, currency)
          xml_data = build_xml(amount, currency)
          response = @legacy_system.execute_transaction(xml_data)
          parse_response(response)
        end

        def refund(transaction_id, amount)
          response = @legacy_system.cancel_transaction(transaction_id)
          parse_response(response)
        end

        def get_status(transaction_id)
          response = @legacy_system.query_status(transaction_id)
          parse_status_response(response)
        end

        private

        def build_xml(amount, currency)
          "<transaction><amount>#{amount.to_cents}</amount><currency>#{currency}</currency></transaction>"
        end

        def parse_response(xml_response)
          status_match = xml_response.match(/<status>(\w+)<\/status>/)
          ref_match = xml_response.match(/<ref>([^<]+)<\/ref>/)

          status = status_match[1] == 'OK' || status_match[1] == 'CANCELLED' ? :success : :failed
          TransactionResult.new(
            transaction_id: ref_match[1],
            status: status,
            message: "Legacy system response: #{status_match[1]}"
          )
        end

        def parse_status_response(xml_response)
          ref_match = xml_response.match(/<ref>([^<]+)<\/ref>/)
          state_match = xml_response.match(/<state>(\w+)<\/state>/)

          status = state_match[1] == 'COMPLETED' ? :success : :pending
          TransactionResult.new(
            transaction_id: ref_match[1],
            status: status,
            message: "State: #{state_match[1]}"
          )
        end
      end

      # Object Adapter: 外部API用アダプタ
      class ExternalApiAdapter < PaymentProcessor
        def initialize(api_client = ExternalPaymentApi.new)
          @api_client = api_client
        end

        def process_payment(amount, currency)
          response = @api_client.charge(
            amount: amount.to_cents,
            currency: currency
          )
          map_to_result(response)
        end

        def refund(transaction_id, amount)
          response = @api_client.create_refund(
            charge_id: transaction_id,
            amount: amount.to_cents
          )
          map_to_result(response)
        end

        def get_status(transaction_id)
          response = @api_client.retrieve_charge(transaction_id)
          map_to_result(response)
        end

        private

        def map_to_result(response)
          status = response[:status] == 'succeeded' ? :success : :failed
          TransactionResult.new(
            transaction_id: response[:id],
            status: status,
            message: "API response status: #{response[:status]}"
          )
        end
      end

      # Class Adapter: 継承を使用したアダプタ（Ruby Module版）
      module PaymentAdapterMixin
        def process_payment(amount, currency)
          raise NotImplementedError
        end

        def refund(transaction_id, amount)
          raise NotImplementedError
        end
      end

      # Domain Service: 支払いファサード
      class PaymentService
        ADAPTERS = {
          legacy: LegacyPaymentAdapter,
          external: ExternalApiAdapter
        }.freeze

        def initialize(adapter_type: :external)
          @adapter = ADAPTERS.fetch(adapter_type).new
        end

        def pay(amount, currency = 'JPY')
          money = Money.new(amount, currency)
          @adapter.process_payment(money, currency)
        end

        def refund(transaction_id, amount, currency = 'JPY')
          money = Money.new(amount, currency)
          @adapter.refund(transaction_id, money)
        end

        def status(transaction_id)
          @adapter.get_status(transaction_id)
        end
      end
    end
  end
end

require 'securerandom'
