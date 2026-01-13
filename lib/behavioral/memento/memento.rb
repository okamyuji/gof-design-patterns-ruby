# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Memento Pattern (メメントパターン)
    # ================================
    # 目的: オブジェクトの内部状態を保存し、
    #       後でその状態に復元できるようにする
    #
    # DDD Context:
    # - Entity の状態履歴管理
    # - イベントソーシングのスナップショット

    module Memento
      # Memento: 状態を保持する不透明オブジェクト
      class Memento
        attr_reader :timestamp, :name

        def initialize(state, name = nil)
          @state = state.dup.freeze
          @timestamp = Time.now
          @name = name || "Snapshot #{@timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
          freeze
        end

        # Originatorのみがアクセス可能
        protected

        def state
          @state.dup
        end
      end

      # Originator Interface
      class Originator
        def create_memento
          raise NotImplementedError
        end

        def restore_from_memento(_memento)
          raise NotImplementedError
        end
      end

      # Entity: テキストエディタ（Originator）
      class TextEditor < Originator
        attr_reader :content, :cursor_position, :selection

        def initialize
          @content = ''
          @cursor_position = 0
          @selection = nil
        end

        def type(text)
          @content = @content[0...@cursor_position] + text + @content[@cursor_position..]
          @cursor_position += text.length
        end

        def delete(count = 1)
          return if @cursor_position.zero?

          start_pos = [@cursor_position - count, 0].max
          @content = @content[0...start_pos] + @content[@cursor_position..]
          @cursor_position = start_pos
        end

        def move_cursor(position)
          @cursor_position = [[position, 0].max, @content.length].min
        end

        def select(start_pos, end_pos)
          @selection = { start: start_pos, end: end_pos }
        end

        def clear_selection
          @selection = nil
        end

        def create_memento(name = nil)
          state = {
            content: @content,
            cursor_position: @cursor_position,
            selection: @selection&.dup
          }
          EditorMemento.new(state, name)
        end

        def restore_from_memento(memento)
          state = memento.send(:state)
          @content = state[:content]
          @cursor_position = state[:cursor_position]
          @selection = state[:selection]
        end
      end

      # Concrete Memento: エディタ用
      class EditorMemento < Memento
        def preview
          state = send(:state)
          content = state[:content]
          preview_text = content.length > 50 ? "#{content[0..47]}..." : content
          "#{name}: \"#{preview_text}\" (cursor: #{state[:cursor_position]})"
        end
      end

      # Caretaker: 履歴管理
      class History
        def initialize(max_size: 100)
          @mementos = []
          @max_size = max_size
          @current_index = -1
        end

        def save(memento)
          # 現在位置より後の履歴を削除（新しい分岐を作成）
          @mementos = @mementos[0..@current_index] if @current_index < @mementos.length - 1

          @mementos << memento
          @mementos.shift if @mementos.length > @max_size
          @current_index = @mementos.length - 1
          memento
        end

        def undo
          return nil if @current_index <= 0

          @current_index -= 1
          @mementos[@current_index]
        end

        def redo
          return nil if @current_index >= @mementos.length - 1

          @current_index += 1
          @mementos[@current_index]
        end

        def can_undo?
          @current_index.positive?
        end

        def can_redo?
          @current_index < @mementos.length - 1
        end

        def current
          return nil if @current_index.negative?

          @mementos[@current_index]
        end

        def all
          @mementos.dup
        end

        def size
          @mementos.length
        end

        def clear
          @mementos.clear
          @current_index = -1
        end
      end

      # ===== ゲームセーブ例 =====

      # Entity: ゲームキャラクター（Originator）
      class GameCharacter < Originator
        attr_accessor :name, :level, :health, :mana, :position, :inventory

        def initialize(name)
          @name = name
          @level = 1
          @health = 100
          @mana = 50
          @position = { x: 0, y: 0 }
          @inventory = []
        end

        def take_damage(amount)
          @health = [@health - amount, 0].max
        end

        def heal(amount)
          @health = [@health + amount, 100].min
        end

        def use_mana(amount)
          return false if @mana < amount

          @mana -= amount
          true
        end

        def level_up
          @level += 1
          @health = 100
          @mana = 50 + (@level * 10)
        end

        def move_to(x, y)
          @position = { x: x, y: y }
        end

        def add_item(item)
          @inventory << item
        end

        def remove_item(item)
          @inventory.delete(item)
        end

        def alive?
          @health.positive?
        end

        def create_memento(name = nil)
          state = {
            name: @name,
            level: @level,
            health: @health,
            mana: @mana,
            position: @position.dup,
            inventory: @inventory.dup
          }
          GameSaveMemento.new(state, name)
        end

        def restore_from_memento(memento)
          state = memento.send(:state)
          @name = state[:name]
          @level = state[:level]
          @health = state[:health]
          @mana = state[:mana]
          @position = state[:position].dup
          @inventory = state[:inventory].dup
        end

        def status
          "#{@name} Lv.#{@level} HP:#{@health}/100 MP:#{@mana} Pos:(#{@position[:x]},#{@position[:y]})"
        end
      end

      # Concrete Memento: ゲームセーブ用
      class GameSaveMemento < Memento
        def preview
          state = send(:state)
          "#{name}: #{state[:name]} Lv.#{state[:level]} HP:#{state[:health]}"
        end
      end

      # Domain Service: ゲームセーブマネージャー
      class SaveManager
        def initialize(max_saves: 10)
          @saves = {}
          @auto_save_history = History.new(max_size: max_saves)
        end

        def save(character, slot_name)
          memento = character.create_memento("Save: #{slot_name}")
          @saves[slot_name] = memento
          memento
        end

        def load(character, slot_name)
          memento = @saves[slot_name]
          return false unless memento

          character.restore_from_memento(memento)
          true
        end

        def auto_save(character)
          memento = character.create_memento('Auto-save')
          @auto_save_history.save(memento)
        end

        def quick_load(character)
          memento = @auto_save_history.current
          return false unless memento

          character.restore_from_memento(memento)
          true
        end

        def undo(character)
          memento = @auto_save_history.undo
          return false unless memento

          character.restore_from_memento(memento)
          true
        end

        def redo(character)
          memento = @auto_save_history.redo
          return false unless memento

          character.restore_from_memento(memento)
          true
        end

        def list_saves
          @saves.map { |slot, memento| "#{slot}: #{memento.preview}" }
        end

        def delete_save(slot_name)
          @saves.delete(slot_name)
        end
      end

      # Domain Service: エディタアプリケーション
      class EditorApplication
        attr_reader :editor

        def initialize
          @editor = TextEditor.new
          @history = History.new
          save_state('Initial')
        end

        def type(text)
          @editor.type(text)
          save_state
        end

        def delete(count = 1)
          @editor.delete(count)
          save_state
        end

        def undo
          memento = @history.undo
          return false unless memento

          @editor.restore_from_memento(memento)
          true
        end

        def redo
          memento = @history.redo
          return false unless memento

          @editor.restore_from_memento(memento)
          true
        end

        def content
          @editor.content
        end

        def save_named(name)
          @history.save(@editor.create_memento(name))
        end

        def history_size
          @history.size
        end

        private

        def save_state(name = nil)
          @history.save(@editor.create_memento(name))
        end
      end
    end
  end
end
