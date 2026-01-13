# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'

# Add lib directory to load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Base test class with common utilities
class GofPatternTest < Minitest::Test
  # Helper method to assert that an object responds to certain methods
  def assert_interface(object, *methods)
    methods.each do |method|
      assert_respond_to object, method, "Expected #{object.class} to respond to #{method}"
    end
  end

  # Helper to capture stdout for testing output
  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
