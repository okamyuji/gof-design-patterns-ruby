# frozen_string_literal: true

require_relative '../test_helper'

class TestExamples < GofPatternTest
  EXAMPLE_DIR = File.expand_path('../../examples', __dir__)

  Dir.glob("#{EXAMPLE_DIR}/**/*_example.rb").each do |example_file|
    pattern_name = File.basename(example_file, '_example.rb')
    category = File.dirname(example_file).split('/').last

    define_method("test_#{category}_#{pattern_name}_example_runs") do
      output = capture_output do
        load example_file
      end

      refute_empty output, "#{pattern_name} example should produce output"
    end
  end
end
