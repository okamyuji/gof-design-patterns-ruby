# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/mediator/mediator'

class TestMediator < GofPatternTest
  def test_chat_message_creation
    msg = GofPatterns::Behavioral::Mediator::ChatMessage.new(
      sender: 'Alice',
      content: 'Hello!'
    )

    assert_equal 'Alice', msg.sender
    assert_equal 'Hello!', msg.content
    assert msg.frozen?
  end

  def test_chat_room_register_user
    room = GofPatterns::Behavioral::Mediator::ChatRoom.new
    user = GofPatterns::Behavioral::Mediator::ChatUser.new('Alice')

    room.register(user)

    assert_includes room.users, 'Alice'
    assert_equal room, user.mediator
  end

  def test_chat_room_broadcast_message
    room = GofPatterns::Behavioral::Mediator::ChatRoom.new
    alice = GofPatterns::Behavioral::Mediator::ChatUser.new('Alice')
    bob = GofPatterns::Behavioral::Mediator::ChatUser.new('Bob')

    room.register(alice)
    room.register(bob)

    alice.send_message('Hello everyone!')

    assert bob.received_messages.any? { |m| m.content == 'Hello everyone!' }
    # 送信者は自分のメッセージを受け取らない（ブロードキャスト時）
  end

  def test_chat_room_private_message
    room = GofPatterns::Behavioral::Mediator::ChatRoom.new
    alice = GofPatterns::Behavioral::Mediator::ChatUser.new('Alice')
    bob = GofPatterns::Behavioral::Mediator::ChatUser.new('Bob')
    charlie = GofPatterns::Behavioral::Mediator::ChatUser.new('Charlie')

    room.register(alice)
    room.register(bob)
    room.register(charlie)

    alice.send_private_message('Bob', 'Secret message')

    assert bob.received_messages.any? { |m| m.content == 'Secret message' }
    refute charlie.received_messages.any? { |m| m.content == 'Secret message' }
  end

  def test_chat_room_message_history
    room = GofPatterns::Behavioral::Mediator::ChatRoom.new
    alice = GofPatterns::Behavioral::Mediator::ChatUser.new('Alice')

    room.register(alice)
    alice.send_message('Test message')

    assert room.message_history.any? { |m| m.content == 'Test message' }
  end

  def test_chat_user_clear_messages
    room = GofPatterns::Behavioral::Mediator::ChatRoom.new
    alice = GofPatterns::Behavioral::Mediator::ChatUser.new('Alice')
    bob = GofPatterns::Behavioral::Mediator::ChatUser.new('Bob')

    room.register(alice)
    room.register(bob)

    alice.send_message('Message')
    bob.clear_messages

    assert bob.received_messages.empty?
  end

  def test_form_dialog_text_changed
    dialog = GofPatterns::Behavioral::Mediator::FormDialog.new
    text_field = GofPatterns::Behavioral::Mediator::TextField.new(:username)
    submit_button = GofPatterns::Behavioral::Mediator::Button.new(:submit_button)

    dialog.register(text_field)
    dialog.register(submit_button)

    # テキストが空の状態
    text_field.set_text('')
    refute submit_button.enabled

    # テキストを入力
    text_field.set_text('user123')
    assert submit_button.enabled
  end

  def test_text_field_operations
    dialog = GofPatterns::Behavioral::Mediator::FormDialog.new
    field = GofPatterns::Behavioral::Mediator::TextField.new(:email)

    dialog.register(field)

    field.set_text('test@example.com')
    assert_equal 'test@example.com', field.text

    field.clear
    assert_equal '', field.text
  end

  def test_checkbox_toggle
    dialog = GofPatterns::Behavioral::Mediator::FormDialog.new
    checkbox = GofPatterns::Behavioral::Mediator::Checkbox.new(:agree)

    dialog.register(checkbox)

    refute checkbox.checked
    checkbox.toggle
    assert checkbox.checked
    checkbox.toggle
    refute checkbox.checked
  end

  def test_checkbox_check_uncheck
    dialog = GofPatterns::Behavioral::Mediator::FormDialog.new
    checkbox = GofPatterns::Behavioral::Mediator::Checkbox.new(:option)

    dialog.register(checkbox)

    checkbox.check
    assert checkbox.checked
    checkbox.check # 再度チェックしても変化なし
    assert checkbox.checked

    checkbox.uncheck
    refute checkbox.checked
  end

  def test_button_click_when_enabled
    dialog = GofPatterns::Behavioral::Mediator::FormDialog.new
    button = GofPatterns::Behavioral::Mediator::Button.new(:submit_button)

    dialog.register(button)

    button.enabled = true
    button.click # エラーが発生しなければOK
  end

  def test_button_click_when_disabled
    dialog = GofPatterns::Behavioral::Mediator::FormDialog.new
    button = GofPatterns::Behavioral::Mediator::Button.new(:submit_button)

    dialog.register(button)

    button.enabled = false
    button.click # 無効時はnotifyが呼ばれない
  end

  def test_control_tower_register_flight
    tower = GofPatterns::Behavioral::Mediator::ControlTower.new
    flight = GofPatterns::Behavioral::Mediator::Flight.new('JA001')

    tower.register(flight)

    assert_includes tower.flights, 'JA001'
    assert_equal tower, flight.mediator
  end

  def test_flight_landing_request
    tower = GofPatterns::Behavioral::Mediator::ControlTower.new
    flight = GofPatterns::Behavioral::Mediator::Flight.new('JA001')

    tower.register(flight)
    flight.request_landing

    assert_equal :landed, flight.status
    assert flight.messages.any? { |m| m.include?('Cleared for landing') }
  end

  def test_flight_landing_queue
    tower = GofPatterns::Behavioral::Mediator::ControlTower.new
    flight1 = GofPatterns::Behavioral::Mediator::Flight.new('JA001')
    flight2 = GofPatterns::Behavioral::Mediator::Flight.new('JA002')

    tower.register(flight1)
    tower.register(flight2)

    flight1.request_landing # 最初の着陸リクエストは許可
    flight2.request_landing # 滑走路使用中でキュー待ち

    assert_equal :landed, flight1.status
    assert_equal :in_flight, flight2.status # まだ着陸待ち
    assert_equal 1, tower.queue_length
  end

  def test_runway_cleared
    tower = GofPatterns::Behavioral::Mediator::ControlTower.new
    flight1 = GofPatterns::Behavioral::Mediator::Flight.new('JA001')
    flight2 = GofPatterns::Behavioral::Mediator::Flight.new('JA002')

    tower.register(flight1)
    tower.register(flight2)

    flight1.request_landing
    flight2.request_landing

    # 最初のフライトが滑走路をクリア
    flight1.clear_runway

    assert_equal :landed, flight2.status
    assert_equal 0, tower.queue_length
  end
end
