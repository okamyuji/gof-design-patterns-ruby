# frozen_string_literal: true

module GofPatterns
  module Creational
    # Builder Pattern (ビルダーパターン)
    # ==================================
    # 目的: 複雑なオブジェクトの構築を段階的に行い、
    #       構築プロセスと表現を分離する
    #
    # DDD Context:
    # - 複雑なAggregate Rootの生成
    # - Value Objectの段階的構築

    module Builder
      # Value Object: 住所
      class Address
        attr_reader :postal_code, :prefecture, :city, :street, :building

        def initialize(postal_code:, prefecture:, city:, street:, building: nil)
          @postal_code = postal_code.freeze
          @prefecture = prefecture.freeze
          @city = city.freeze
          @street = street.freeze
          @building = building&.freeze
          freeze
        end

        def full_address
          parts = [postal_code, prefecture, city, street]
          parts << building if building
          parts.join(' ')
        end

        def ==(other)
          return false unless other.is_a?(Address)

          postal_code == other.postal_code &&
            prefecture == other.prefecture &&
            city == other.city &&
            street == other.street &&
            building == other.building
        end
        alias eql? ==

        def hash
          [postal_code, prefecture, city, street, building].hash
        end
      end

      # Value Object: 連絡先
      class Contact
        attr_reader :email, :phone

        def initialize(email: nil, phone: nil)
          @email = email&.freeze
          @phone = phone&.freeze
          freeze
        end

        def ==(other)
          return false unless other.is_a?(Contact)

          email == other.email && phone == other.phone
        end
        alias eql? ==

        def hash
          [email, phone].hash
        end
      end

      # Entity: ユーザープロファイル（構築対象）
      class UserProfile
        attr_reader :id, :name, :age, :address, :contact, :preferences, :created_at

        def initialize(id:, name:, age: nil, address: nil, contact: nil, preferences: {})
          @id = id
          @name = name
          @age = age
          @address = address
          @contact = contact
          @preferences = preferences.freeze
          @created_at = Time.now
        end

        def to_h
          {
            id: id,
            name: name,
            age: age,
            address: address&.full_address,
            email: contact&.email,
            phone: contact&.phone,
            preferences: preferences,
            created_at: created_at.iso8601
          }
        end

        def ==(other)
          return false unless other.is_a?(UserProfile)

          id == other.id
        end
        alias eql? ==

        def hash
          id.hash
        end
      end

      # Builder: ユーザープロファイルビルダー（抽象）
      class UserProfileBuilder
        def initialize
          reset
        end

        def reset
          @id = nil
          @name = nil
          @age = nil
          @address = nil
          @contact = nil
          @preferences = {}
          self
        end

        def set_id(id)
          @id = id
          self
        end

        def set_name(name)
          @name = name
          self
        end

        def set_age(age)
          @age = age
          self
        end

        def set_address(postal_code:, prefecture:, city:, street:, building: nil)
          @address = Address.new(
            postal_code: postal_code,
            prefecture: prefecture,
            city: city,
            street: street,
            building: building
          )
          self
        end

        def set_contact(email: nil, phone: nil)
          @contact = Contact.new(email: email, phone: phone)
          self
        end

        def add_preference(key, value)
          @preferences[key.to_sym] = value
          self
        end

        def build
          validate!
          UserProfile.new(
            id: @id,
            name: @name,
            age: @age,
            address: @address,
            contact: @contact,
            preferences: @preferences
          )
        end

        private

        def validate!
          raise ArgumentError, 'ID is required' if @id.nil?
          raise ArgumentError, 'Name is required' if @name.nil? || @name.empty?
        end
      end

      # Fluent Builder: DSL風インターフェースを提供
      class FluentUserProfileBuilder < UserProfileBuilder
        def id(value)
          set_id(value)
        end

        def name(value)
          set_name(value)
        end

        def age(value)
          set_age(value)
        end

        def address(&)
          builder = AddressBuilder.new
          builder.instance_eval(&) if block_given?
          @address = builder.build
          self
        end

        def contact(&)
          builder = ContactBuilder.new
          builder.instance_eval(&) if block_given?
          @contact = builder.build
          self
        end

        def preference(key, value)
          add_preference(key, value)
        end
      end

      # Helper Builder: 住所ビルダー
      class AddressBuilder
        def initialize
          @postal_code = nil
          @prefecture = nil
          @city = nil
          @street = nil
          @building = nil
        end

        def postal_code(value)
          @postal_code = value
          self
        end

        def prefecture(value)
          @prefecture = value
          self
        end

        def city(value)
          @city = value
          self
        end

        def street(value)
          @street = value
          self
        end

        def building(value)
          @building = value
          self
        end

        def build
          Address.new(
            postal_code: @postal_code,
            prefecture: @prefecture,
            city: @city,
            street: @street,
            building: @building
          )
        end
      end

      # Helper Builder: 連絡先ビルダー
      class ContactBuilder
        def initialize
          @email = nil
          @phone = nil
        end

        def email(value)
          @email = value
          self
        end

        def phone(value)
          @phone = value
          self
        end

        def build
          Contact.new(email: @email, phone: @phone)
        end
      end

      # Director: 構築プロセスを指示
      class UserProfileDirector
        def initialize(builder)
          @builder = builder
        end

        def build_minimal_profile(id:, name:)
          @builder.reset
                  .set_id(id)
                  .set_name(name)
                  .build
        end

        def build_full_profile(id:, name:, age:, address_params:, contact_params:, preferences: {})
          @builder.reset
                  .set_id(id)
                  .set_name(name)
                  .set_age(age)
                  .set_address(**address_params)
                  .set_contact(**contact_params)

          preferences.each { |k, v| @builder.add_preference(k, v) }

          @builder.build
        end

        def build_business_profile(id:, name:, company_email:, company_phone:)
          @builder.reset
                  .set_id(id)
                  .set_name(name)
                  .set_contact(email: company_email, phone: company_phone)
                  .add_preference(:account_type, :business)
                  .build
        end
      end

      # Domain Service: プロファイル生成サービス
      class ProfileFactory
        def self.create(&)
          builder = FluentUserProfileBuilder.new
          builder.instance_eval(&) if block_given?
          builder.build
        end
      end
    end
  end
end
