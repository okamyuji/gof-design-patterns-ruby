# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/creational/builder/builder'

class TestBuilder < GofPatternTest
  def test_basic_builder_usage
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    profile = builder
              .set_id('user-001')
              .set_name('John Doe')
              .set_age(30)
              .build

    assert_equal 'user-001', profile.id
    assert_equal 'John Doe', profile.name
    assert_equal 30, profile.age
  end

  def test_builder_requires_id
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    builder.set_name('John Doe')

    assert_raises(ArgumentError) do
      builder.build
    end
  end

  def test_builder_requires_name
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    builder.set_id('user-001')

    assert_raises(ArgumentError) do
      builder.build
    end
  end

  def test_builder_with_address
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    profile = builder
              .set_id('user-001')
              .set_name('John Doe')
              .set_address(
                postal_code: '100-0001',
                prefecture: 'Tokyo',
                city: 'Chiyoda',
                street: '1-1-1',
                building: 'Sample Building'
              )
              .build

    assert_instance_of GofPatterns::Creational::Builder::Address, profile.address
    assert_equal '100-0001 Tokyo Chiyoda 1-1-1 Sample Building', profile.address.full_address
  end

  def test_builder_with_contact
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    profile = builder
              .set_id('user-001')
              .set_name('John Doe')
              .set_contact(email: 'john@example.com', phone: '090-1234-5678')
              .build

    assert_equal 'john@example.com', profile.contact.email
    assert_equal '090-1234-5678', profile.contact.phone
  end

  def test_builder_with_preferences
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    profile = builder
              .set_id('user-001')
              .set_name('John Doe')
              .add_preference(:theme, 'dark')
              .add_preference(:language, 'ja')
              .build

    assert_equal 'dark', profile.preferences[:theme]
    assert_equal 'ja', profile.preferences[:language]
  end

  def test_builder_reset
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    builder.set_id('user-001').set_name('John')

    builder.reset

    assert_raises(ArgumentError) do
      builder.build
    end
  end

  def test_fluent_builder
    builder = GofPatterns::Creational::Builder::FluentUserProfileBuilder.new
    profile = builder
              .id('user-002')
              .name('Jane Doe')
              .age(25)
              .preference(:newsletter, true)
              .build

    assert_equal 'user-002', profile.id
    assert_equal 'Jane Doe', profile.name
    assert_equal 25, profile.age
    assert_equal true, profile.preferences[:newsletter]
  end

  def test_fluent_builder_with_block_address
    builder = GofPatterns::Creational::Builder::FluentUserProfileBuilder.new
    profile = builder
              .id('user-003')
              .name('Bob')
              .address do
                postal_code '123-4567'
                prefecture 'Osaka'
                city 'Namba'
                street '2-2-2'
              end
              .build

    assert_equal '123-4567', profile.address.postal_code
    assert_equal 'Osaka', profile.address.prefecture
  end

  def test_director_minimal_profile
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    director = GofPatterns::Creational::Builder::UserProfileDirector.new(builder)

    profile = director.build_minimal_profile(id: 'min-001', name: 'Minimal User')

    assert_equal 'min-001', profile.id
    assert_equal 'Minimal User', profile.name
    assert_nil profile.age
    assert_nil profile.address
  end

  def test_director_business_profile
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    director = GofPatterns::Creational::Builder::UserProfileDirector.new(builder)

    profile = director.build_business_profile(
      id: 'biz-001',
      name: 'Business User',
      company_email: 'business@corp.com',
      company_phone: '03-1234-5678'
    )

    assert_equal :business, profile.preferences[:account_type]
    assert_equal 'business@corp.com', profile.contact.email
  end

  def test_profile_factory_dsl
    profile = GofPatterns::Creational::Builder::ProfileFactory.create do
      id 'dsl-001'
      name 'DSL User'
      age 40
      preference :vip, true
    end

    assert_equal 'dsl-001', profile.id
    assert_equal 'DSL User', profile.name
    assert_equal 40, profile.age
    assert_equal true, profile.preferences[:vip]
  end

  def test_address_value_object
    addr1 = GofPatterns::Creational::Builder::Address.new(
      postal_code: '100-0001',
      prefecture: 'Tokyo',
      city: 'Chiyoda',
      street: '1-1'
    )
    addr2 = GofPatterns::Creational::Builder::Address.new(
      postal_code: '100-0001',
      prefecture: 'Tokyo',
      city: 'Chiyoda',
      street: '1-1'
    )

    assert_equal addr1, addr2
    assert addr1.frozen?
  end

  def test_contact_value_object
    contact1 = GofPatterns::Creational::Builder::Contact.new(email: 'test@example.com')
    contact2 = GofPatterns::Creational::Builder::Contact.new(email: 'test@example.com')

    assert_equal contact1, contact2
    assert contact1.frozen?
  end

  def test_profile_to_hash
    builder = GofPatterns::Creational::Builder::UserProfileBuilder.new
    profile = builder
              .set_id('hash-001')
              .set_name('Hash User')
              .set_age(35)
              .build

    hash = profile.to_h

    assert_equal 'hash-001', hash[:id]
    assert_equal 'Hash User', hash[:name]
    assert_equal 35, hash[:age]
  end
end
