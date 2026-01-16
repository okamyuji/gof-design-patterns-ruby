# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/command/command'

class TestCommand < GofPatternTest
  def test_text_document_insert
    doc = GofPatterns::Behavioral::Command::TextDocument.new
    doc.insert('Hello')

    assert_equal 'Hello', doc.content
    assert_equal 5, doc.cursor_position
  end

  def test_text_document_delete
    doc = GofPatterns::Behavioral::Command::TextDocument.new('Hello World')
    doc.delete(5, 6) # Delete " World" (6 chars starting at position 5)

    assert_equal 'Hello', doc.content
  end

  def test_text_document_replace
    doc = GofPatterns::Behavioral::Command::TextDocument.new('Hello World')
    old = doc.replace(6, 5, 'Ruby')

    assert_equal 'Hello Ruby', doc.content
    assert_equal 'World', old
  end

  def test_insert_command_execute_and_undo
    doc = GofPatterns::Behavioral::Command::TextDocument.new
    cmd = GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'Hello')

    cmd.execute

    assert_equal 'Hello', doc.content

    cmd.undo

    assert_equal '', doc.content
  end

  def test_delete_command_execute_and_undo
    doc = GofPatterns::Behavioral::Command::TextDocument.new('Hello World')
    doc.move_cursor(11)
    cmd = GofPatterns::Behavioral::Command::DeleteCommand.new(doc, 6, 5)

    cmd.execute

    assert_equal 'Hello ', doc.content

    cmd.undo

    assert_equal 'Hello World', doc.content
  end

  def test_replace_command_execute_and_undo
    doc = GofPatterns::Behavioral::Command::TextDocument.new('Hello World')
    cmd = GofPatterns::Behavioral::Command::ReplaceCommand.new(doc, 6, 5, 'Ruby')

    cmd.execute

    assert_equal 'Hello Ruby', doc.content

    cmd.undo

    assert_equal 'Hello World', doc.content
  end

  def test_macro_command
    doc = GofPatterns::Behavioral::Command::TextDocument.new
    macro = GofPatterns::Behavioral::Command::MacroCommand.new('Format')
                                                          .add(GofPatterns::Behavioral::Command::InsertCommand.new(doc,
                                                                                                                   'Hello'))
                                                          .add(GofPatterns::Behavioral::Command::InsertCommand.new(doc,
                                                                                                                   ' World'))

    macro.execute

    assert_equal 'Hello World', doc.content

    macro.undo

    assert_equal '', doc.content
  end

  def test_command_history
    doc = GofPatterns::Behavioral::Command::TextDocument.new
    history = GofPatterns::Behavioral::Command::CommandHistory.new

    history.execute(GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'A'))
    history.execute(GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'B'))

    assert_equal 'AB', doc.content
    assert_predicate history, :can_undo?

    history.undo

    assert_equal 'A', doc.content

    history.redo

    assert_equal 'AB', doc.content
  end

  def test_command_history_clears_redo_on_new_command
    doc = GofPatterns::Behavioral::Command::TextDocument.new
    history = GofPatterns::Behavioral::Command::CommandHistory.new

    history.execute(GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'A'))
    history.execute(GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'B'))
    history.undo
    history.execute(GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'C'))

    refute_predicate history, :can_redo?
    assert_equal 'AC', doc.content
  end

  def test_bank_account
    account = GofPatterns::Behavioral::Command::BankAccount.new('001', 1000)

    account.deposit(500)

    assert_equal 1500, account.balance

    account.withdraw(200)

    assert_equal 1300, account.balance
  end

  def test_bank_account_insufficient_funds
    account = GofPatterns::Behavioral::Command::BankAccount.new('001', 100)

    assert_raises(ArgumentError) do
      account.withdraw(200)
    end
  end

  def test_deposit_command
    account = GofPatterns::Behavioral::Command::BankAccount.new('001', 1000)
    cmd = GofPatterns::Behavioral::Command::DepositCommand.new(account, 500)

    cmd.execute

    assert_equal 1500, account.balance

    cmd.undo

    assert_equal 1000, account.balance
  end

  def test_withdraw_command
    account = GofPatterns::Behavioral::Command::BankAccount.new('001', 1000)
    cmd = GofPatterns::Behavioral::Command::WithdrawCommand.new(account, 300)

    cmd.execute

    assert_equal 700, account.balance

    cmd.undo

    assert_equal 1000, account.balance
  end

  def test_transfer_command
    from = GofPatterns::Behavioral::Command::BankAccount.new('001', 1000)
    to = GofPatterns::Behavioral::Command::BankAccount.new('002', 500)
    cmd = GofPatterns::Behavioral::Command::TransferCommand.new(from, to, 300)

    cmd.execute

    assert_equal 700, from.balance
    assert_equal 800, to.balance

    cmd.undo

    assert_equal 1000, from.balance
    assert_equal 500, to.balance
  end

  def test_text_editor_service
    editor = GofPatterns::Behavioral::Command::TextEditor.new

    editor.insert('Hello')
    editor.insert(' World')

    assert_equal 'Hello World', editor.content

    editor.undo

    assert_equal 'Hello', editor.content

    editor.redo

    assert_equal 'Hello World', editor.content
  end

  def test_banking_service
    service = GofPatterns::Behavioral::Command::BankingService.new
    service.create_account('A001', 10_000)
    service.create_account('A002', 5000)

    service.deposit('A001', 2000)

    assert_equal 12_000, service.balance('A001')

    service.transfer('A001', 'A002', 3000)

    assert_equal 9000, service.balance('A001')
    assert_equal 8000, service.balance('A002')

    service.undo

    assert_equal 12_000, service.balance('A001')
    assert_equal 5000, service.balance('A002')
  end

  def test_command_description
    doc = GofPatterns::Behavioral::Command::TextDocument.new
    cmd = GofPatterns::Behavioral::Command::InsertCommand.new(doc, 'Test', 0)

    assert_match(/Insert/, cmd.description)
  end
end
