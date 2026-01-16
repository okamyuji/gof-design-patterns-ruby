# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Command Pattern (コマンドパターン)
    # ================================
    # 目的: リクエストをオブジェクトとしてカプセル化し、
    #       実行、取り消し、再実行を可能にする
    #
    # DDD Context:
    # - ドメインイベントとしてのコマンド
    # - CQRS のコマンド側

    module Command
      # Command Interface
      class Command
        def execute
          raise NotImplementedError
        end

        def undo
          raise NotImplementedError
        end

        def description
          raise NotImplementedError
        end
      end

      # Entity: テキストドキュメント（Receiver）
      class TextDocument
        attr_reader :content, :cursor_position

        def initialize(initial_content = '')
          @content = initial_content
          @cursor_position = @content.length
        end

        def insert(text, position = @cursor_position)
          @content = @content[0...position].to_s + text + @content[position..].to_s
          @cursor_position = position + text.length
        end

        def delete(start_pos, length)
          deleted = @content[start_pos, length]
          @content = @content[0...start_pos].to_s + @content[(start_pos + length)..].to_s
          @cursor_position = start_pos
          deleted
        end

        def replace(start_pos, length, new_text)
          old_text = @content[start_pos, length]
          @content = @content[0...start_pos].to_s + new_text + @content[(start_pos + length)..].to_s
          @cursor_position = start_pos + new_text.length
          old_text
        end

        def move_cursor(position)
          @cursor_position = [[position, 0].max, @content.length].min
        end

        def select_all
          @content.dup
        end

        def to_s
          @content
        end
      end

      # Concrete Command: 挿入コマンド
      class InsertCommand < Command
        def initialize(document, text, position = nil)
          @document = document
          @text = text
          @explicit_position = position
          @executed = false
          @actual_position = nil
        end

        def execute
          # カーソル位置は実行時に評価（MacroCommand対応）
          @actual_position = @explicit_position || @document.cursor_position
          @document.insert(@text, @actual_position)
          @executed = true
        end

        def undo
          return unless @executed

          @document.delete(@actual_position, @text.length)
          @executed = false
        end

        def description
          pos = @actual_position || @explicit_position || 'cursor'
          "Insert '#{@text}' at position #{pos}"
        end
      end

      # Concrete Command: 削除コマンド
      class DeleteCommand < Command
        def initialize(document, start_pos, length)
          @document = document
          @start_pos = start_pos
          @length = length
          @deleted_text = nil
        end

        def execute
          @deleted_text = @document.delete(@start_pos, @length)
        end

        def undo
          return unless @deleted_text

          @document.insert(@deleted_text, @start_pos)
          @deleted_text = nil
        end

        def description
          "Delete #{@length} characters from position #{@start_pos}"
        end
      end

      # Concrete Command: 置換コマンド
      class ReplaceCommand < Command
        def initialize(document, start_pos, length, new_text)
          @document = document
          @start_pos = start_pos
          @length = length
          @new_text = new_text
          @old_text = nil
        end

        def execute
          @old_text = @document.replace(@start_pos, @length, @new_text)
        end

        def undo
          return unless @old_text

          @document.replace(@start_pos, @new_text.length, @old_text)
          @old_text = nil
        end

        def description
          "Replace #{@length} characters with '#{@new_text}'"
        end
      end

      # Macro Command: 複数コマンドの組み合わせ
      class MacroCommand < Command
        def initialize(name = 'Macro')
          @name = name
          @commands = []
        end

        def add(command)
          @commands << command
          self
        end

        def execute
          @commands.each(&:execute)
        end

        def undo
          @commands.reverse_each(&:undo)
        end

        def description
          "#{@name}: #{@commands.map(&:description).join(', ')}"
        end
      end

      # Invoker: コマンド履歴管理
      class CommandHistory
        def initialize
          @history = []
          @redo_stack = []
        end

        def execute(command)
          command.execute
          @history.push(command)
          @redo_stack.clear
        end

        def undo
          return nil if @history.empty?

          command = @history.pop
          command.undo
          @redo_stack.push(command)
          command
        end

        def redo
          return nil if @redo_stack.empty?

          command = @redo_stack.pop
          command.execute
          @history.push(command)
          command
        end

        def can_undo?
          !@history.empty?
        end

        def can_redo?
          !@redo_stack.empty?
        end

        def history
          @history.map(&:description)
        end

        def clear
          @history.clear
          @redo_stack.clear
        end
      end

      # ===== 銀行取引例 =====

      # Entity: 銀行口座（Receiver）
      class BankAccount
        attr_reader :account_number, :balance

        def initialize(account_number, initial_balance = 0)
          @account_number = account_number
          @balance = initial_balance
        end

        def deposit(amount)
          raise ArgumentError, 'Amount must be positive' if amount <= 0

          @balance += amount
        end

        def withdraw(amount)
          raise ArgumentError, 'Amount must be positive' if amount <= 0
          raise ArgumentError, 'Insufficient funds' if amount > @balance

          @balance -= amount
        end

        def to_s
          "Account #{@account_number}: ¥#{@balance}"
        end
      end

      # Concrete Command: 入金コマンド
      class DepositCommand < Command
        def initialize(account, amount)
          @account = account
          @amount = amount
          @executed = false
        end

        def execute
          @account.deposit(@amount)
          @executed = true
        end

        def undo
          return unless @executed

          @account.withdraw(@amount)
          @executed = false
        end

        def description
          "Deposit ¥#{@amount} to #{@account.account_number}"
        end
      end

      # Concrete Command: 出金コマンド
      class WithdrawCommand < Command
        def initialize(account, amount)
          @account = account
          @amount = amount
          @executed = false
        end

        def execute
          @account.withdraw(@amount)
          @executed = true
        end

        def undo
          return unless @executed

          @account.deposit(@amount)
          @executed = false
        end

        def description
          "Withdraw ¥#{@amount} from #{@account.account_number}"
        end
      end

      # Concrete Command: 送金コマンド
      class TransferCommand < Command
        def initialize(from_account, to_account, amount)
          @from_account = from_account
          @to_account = to_account
          @amount = amount
          @executed = false
        end

        def execute
          @from_account.withdraw(@amount)
          @to_account.deposit(@amount)
          @executed = true
        end

        def undo
          return unless @executed

          @to_account.withdraw(@amount)
          @from_account.deposit(@amount)
          @executed = false
        end

        def description
          "Transfer ¥#{@amount} from #{@from_account.account_number} to #{@to_account.account_number}"
        end
      end

      # Domain Service: テキストエディタ
      class TextEditor
        attr_reader :document, :history

        def initialize(initial_content = '')
          @document = TextDocument.new(initial_content)
          @history = CommandHistory.new
        end

        def insert(text, position = nil)
          cmd = InsertCommand.new(@document, text, position)
          @history.execute(cmd)
        end

        def delete(start_pos, length)
          cmd = DeleteCommand.new(@document, start_pos, length)
          @history.execute(cmd)
        end

        def replace(start_pos, length, new_text)
          cmd = ReplaceCommand.new(@document, start_pos, length, new_text)
          @history.execute(cmd)
        end

        def undo
          @history.undo
        end

        def redo
          @history.redo
        end

        def content
          @document.content
        end
      end

      # Domain Service: 銀行サービス
      class BankingService
        def initialize
          @accounts = {}
          @history = CommandHistory.new
        end

        def create_account(account_number, initial_balance = 0)
          @accounts[account_number] = BankAccount.new(account_number, initial_balance)
        end

        def deposit(account_number, amount)
          account = @accounts[account_number]
          raise ArgumentError, "Account not found: #{account_number}" unless account

          cmd = DepositCommand.new(account, amount)
          @history.execute(cmd)
        end

        def withdraw(account_number, amount)
          account = @accounts[account_number]
          raise ArgumentError, "Account not found: #{account_number}" unless account

          cmd = WithdrawCommand.new(account, amount)
          @history.execute(cmd)
        end

        def transfer(from_account_number, to_account_number, amount)
          from = @accounts[from_account_number]
          to = @accounts[to_account_number]
          raise ArgumentError, 'Account not found' unless from && to

          cmd = TransferCommand.new(from, to, amount)
          @history.execute(cmd)
        end

        def undo
          @history.undo
        end

        def balance(account_number)
          @accounts[account_number]&.balance
        end

        def transaction_history
          @history.history
        end
      end
    end
  end
end
