#!/usr/bin/env ruby
# frozen_string_literal: true

# Composite Pattern Example
# =========================
# コンポジットパターン: オブジェクトをツリー構造に組み立て、
#                       個々のオブジェクトと合成を同一視して扱う
#
# Usage: ruby examples/structural/composite_example.rb

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'gof_patterns'

Composite = GofPatterns::Structural::Composite

puts '=' * 60
puts 'Composite Pattern Demo'
puts '=' * 60
puts

# ========================================
# Example 1: Basic File System Structure
# ========================================
puts '--- Example 1: File System Structure ---'
puts

root = Composite::Directory.new('root')
root.add(Composite::File.new('readme.txt', content_size: 1024))
root.add(Composite::File.new('license.md', content_size: 2048))

documents = Composite::Directory.new('documents')
documents.add(Composite::File.new('report.pdf', content_size: 50_000))
documents.add(Composite::File.new('presentation.pptx', content_size: 120_000))

root.add(documents)

puts root.display
puts
puts "Total size: #{root.size} bytes"
puts "Path to report: #{root.find('report.pdf')&.path}"

puts

# ========================================
# Example 2: Deep Directory Structure
# ========================================
puts '--- Example 2: Deep Directory Structure ---'
puts

project = Composite::Directory.new('project')

src = Composite::Directory.new('src')
src.add(Composite::File.new('main.rb', content_size: 5000))
src.add(Composite::File.new('helper.rb', content_size: 3000))

lib = Composite::Directory.new('lib')
lib.add(Composite::File.new('utils.rb', content_size: 2000))
lib.add(Composite::File.new('config.rb', content_size: 1500))

src.add(lib)
project.add(src)

test = Composite::Directory.new('test')
test.add(Composite::File.new('test_main.rb', content_size: 4000))
test.add(Composite::File.new('test_helper.rb', content_size: 2500))

project.add(test)

puts project.display
puts
puts "Project total size: #{project.size} bytes"
puts "Number of items in src: #{src.count}"

puts

# ========================================
# Example 3: Organization Hierarchy
# ========================================
puts '--- Example 3: Organization Hierarchy ---'
puts

company = Composite::Department.new(id: 'DEPT-000', name: 'TechCorp')

engineering = Composite::Department.new(id: 'DEPT-001', name: 'Engineering')
engineering.add(Composite::Employee.new(id: 'E001', name: 'Alice Johnson', position: 'Senior Engineer',
                                        salary: 120_000))
engineering.add(Composite::Employee.new(id: 'E002', name: 'Bob Smith', position: 'Engineer', salary: 90_000))

backend = Composite::Department.new(id: 'DEPT-002', name: 'Backend Team')
backend.add(Composite::Employee.new(id: 'E003', name: 'Carol White', position: 'Backend Developer', salary: 100_000))
backend.add(Composite::Employee.new(id: 'E004', name: 'Dave Brown', position: 'Backend Developer', salary: 95_000))

engineering.add(backend)

sales = Composite::Department.new(id: 'DEPT-003', name: 'Sales')
sales.add(Composite::Employee.new(id: 'S001', name: 'Eve Green', position: 'Sales Manager', salary: 110_000))
sales.add(Composite::Employee.new(id: 'S002', name: 'Frank Black', position: 'Sales Rep', salary: 80_000))

company.add(engineering)
company.add(sales)

puts company.display
puts
puts "Total employees: #{company.total_members}"
puts "Total salary budget: $#{company.total_salary}"
avg = company.total_members.positive? ? (company.total_salary.to_f / company.total_members).round(2) : 0
puts "Average salary: $#{avg}"

puts

# ========================================
# Example 4: File System Operations
# ========================================
puts '--- Example 4: File System Operations ---'
puts

workspace = Composite::Directory.new('workspace')

# Add files
workspace.add(Composite::File.new('index.html', content_size: 3000))
workspace.add(Composite::File.new('style.css', content_size: 2000))

# Add subdirectory with files
js_dir = Composite::Directory.new('js')
js_dir.add(Composite::File.new('app.js', content_size: 8000))
js_dir.add(Composite::File.new('utils.js', content_size: 1500))

workspace.add(js_dir)

puts 'Initial structure:'
puts workspace.display
puts

# Remove a file
file_to_remove = workspace.find('style.css')
workspace.remove(file_to_remove) if file_to_remove
puts "\nAfter removing style.css:"
puts workspace.display
puts

# Statistics
puts "\nStatistics:"
puts "  Total files: #{workspace.files.size}"
puts "  Total directories: #{workspace.directories.size}"
puts "  Is empty? #{workspace.empty?}"

puts

# ========================================
# Example 5: Traversing the Tree
# ========================================
puts '--- Example 5: Tree Traversal ---'
puts

root = Composite::Directory.new('root')
dir1 = Composite::Directory.new('dir1')
dir2 = Composite::Directory.new('dir2')

dir1.add(Composite::File.new('file1.txt', content_size: 100))
dir1.add(Composite::File.new('file2.txt', content_size: 200))
dir2.add(Composite::File.new('file3.txt', content_size: 300))

root.add(dir1)
root.add(dir2)
root.add(Composite::File.new('root_file.txt', content_size: 150))

puts 'All files in the tree:'
def find_all_files(component, files = [])
  if component.leaf?
    files << component
  else
    component.children.each { |child| find_all_files(child, files) }
  end
  files
end

all_files = find_all_files(root)
all_files.each do |file|
  puts "  #{file.path} (#{file.size} bytes)"
end

puts
puts '=' * 60
puts 'End of Composite Pattern Demo'
puts '=' * 60
