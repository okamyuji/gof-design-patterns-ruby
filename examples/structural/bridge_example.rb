#!/usr/bin/env ruby
# frozen_string_literal: true

# Bridge Pattern Example
# ======================
# ブリッジパターン: 抽象と実装を分離し、それぞれを独立して変更可能にする
#
# Usage: ruby examples/structural/bridge_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Bridge = GofPatterns::Structural::Bridge

puts '=' * 60
puts 'Bridge Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Simple Notifications
# ========================================
puts '--- Example 1: Simple Notifications ---'
puts

email_sender = Bridge::EmailSender.new
email_notification = Bridge::RegularNotification.new(email_sender)
result = email_notification.notify('user@example.com', { subject: 'Hello', body: 'Hello via Email' })

puts 'Email notification:'
puts "  Channel: #{result.channel}"
puts "  Success: #{result.success?}"
puts "  Details: #{result.details}"

puts

sms_sender = Bridge::SmsSender.new
sms_notification = Bridge::RegularNotification.new(sms_sender)
result = sms_notification.notify('+81-90-1234-5678', { subject: 'Hello', body: 'Hello via SMS' })

puts 'SMS notification:'
puts "  Channel: #{result.channel}"
puts "  Details: #{result.details}"

puts

# ========================================
# Example 2: Urgent Notifications
# ========================================
puts '--- Example 2: Urgent Notifications ---'
puts

push_sender = Bridge::PushNotificationSender.new
urgent_notification = Bridge::UrgentNotification.new(push_sender)
result = urgent_notification.notify('device-123', { subject: 'System Alert', body: 'URGENT: System alert' })

puts 'Urgent push notification:'
puts "  Details: #{result.details}"

puts

slack_sender = Bridge::SlackSender.new
urgent_slack = Bridge::UrgentNotification.new(slack_sender)
result = urgent_slack.notify('engineering', { subject: 'Production Issue', body: 'URGENT: Production issue' })

puts 'Urgent Slack notification:'
puts "  Details: #{result.details}"

puts

# ========================================
# Example 3: Scheduled Notifications
# ========================================
puts '--- Example 3: Scheduled Notifications ---'
puts

email_sender = Bridge::EmailSender.new
schedule_time = Time.now + 60 # 1 minute from now
scheduled = Bridge::ScheduledNotification.new(email_sender, scheduled_at: schedule_time)
result = scheduled.notify(
  'admin@example.com',
  { subject: 'Maintenance', body: 'Scheduled maintenance notice' }
)

puts 'Scheduled notification:'
puts "  Details: #{result.details}"
puts "  Scheduled for: #{schedule_time.strftime('%Y-%m-%d %H:%M:%S')}"

puts

# ========================================
# Example 4: Template Notifications
# ========================================
puts '--- Example 4: Template Notifications ---'
puts

email_sender = Bridge::EmailSender.new
regular = Bridge::RegularNotification.new(email_sender)

result = regular.notify(
  'customer@example.com',
  { subject: 'Welcome', body: 'Welcome Taro Yamada to Premium service' }
)

puts 'Template notification:'
puts "  Details: #{result.details}"

puts

# ========================================
# Example 5: Notification System with Multiple Channels
# ========================================
puts '--- Example 5: Multi-Channel Notification System ---'
puts

service = Bridge::NotificationService.new

# Send notifications through different channels
results = []
results << service.send_notification(
  recipient: 'user1@example.com',
  message: { subject: 'Test', body: 'Email message' },
  sender_type: :email
)
results << service.send_notification(
  recipient: '+81-90-1111-2222',
  message: { subject: 'Test', body: 'SMS message' },
  sender_type: :sms
)
results << service.send_notification(
  recipient: 'device-456',
  message: { subject: 'Test', body: 'Push message' },
  sender_type: :push
)
results << service.send_notification(
  recipient: 'general',
  message: { subject: 'Test', body: 'Slack message' },
  sender_type: :slack
)

results.each do |result|
  puts "Sent via #{result.channel}: #{result.success?}"
end

puts
puts "Total notifications sent: #{results.size}"

puts

# ========================================
# Example 6: Switching Implementations at Runtime
# ========================================
puts '--- Example 6: Runtime Implementation Switching ---'
puts

user_preference = :email
notification = case user_preference
               when :email
                 Bridge::RegularNotification.new(Bridge::EmailSender.new)
               when :sms
                 Bridge::RegularNotification.new(Bridge::SmsSender.new)
               when :push
                 Bridge::RegularNotification.new(Bridge::PushNotificationSender.new)
               else
                 Bridge::RegularNotification.new(Bridge::SlackSender.new)
               end

result = notification.notify('recipient@example.com', { subject: 'Notice', body: 'Preference-based notification' })
puts "Sent via user preference (#{user_preference}): #{result.channel}"

puts
puts '=' * 60
puts 'End of Bridge Pattern Demo'
puts '=' * 60
