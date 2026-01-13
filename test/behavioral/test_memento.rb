# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/memento/memento'

class TestMemento < GofPatternTest
  def test_text_editor_type
    editor = GofPatterns::Behavioral::Memento::TextEditor.new
    editor.type('Hello')

    assert_equal 'Hello', editor.content
    assert_equal 5, editor.cursor_position
  end

  def test_text_editor_delete
    editor = GofPatterns::Behavioral::Memento::TextEditor.new
    editor.type('Hello World')
    editor.delete(6)

    assert_equal 'Hello', editor.content
  end

  def test_text_editor_create_memento
    editor = GofPatterns::Behavioral::Memento::TextEditor.new
    editor.type('Test content')

    memento = editor.create_memento('Test Snapshot')

    assert_instance_of GofPatterns::Behavioral::Memento::EditorMemento, memento
    assert_equal 'Test Snapshot', memento.name
  end

  def test_text_editor_restore_from_memento
    editor = GofPatterns::Behavioral::Memento::TextEditor.new
    editor.type('Original')
    memento = editor.create_memento

    editor.type(' Modified')
    assert_equal 'Original Modified', editor.content

    editor.restore_from_memento(memento)
    assert_equal 'Original', editor.content
  end

  def test_editor_memento_preview
    editor = GofPatterns::Behavioral::Memento::TextEditor.new
    editor.type('Short text')
    memento = editor.create_memento('Preview Test')

    preview = memento.preview
    assert_match(/Preview Test/, preview)
    assert_match(/Short text/, preview)
  end

  def test_history_save_and_undo
    history = GofPatterns::Behavioral::Memento::History.new
    editor = GofPatterns::Behavioral::Memento::TextEditor.new

    editor.type('A')
    history.save(editor.create_memento)

    editor.type('B')
    history.save(editor.create_memento)

    assert history.can_undo?
    memento = history.undo
    editor.restore_from_memento(memento)

    assert_equal 'A', editor.content
  end

  def test_history_redo
    history = GofPatterns::Behavioral::Memento::History.new
    editor = GofPatterns::Behavioral::Memento::TextEditor.new

    editor.type('A')
    history.save(editor.create_memento)

    editor.type('B')
    history.save(editor.create_memento)

    history.undo
    assert history.can_redo?

    memento = history.redo
    editor.restore_from_memento(memento)
    assert_equal 'AB', editor.content
  end

  def test_history_max_size
    history = GofPatterns::Behavioral::Memento::History.new(max_size: 3)
    editor = GofPatterns::Behavioral::Memento::TextEditor.new

    5.times do |i|
      editor.type(i.to_s)
      history.save(editor.create_memento)
    end

    assert_equal 3, history.size
  end

  def test_history_clear
    history = GofPatterns::Behavioral::Memento::History.new
    editor = GofPatterns::Behavioral::Memento::TextEditor.new

    editor.type('Test')
    history.save(editor.create_memento)

    history.clear

    assert_equal 0, history.size
    refute history.can_undo?
  end

  def test_game_character_creation
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')

    assert_equal 'Hero', character.name
    assert_equal 1, character.level
    assert_equal 100, character.health
    assert_equal 50, character.mana
  end

  def test_game_character_take_damage
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')
    character.take_damage(30)

    assert_equal 70, character.health
    assert character.alive?

    character.take_damage(100)
    assert_equal 0, character.health
    refute character.alive?
  end

  def test_game_character_level_up
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')
    character.take_damage(50)
    character.level_up

    assert_equal 2, character.level
    assert_equal 100, character.health # 回復
    assert_equal 70, character.mana # 50 + (2 * 10)
  end

  def test_game_character_memento
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')
    character.level_up
    character.move_to(100, 200)
    character.add_item('Sword')

    memento = character.create_memento('Before Battle')

    character.take_damage(80)
    character.move_to(0, 0)

    assert_equal 20, character.health

    character.restore_from_memento(memento)

    assert_equal 100, character.health
    assert_equal({ x: 100, y: 200 }, character.position)
    assert_includes character.inventory, 'Sword'
  end

  def test_save_manager
    manager = GofPatterns::Behavioral::Memento::SaveManager.new
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')

    character.level_up
    manager.save(character, 'slot1')

    character.take_damage(50)
    assert_equal 50, character.health

    manager.load(character, 'slot1')
    assert_equal 100, character.health
  end

  def test_save_manager_auto_save
    manager = GofPatterns::Behavioral::Memento::SaveManager.new
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')

    # First auto_save at health=100
    manager.auto_save(character)
    character.take_damage(50)
    # Second auto_save at health=50
    manager.auto_save(character)

    character.take_damage(30)
    assert_equal 20, character.health

    # Undo goes back in history: from save2(50) to save1(100)
    manager.undo(character)
    assert_equal 100, character.health

    # Redo goes forward: from save1(100) to save2(50)
    manager.redo(character)
    assert_equal 50, character.health
  end

  def test_save_manager_list_saves
    manager = GofPatterns::Behavioral::Memento::SaveManager.new
    character = GofPatterns::Behavioral::Memento::GameCharacter.new('Hero')

    manager.save(character, 'save1')
    manager.save(character, 'save2')

    saves = manager.list_saves
    assert_equal 2, saves.size
  end

  def test_editor_application
    app = GofPatterns::Behavioral::Memento::EditorApplication.new

    app.type('Hello')
    app.type(' World')

    assert_equal 'Hello World', app.content

    app.undo
    assert_equal 'Hello', app.content

    app.redo
    assert_equal 'Hello World', app.content
  end

  def test_editor_application_named_save
    app = GofPatterns::Behavioral::Memento::EditorApplication.new

    app.type('Important')
    app.save_named('Checkpoint')

    initial_size = app.history_size
    app.type(' Extra')

    assert app.history_size > initial_size
  end
end
