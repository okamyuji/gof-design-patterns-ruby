# frozen_string_literal: true

module GofPatterns
  module Structural
    # Bridge Pattern (ブリッジパターン)
    # ================================
    # 目的: 抽象と実装を分離し、それぞれを独立して変更可能にする
    #
    # DDD Context:
    # - Repository の抽象と具象実装の分離
    # - 通知システムの抽象化

    module Bridge
      # Implementation Interface: メッセージ送信者
      class MessageSender
        def send_message(recipient, subject, body)
          raise NotImplementedError
        end

        def sender_type
          raise NotImplementedError
        end
      end

      # Concrete Implementation: Email送信者
      class EmailSender < MessageSender
        def initialize(smtp_server: 'localhost', port: 25)
          @smtp_server = smtp_server
          @port = port
        end

        def send_message(recipient, subject, _body)
          MessageDeliveryResult.new(
            success: true,
            channel: :email,
            recipient: recipient,
            details: "Email '#{subject}' sent to #{recipient} via #{@smtp_server}:#{@port}"
          )
        end

        def sender_type
          :email
        end
      end

      # Concrete Implementation: SMS送信者
      class SmsSender < MessageSender
        def initialize(api_key: 'demo-key')
          @api_key = api_key
        end

        def send_message(recipient, _subject, body)
          # SMSは件名なしでボディのみ送信
          truncated = body.length > 160 ? "#{body[0..156]}..." : body
          MessageDeliveryResult.new(
            success: true,
            channel: :sms,
            recipient: recipient,
            details: "SMS (#{truncated.length} chars) sent to #{recipient}"
          )
        end

        def sender_type
          :sms
        end
      end

      # Concrete Implementation: Push通知送信者
      class PushNotificationSender < MessageSender
        def initialize(app_id: 'demo-app')
          @app_id = app_id
        end

        def send_message(recipient, subject, _body)
          MessageDeliveryResult.new(
            success: true,
            channel: :push,
            recipient: recipient,
            details: "Push notification '#{subject}' sent to device #{recipient}"
          )
        end

        def sender_type
          :push
        end
      end

      # Concrete Implementation: Slack送信者
      class SlackSender < MessageSender
        def initialize(webhook_url: 'https://hooks.slack.com/demo')
          @webhook_url = webhook_url
        end

        def send_message(recipient, subject, _body)
          MessageDeliveryResult.new(
            success: true,
            channel: :slack,
            recipient: recipient,
            details: "Slack message posted to ##{recipient}: #{subject}"
          )
        end

        def sender_type
          :slack
        end
      end

      # Value Object: メッセージ配信結果
      class MessageDeliveryResult
        attr_reader :success, :channel, :recipient, :details, :timestamp

        def initialize(success:, channel:, recipient:, details:)
          @success = success
          @channel = channel.to_sym
          @recipient = recipient.freeze
          @details = details.freeze
          @timestamp = Time.now
          freeze
        end

        def success?
          success
        end

        def ==(other)
          return false unless other.is_a?(MessageDeliveryResult)

          channel == other.channel &&
            recipient == other.recipient &&
            timestamp == other.timestamp
        end
        alias eql? ==

        def hash
          [channel, recipient, timestamp].hash
        end
      end

      # Abstraction: 通知（抽象）
      class Notification
        def initialize(sender)
          @sender = sender
        end

        def notify(recipient, message)
          raise NotImplementedError
        end

        protected

        attr_reader :sender
      end

      # Refined Abstraction: 緊急通知
      class UrgentNotification < Notification
        def notify(recipient, message)
          subject = "[URGENT] #{message[:subject] || 'Important Notice'}"
          body = "!!! URGENT !!!\n\n#{message[:body]}\n\nPlease respond immediately."
          sender.send_message(recipient, subject, body)
        end
      end

      # Refined Abstraction: 通常通知
      class RegularNotification < Notification
        def notify(recipient, message)
          subject = message[:subject] || 'Notification'
          body = message[:body] || ''
          sender.send_message(recipient, subject, body)
        end
      end

      # Refined Abstraction: 予約通知
      class ScheduledNotification < Notification
        def initialize(sender, scheduled_at:)
          super(sender)
          @scheduled_at = scheduled_at
        end

        def notify(recipient, message)
          subject = "[Scheduled: #{@scheduled_at}] #{message[:subject]}"
          body = "This message was scheduled for #{@scheduled_at}.\n\n#{message[:body]}"
          sender.send_message(recipient, subject, body)
        end
      end

      # Refined Abstraction: バッチ通知
      class BatchNotification < Notification
        def notify_batch(recipients, message)
          recipients.map do |recipient|
            sender.send_message(recipient, message[:subject], message[:body])
          end
        end

        def notify(recipient, message)
          notify_batch([recipient], message).first
        end
      end

      # Domain Service: 通知サービス
      class NotificationService
        SENDERS = {
          email: EmailSender,
          sms: SmsSender,
          push: PushNotificationSender,
          slack: SlackSender
        }.freeze

        NOTIFICATION_TYPES = {
          urgent: UrgentNotification,
          regular: RegularNotification,
          scheduled: ScheduledNotification,
          batch: BatchNotification
        }.freeze

        def initialize
          @senders = {}
        end

        def register_sender(type, sender)
          @senders[type.to_sym] = sender
        end

        def create_notification(sender_type:, notification_type:, **options)
          sender = @senders[sender_type] || SENDERS.fetch(sender_type).new
          notification_class = NOTIFICATION_TYPES.fetch(notification_type)

          if notification_type == :scheduled
            notification_class.new(sender, scheduled_at: options[:scheduled_at])
          else
            notification_class.new(sender)
          end
        end

        def send_notification(recipient:, message:, sender_type:, notification_type: :regular, **)
          notification = create_notification(
            sender_type: sender_type,
            notification_type: notification_type,
            **
          )
          notification.notify(recipient, message)
        end
      end
    end
  end
end
