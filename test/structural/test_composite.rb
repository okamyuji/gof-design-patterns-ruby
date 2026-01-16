# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/composite/composite'

class TestComposite < GofPatternTest
  def test_file_creation
    file = GofPatterns::Structural::Composite::File.new('test.txt', content_size: 100)

    assert_equal 'test.txt', file.name
    assert_equal 100, file.size
    assert_equal '.txt', file.extension
    assert_predicate file, :leaf?
  end

  def test_directory_creation
    dir = GofPatterns::Structural::Composite::Directory.new('src')

    assert_equal 'src', dir.name
    assert_equal 0, dir.size
    refute_predicate dir, :leaf?
    assert_predicate dir, :composite?
    assert_empty dir
  end

  def test_directory_add_file
    dir = GofPatterns::Structural::Composite::Directory.new('docs')
    file = GofPatterns::Structural::Composite::File.new('readme.md', content_size: 500)

    dir.add(file)

    assert_equal 1, dir.count
    assert_equal 500, dir.size
    assert_equal dir, file.parent
  end

  def test_directory_nested_structure
    root = GofPatterns::Structural::Composite::Directory.new('project')
    src = GofPatterns::Structural::Composite::Directory.new('src')
    file1 = GofPatterns::Structural::Composite::File.new('main.rb', content_size: 1000)
    file2 = GofPatterns::Structural::Composite::File.new('helper.rb', content_size: 500)

    src.add(file1).add(file2)
    root.add(src)

    assert_equal 1500, root.size
    assert_equal 'project/src/main.rb', file1.path
  end

  def test_directory_find
    root = GofPatterns::Structural::Composite::Directory.new('root')
    sub = GofPatterns::Structural::Composite::Directory.new('sub')
    file = GofPatterns::Structural::Composite::File.new('target.txt', content_size: 100)

    sub.add(file)
    root.add(sub)

    found = root.find('target.txt')

    assert_equal file, found

    not_found = root.find('missing.txt')

    assert_nil not_found
  end

  def test_directory_remove
    dir = GofPatterns::Structural::Composite::Directory.new('test')
    file = GofPatterns::Structural::Composite::File.new('temp.txt', content_size: 50)

    dir.add(file)

    assert_equal 1, dir.count

    dir.remove(file)

    assert_equal 0, dir.count
    assert_nil file.parent
  end

  def test_directory_files_and_directories
    dir = GofPatterns::Structural::Composite::Directory.new('mixed')
    file1 = GofPatterns::Structural::Composite::File.new('a.txt', content_size: 100)
    file2 = GofPatterns::Structural::Composite::File.new('b.txt', content_size: 200)
    subdir = GofPatterns::Structural::Composite::Directory.new('subdir')

    dir.add(file1).add(subdir).add(file2)

    assert_equal 2, dir.files.size
    assert_equal 1, dir.directories.size
  end

  def test_directory_deep_files
    root = GofPatterns::Structural::Composite::Directory.new('root')
    sub1 = GofPatterns::Structural::Composite::Directory.new('sub1')
    sub2 = GofPatterns::Structural::Composite::Directory.new('sub2')
    file1 = GofPatterns::Structural::Composite::File.new('f1.txt', content_size: 100)
    file2 = GofPatterns::Structural::Composite::File.new('f2.txt', content_size: 100)
    file3 = GofPatterns::Structural::Composite::File.new('f3.txt', content_size: 100)

    sub2.add(file3)
    sub1.add(file2).add(sub2)
    root.add(file1).add(sub1)

    deep_files = root.deep_files

    assert_equal 3, deep_files.size
  end

  def test_display_output
    root = GofPatterns::Structural::Composite::Directory.new('project')
    file = GofPatterns::Structural::Composite::File.new('main.rb', content_size: 500)
    root.add(file)

    output = root.display

    assert_match(/project/, output)
    assert_match(/main\.rb/, output)
  end

  def test_employee_creation
    emp = GofPatterns::Structural::Composite::Employee.new(
      id: 'EMP-001',
      name: 'John',
      position: 'Developer',
      salary: 50_000
    )

    assert_equal 'John', emp.name
    assert_equal 1, emp.total_members
    assert_equal 50_000, emp.total_salary
  end

  def test_department_with_employees
    dept = GofPatterns::Structural::Composite::Department.new(id: 'DEPT-001', name: 'Engineering')
    emp1 = GofPatterns::Structural::Composite::Employee.new(id: 'E1', name: 'Alice', position: 'Lead', salary: 80_000)
    emp2 = GofPatterns::Structural::Composite::Employee.new(id: 'E2', name: 'Bob', position: 'Dev', salary: 60_000)

    dept.add(emp1).add(emp2)

    assert_equal 2, dept.total_members
    assert_equal 140_000, dept.total_salary
  end

  def test_nested_departments
    company = GofPatterns::Structural::Composite::Department.new(id: 'C1', name: 'Company')
    eng = GofPatterns::Structural::Composite::Department.new(id: 'D1', name: 'Engineering')
    sales = GofPatterns::Structural::Composite::Department.new(id: 'D2', name: 'Sales')

    eng.add(GofPatterns::Structural::Composite::Employee.new(id: 'E1', name: 'Dev1', position: 'Dev', salary: 50_000))
    eng.add(GofPatterns::Structural::Composite::Employee.new(id: 'E2', name: 'Dev2', position: 'Dev', salary: 50_000))
    sales.add(GofPatterns::Structural::Composite::Employee.new(id: 'E3', name: 'Sales1', position: 'Rep',
                                                               salary: 40_000))

    company.add(eng).add(sales)

    assert_equal 3, company.total_members
    assert_equal 140_000, company.total_salary
  end

  def test_find_employee
    company = GofPatterns::Structural::Composite::Department.new(id: 'C1', name: 'Company')
    dept = GofPatterns::Structural::Composite::Department.new(id: 'D1', name: 'Dept')
    emp = GofPatterns::Structural::Composite::Employee.new(id: 'TARGET', name: 'Target', position: 'Dev',
                                                           salary: 50_000)

    dept.add(emp)
    company.add(dept)

    found = company.find_employee('TARGET')

    assert_equal emp, found

    not_found = company.find_employee('MISSING')

    assert_nil not_found
  end

  def test_file_system_builder
    fs = GofPatterns::Structural::Composite::FileSystemBuilder.new
                                                              .root('project')
                                                              .directory('src') do
                                                                file 'main.rb', size: 1000
                                                                file 'helper.rb', size: 500
    end
                                                              .directory('test') do
                                                                file 'test_main.rb', size: 800
    end
                                                              .build

    assert_equal 2300, fs.size
    assert_equal 2, fs.directories.size
  end

  def test_organization_builder
    org = GofPatterns::Structural::Composite::OrganizationBuilder.new
                                                                 .company('Tech Corp')
                                                                 .department('Engineering') do
                                                                   employee 'Alice', position: 'Lead', salary: 100_000
                                                                   employee 'Bob', position: 'Dev', salary: 80_000
    end
                                                                 .department('Sales') do
                                                                   employee 'Charlie', position: 'Manager',
                                                                                       salary: 90_000
    end
                                                                 .build

    assert_equal 3, org.total_members
    assert_equal 270_000, org.total_salary
  end
end
