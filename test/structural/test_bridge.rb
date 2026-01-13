# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/bridge/bridge'

class TestBridge < GofPatternTest
  def test_email_sender
    sender = GofPatterns::Structural::Bridge::EmailSender.new
    result = sender.send_message('test@example.com', 'Subject', 'Body')

    assert result.success?
    assert_equal :email, result.channel
    assert_equal 'test@example.com', result.recipient
  end

  def test_sms_sender
    sender = GofPatterns::Structural::Bridge::SmsSender.new
    result = sender.send_message('090-1234-5678', 'Subject', 'Short message')

    assert result.success?
    assert_equal :sms, result.channel
  end

  def test_sms_sender_truncates_long_messages
    sender = GofPatterns::Structural::Bridge::SmsSender.new
    long_message = 'A' * 200
    result = sender.send_message('090-1234-5678', 'Subject', long_message)

    assert result.success?
    assert_match(/160 chars/, result.details)
  end

  def test_push_notification_sender
    sender = GofPatterns::Structural::Bridge::PushNotificationSender.new
    result = sender.send_message('device-123', 'Alert', 'Push message')

    assert result.success?
    assert_equal :push, result.channel
  end

  def test_slack_sender
    sender = GofPatterns::Structural::Bridge::SlackSender.new
    result = sender.send_message('general', 'Notice', 'Slack message')

    assert result.success?
    assert_equal :slack, result.channel
  end

  def test_urgent_notification
    sender = GofPatterns::Structural::Bridge::EmailSender.new
    notification = GofPatterns::Structural::Bridge::UrgentNotification.new(sender)

    result = notification.notify('test@example.com', { subject: 'Test', body: 'Content' })

    assert result.success?
    assert_match(/URGENT/, result.details)
  end

  def test_regular_notification
    sender = GofPatterns::Structural::Bridge::SmsSender.new
    notification = GofPatterns::Structural::Bridge::RegularNotification.new(sender)

    result = notification.notify('090-1234-5678', { subject: 'Hello', body: 'Message' })

    assert result.success?
  end

  def test_scheduled_notification
    sender = GofPatterns::Structural::Bridge::EmailSender.new
    scheduled_time = Time.now + 3600
    notification = GofPatterns::Structural::Bridge::ScheduledNotification.new(sender, scheduled_at: scheduled_time)

    result = notification.notify('test@example.com', { subject: 'Later', body: 'Content' })

    assert result.success?
  end

  def test_batch_notification
    sender = GofPatterns::Structural::Bridge::EmailSender.new
    notification = GofPatterns::Structural::Bridge::BatchNotification.new(sender)

    recipients = ['a@example.com', 'b@example.com', 'c@example.com']
    results = notification.notify_batch(recipients, { subject: 'Batch', body: 'Message' })

    assert_equal 3, results.size
    assert results.all?(&:success?)
  end

  def test_notification_service_create
    service = GofPatterns::Structural::Bridge::NotificationService.new
    notification = service.create_notification(
      sender_type: :email,
      notification_type: :urgent
    )

    assert_instance_of GofPatterns::Structural::Bridge::UrgentNotification, notification
  end

  def test_notification_service_send
    service = GofPatterns::Structural::Bridge::NotificationService.new
    result = service.send_notification(
      recipient: 'test@example.com',
      message: { subject: 'Test', body: 'Content' },
      sender_type: :email,
      notification_type: :regular
    )

    assert result.success?
  end

  def test_message_delivery_result_value_object
    result1 = GofPatterns::Structural::Bridge::MessageDeliveryResult.new(
      success: true,
      channel: :email,
      recipient: 'test@example.com',
      details: 'OK'
    )

    assert result1.success?
    assert_equal :email, result1.channel
    assert result1.frozen?
  end
end
