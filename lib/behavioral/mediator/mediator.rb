# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Mediator Pattern (メディエータパターン)
    # ======================================
    # 目的: オブジェクト間の通信を仲介し、
    #       オブジェクト同士の直接的な参照を避ける
    #
    # DDD Context:
    # - Aggregate 間の調整
    # - Domain Event の配信

    module Mediator
      # Mediator Interface
      class Mediator
        def notify(sender, event, data = nil)
          raise NotImplementedError
        end
      end

      # Colleague Interface
      class Colleague
        attr_accessor :mediator

        def initialize(mediator = nil)
          @mediator = mediator
        end
      end

      # ===== チャットルーム例 =====

      # Value Object: チャットメッセージ
      class ChatMessage
        attr_reader :sender, :content, :timestamp

        def initialize(sender:, content:)
          @sender = sender.freeze
          @content = content.freeze
          @timestamp = Time.now
          freeze
        end

        def to_s
          "[#{timestamp.strftime('%H:%M:%S')}] #{sender}: #{content}"
        end

        def ==(other)
          return false unless other.is_a?(ChatMessage)

          sender == other.sender && content == other.content && timestamp == other.timestamp
        end
        alias eql? ==

        def hash
          [sender, content, timestamp].hash
        end
      end

      # Concrete Mediator: チャットルーム
      class ChatRoom < Mediator
        def initialize
          @users = {}
          @message_history = []
        end

        def register(user)
          @users[user.name] = user
          user.mediator = self
          notify_all(user, :joined)
        end

        def unregister(user)
          @users.delete(user.name)
          user.mediator = nil
          notify_all(user, :left)
        end

        def notify(sender, event, data = nil)
          case event
          when :message
            broadcast_message(sender, data)
          when :private_message
            send_private_message(sender, data[:to], data[:content])
          when :joined
            broadcast_system_message("#{sender.name} joined the room")
          when :left
            broadcast_system_message("#{sender.name} left the room")
          end
        end

        def users
          @users.keys
        end

        def message_history
          @message_history.dup
        end

        private

        def broadcast_message(sender, content)
          message = ChatMessage.new(sender: sender.name, content: content)
          @message_history << message
          @users.each_value do |user|
            user.receive(message) unless user == sender
          end
        end

        def send_private_message(sender, recipient_name, content)
          recipient = @users[recipient_name]
          return unless recipient

          message = ChatMessage.new(sender: "#{sender.name} (private)", content: content)
          recipient.receive(message)
        end

        def broadcast_system_message(content)
          message = ChatMessage.new(sender: 'System', content: content)
          @message_history << message
          @users.each_value { |user| user.receive(message) }
        end

        def notify_all(sender, event)
          @users.each_value do |user|
            notify(sender, event) unless user == sender
          end
        end
      end

      # Concrete Colleague: チャットユーザー
      class ChatUser < Colleague
        attr_reader :name, :received_messages

        def initialize(name, mediator = nil)
          super(mediator)
          @name = name
          @received_messages = []
        end

        def send_message(content)
          @mediator&.notify(self, :message, content)
        end

        def send_private_message(to, content)
          @mediator&.notify(self, :private_message, { to: to, content: content })
        end

        def receive(message)
          @received_messages << message
        end

        def clear_messages
          @received_messages.clear
        end
      end

      # ===== フォームコンポーネント例 =====

      # Concrete Mediator: フォームダイアログ
      class FormDialog < Mediator
        def initialize
          @components = {}
        end

        def register(component)
          @components[component.name] = component
          component.mediator = self
        end

        def notify(sender, event, data = nil)
          case event
          when :text_changed
            handle_text_changed(sender, data)
          when :checkbox_changed
            handle_checkbox_changed(sender, data)
          when :button_clicked
            handle_button_clicked(sender)
          end
        end

        def component(name)
          @components[name]
        end

        private

        def handle_text_changed(sender, text)
          # テキストフィールドの変更に応じてボタンを有効/無効化
          submit_button = @components[:submit_button]
          return unless submit_button

          submit_button.enabled = !text.to_s.empty?
        end

        def handle_checkbox_changed(sender, checked)
          # チェックボックスの変更に応じて関連フィールドを有効/無効化
          related_field = @components["#{sender.name}_related".to_sym]
          return unless related_field

          related_field.enabled = checked
        end

        def handle_button_clicked(sender)
          # ボタンクリックに応じた処理
          case sender.name
          when :submit_button
            validate_and_submit
          when :clear_button
            clear_all_fields
          end
        end

        def validate_and_submit
          # バリデーションとサブミット処理
          @components.each_value do |component|
            next unless component.respond_to?(:validate)

            return false unless component.validate
          end
          true
        end

        def clear_all_fields
          @components.each_value do |component|
            component.clear if component.respond_to?(:clear)
          end
        end
      end

      # UI Component Base
      class UIComponent < Colleague
        attr_reader :name
        attr_accessor :enabled

        def initialize(name, mediator = nil)
          super(mediator)
          @name = name
          @enabled = true
        end
      end

      # Concrete Colleague: テキストフィールド
      class TextField < UIComponent
        attr_reader :text

        def initialize(name, mediator = nil)
          super
          @text = ''
        end

        def set_text(text)
          @text = text
          @mediator&.notify(self, :text_changed, text)
        end

        def clear
          set_text('')
        end

        def validate
          !@text.empty?
        end
      end

      # Concrete Colleague: チェックボックス
      class Checkbox < UIComponent
        attr_reader :checked

        def initialize(name, mediator = nil)
          super
          @checked = false
        end

        def toggle
          @checked = !@checked
          @mediator&.notify(self, :checkbox_changed, @checked)
        end

        def check
          return if @checked

          @checked = true
          @mediator&.notify(self, :checkbox_changed, true)
        end

        def uncheck
          return unless @checked

          @checked = false
          @mediator&.notify(self, :checkbox_changed, false)
        end
      end

      # Concrete Colleague: ボタン
      class Button < UIComponent
        def initialize(name, mediator = nil)
          super
        end

        def click
          return unless @enabled

          @mediator&.notify(self, :button_clicked)
        end
      end

      # ===== 航空管制例 =====

      # Concrete Mediator: 管制塔
      class ControlTower < Mediator
        def initialize
          @flights = {}
          @runway_occupied = false
          @landing_queue = []
        end

        def register(flight)
          @flights[flight.call_sign] = flight
          flight.mediator = self
        end

        def notify(sender, event, data = nil)
          case event
          when :request_landing
            handle_landing_request(sender)
          when :request_takeoff
            handle_takeoff_request(sender)
          when :runway_cleared
            handle_runway_cleared(sender)
          end
        end

        def flights
          @flights.keys
        end

        def queue_length
          @landing_queue.length
        end

        private

        def handle_landing_request(flight)
          if @runway_occupied
            @landing_queue << flight
            flight.receive_message('Runway busy. Added to queue. Position: #{@landing_queue.length}')
          else
            @runway_occupied = true
            flight.receive_message('Cleared for landing')
            flight.land
          end
        end

        def handle_takeoff_request(flight)
          if @runway_occupied
            flight.receive_message('Runway busy. Please hold')
          else
            @runway_occupied = true
            flight.receive_message('Cleared for takeoff')
            flight.takeoff
          end
        end

        def handle_runway_cleared(flight)
          @runway_occupied = false
          next_flight = @landing_queue.shift
          return unless next_flight

          @runway_occupied = true
          next_flight.receive_message('Cleared for landing')
          next_flight.land
        end
      end

      # Concrete Colleague: 航空機
      class Flight < Colleague
        attr_reader :call_sign, :status, :messages

        def initialize(call_sign, mediator = nil)
          super(mediator)
          @call_sign = call_sign
          @status = :in_flight
          @messages = []
        end

        def request_landing
          @mediator&.notify(self, :request_landing)
        end

        def request_takeoff
          @mediator&.notify(self, :request_takeoff)
        end

        def land
          @status = :landed
        end

        def takeoff
          @status = :in_flight
          @mediator&.notify(self, :runway_cleared)
        end

        def clear_runway
          @mediator&.notify(self, :runway_cleared)
        end

        def receive_message(message)
          @messages << message
        end
      end
    end
  end
end
