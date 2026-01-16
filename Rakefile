# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
  t.warning = true
end

namespace :test do
  Rake::TestTask.new(:creational) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/creational/test_*.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:structural) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/structural/test_*.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:behavioral) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/behavioral/test_*.rb'
    t.verbose = true
  end
end

namespace :examples do
  desc 'Run all pattern examples'
  task :run do
    Dir.glob('examples/**/*_example.rb').each do |file|
      puts "\n#{'=' * 60}"
      puts "Running: #{file}"
      puts '=' * 60
      system("ruby #{file}") || abort("Example failed: #{file}")
    end
  end

  %i[creational structural behavioral].each do |category|
    desc "Run #{category} pattern examples"
    task category do
      Dir.glob("examples/#{category}/*_example.rb").each do |file|
        puts "\n#{'=' * 60}"
        puts "Running: #{file}"
        puts '=' * 60
        system("ruby #{file}") || abort("Example failed: #{file}")
      end
    end
  end
end

task default: :test
