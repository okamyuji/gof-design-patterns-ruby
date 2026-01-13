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

task default: :test
