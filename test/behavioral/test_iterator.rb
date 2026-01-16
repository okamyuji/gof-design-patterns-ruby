# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/iterator/iterator'

class TestIterator < GofPatternTest
  def test_book_value_object
    book = GofPatterns::Behavioral::Iterator::Book.new(
      isbn: '978-4-123-45678-9',
      title: 'Ruby入門',
      author: '山田太郎',
      year: 2024
    )

    assert_equal '978-4-123-45678-9', book.isbn
    assert_equal 'Ruby入門', book.title
    assert_predicate book, :frozen?
  end

  def test_bookshelf_add_and_size
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    book1 = GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'Book1', author: 'A', year: 2020)
    book2 = GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'Book2', author: 'B', year: 2021)

    shelf.add(book1).add(book2)

    assert_equal 2, shelf.size
  end

  def test_bookshelf_iterator
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'A', author: 'X', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'B', author: 'Y', year: 2021))

    iterator = shelf.create_iterator

    assert_predicate iterator, :has_next?
    assert_equal 'A', iterator.next.title
    assert_predicate iterator, :has_next?
    assert_equal 'B', iterator.next.title
    refute_predicate iterator, :has_next?
  end

  def test_bookshelf_iterator_reset
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'A', author: 'X', year: 2020))

    iterator = shelf.create_iterator
    iterator.next

    refute_predicate iterator, :has_next?

    iterator.reset

    assert_predicate iterator, :has_next?
  end

  def test_reverse_iterator
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'First', author: 'A', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'Second', author: 'B', year: 2021))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '3', title: 'Third', author: 'C', year: 2022))

    iterator = GofPatterns::Behavioral::Iterator::ReverseBookshelfIterator.new(shelf)

    assert_equal 'Third', iterator.next.title
    assert_equal 'Second', iterator.next.title
    assert_equal 'First', iterator.next.title
  end

  def test_filtering_iterator
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'Ruby', author: 'A', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'Python', author: 'B', year: 2021))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '3', title: 'Ruby Advanced', author: 'C', year: 2022))

    base_iterator = shelf.create_iterator
    filter_iterator = GofPatterns::Behavioral::Iterator::FilteringIterator.new(base_iterator) do |book|
      book.title.include?('Ruby')
    end

    titles = []
    titles << filter_iterator.next.title while filter_iterator.has_next?

    assert_equal 2, titles.size
    assert(titles.all? { |t| t.include?('Ruby') })
  end

  def test_bookshelf_enumerable
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'A', author: 'X', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'B', author: 'Y', year: 2021))

    titles = shelf.map(&:title)

    assert_equal %w[A B], titles
  end

  def test_binary_tree_insert
    tree = GofPatterns::Behavioral::Iterator::BinaryTree.new
    tree.insert(5).insert(3).insert(7).insert(1).insert(4)

    refute_nil tree.root
    assert_equal 5, tree.root.value
  end

  def test_inorder_iterator
    tree = GofPatterns::Behavioral::Iterator::BinaryTree.new
    tree.insert(5).insert(3).insert(7).insert(1).insert(4)

    iterator = tree.create_iterator(traversal: :inorder)
    values = []
    values << iterator.next while iterator.has_next?

    assert_equal [1, 3, 4, 5, 7], values
  end

  def test_preorder_iterator
    tree = GofPatterns::Behavioral::Iterator::BinaryTree.new
    tree.insert(5).insert(3).insert(7)

    iterator = tree.create_iterator(traversal: :preorder)
    values = []
    values << iterator.next while iterator.has_next?

    assert_equal [5, 3, 7], values
  end

  def test_postorder_iterator
    tree = GofPatterns::Behavioral::Iterator::BinaryTree.new
    tree.insert(5).insert(3).insert(7)

    iterator = tree.create_iterator(traversal: :postorder)
    values = []
    values << iterator.next while iterator.has_next?

    assert_equal [3, 7, 5], values
  end

  def test_iterator_utils_to_array
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'A', author: 'X', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'B', author: 'Y', year: 2021))

    array = GofPatterns::Behavioral::Iterator::IteratorUtils.to_array(shelf.create_iterator)

    assert_equal 2, array.size
  end

  def test_iterator_utils_map
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'A', author: 'X', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'B', author: 'Y', year: 2021))

    titles = GofPatterns::Behavioral::Iterator::IteratorUtils.map(shelf.create_iterator, &:title)

    assert_equal %w[A B], titles
  end

  def test_iterator_utils_reduce
    tree = GofPatterns::Behavioral::Iterator::BinaryTree.new
    tree.insert(1).insert(2).insert(3).insert(4).insert(5)

    sum = GofPatterns::Behavioral::Iterator::IteratorUtils.reduce(
      tree.create_iterator(traversal: :inorder),
      0
    ) { |acc, val| acc + val }

    assert_equal 15, sum
  end

  def test_iterator_utils_count
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '1', title: 'A', author: 'X', year: 2020))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '2', title: 'B', author: 'Y', year: 2021))
    shelf.add(GofPatterns::Behavioral::Iterator::Book.new(isbn: '3', title: 'C', author: 'Z', year: 2022))

    count = GofPatterns::Behavioral::Iterator::IteratorUtils.count(shelf.create_iterator)

    assert_equal 3, count
  end

  def test_iterator_stop_iteration
    shelf = GofPatterns::Behavioral::Iterator::Bookshelf.new
    iterator = shelf.create_iterator

    assert_raises(StopIteration) do
      iterator.next
    end
  end
end
