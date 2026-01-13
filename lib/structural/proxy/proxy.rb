# frozen_string_literal: true

module GofPatterns
  module Structural
    # Proxy Pattern (プロキシパターン)
    # ================================
    # 目的: 他のオブジェクトへのアクセスを制御する代理を提供する
    #
    # DDD Context:
    # - Repository のキャッシュ層
    # - 遅延ロード
    # - アクセス制御

    module Proxy
      # Subject Interface: 画像
      class Image
        def display
          raise NotImplementedError
        end

        def width
          raise NotImplementedError
        end

        def height
          raise NotImplementedError
        end

        def filename
          raise NotImplementedError
        end
      end

      # Real Subject: 実際の画像
      class RealImage < Image
        attr_reader :filename, :width, :height

        def initialize(filename)
          @filename = filename
          @width = 0
          @height = 0
          load_from_disk
        end

        def display
          "Displaying image: #{filename} (#{width}x#{height})"
        end

        private

        def load_from_disk
          # 重い処理をシミュレート
          @width = rand(800..1920)
          @height = rand(600..1080)
          @loaded = true
        end
      end

      # Virtual Proxy: 遅延ロードプロキシ
      class LazyImageProxy < Image
        def initialize(filename)
          @filename = filename
          @real_image = nil
        end

        def display
          load_image
          @real_image.display
        end

        def width
          load_image
          @real_image.width
        end

        def height
          load_image
          @real_image.height
        end

        def filename
          @filename
        end

        def loaded?
          !@real_image.nil?
        end

        private

        def load_image
          @real_image ||= RealImage.new(@filename)
        end
      end

      # Protection Proxy: アクセス制御プロキシ
      class ProtectedImageProxy < Image
        def initialize(filename, user_role:)
          @filename = filename
          @user_role = user_role
          @real_image = nil
        end

        def display
          check_access!(:read)
          load_image
          @real_image.display
        end

        def width
          check_access!(:read)
          load_image
          @real_image.width
        end

        def height
          check_access!(:read)
          load_image
          @real_image.height
        end

        def filename
          @filename
        end

        def delete
          check_access!(:admin)
          "Deleted: #{@filename}"
        end

        private

        ACCESS_LEVELS = {
          guest: [],
          user: [:read],
          admin: %i[read write delete admin]
        }.freeze

        def check_access!(permission)
          allowed = ACCESS_LEVELS.fetch(@user_role, [])
          raise SecurityError, "Access denied: #{permission}" unless allowed.include?(permission)
        end

        def load_image
          @real_image ||= RealImage.new(@filename)
        end
      end

      # Caching Proxy: キャッシュプロキシ
      class CachingImageProxy < Image
        def initialize(filename, cache:)
          @filename = filename
          @cache = cache
        end

        def display
          cached_display || fetch_and_cache_display
        end

        def width
          get_metadata[:width]
        end

        def height
          get_metadata[:height]
        end

        def filename
          @filename
        end

        def cache_hit?
          @cache.key?(cache_key(:display))
        end

        def invalidate_cache
          @cache.delete(cache_key(:display))
          @cache.delete(cache_key(:metadata))
        end

        private

        def cache_key(type)
          "#{@filename}:#{type}"
        end

        def cached_display
          @cache[cache_key(:display)]
        end

        def fetch_and_cache_display
          image = RealImage.new(@filename)
          result = image.display
          @cache[cache_key(:display)] = result
          @cache[cache_key(:metadata)] = { width: image.width, height: image.height }
          result
        end

        def get_metadata
          @cache[cache_key(:metadata)] || fetch_metadata
        end

        def fetch_metadata
          image = RealImage.new(@filename)
          metadata = { width: image.width, height: image.height }
          @cache[cache_key(:metadata)] = metadata
          metadata
        end
      end

      # ===== データベースアクセス例 =====

      # Subject Interface: データベースクエリ
      class DatabaseQuery
        def execute(sql)
          raise NotImplementedError
        end

        def fetch_all(table)
          raise NotImplementedError
        end

        def find_by_id(table, id)
          raise NotImplementedError
        end
      end

      # Real Subject: 実際のデータベース接続
      class RealDatabaseQuery < DatabaseQuery
        def initialize
          @data = {
            users: [
              { id: 1, name: 'Alice', email: 'alice@example.com' },
              { id: 2, name: 'Bob', email: 'bob@example.com' },
              { id: 3, name: 'Charlie', email: 'charlie@example.com' }
            ],
            products: [
              { id: 1, name: 'Widget', price: 100 },
              { id: 2, name: 'Gadget', price: 200 }
            ]
          }
        end

        def execute(sql)
          # SQLパースのシミュレーション
          { result: 'Query executed', sql: sql }
        end

        def fetch_all(table)
          @data[table.to_sym] || []
        end

        def find_by_id(table, id)
          records = @data[table.to_sym] || []
          records.find { |r| r[:id] == id }
        end
      end

      # Logging Proxy: ログ記録プロキシ
      class LoggingDatabaseProxy < DatabaseQuery
        def initialize(real_db, logger: nil)
          @real_db = real_db
          @logger = logger || ->(msg) { puts "[DB LOG] #{msg}" }
          @query_count = 0
        end

        def execute(sql)
          log("Executing SQL: #{sql}")
          start = Time.now
          result = @real_db.execute(sql)
          log("Query completed in #{((Time.now - start) * 1000).round(2)}ms")
          @query_count += 1
          result
        end

        def fetch_all(table)
          log("Fetching all from #{table}")
          @query_count += 1
          @real_db.fetch_all(table)
        end

        def find_by_id(table, id)
          log("Finding #{table}##{id}")
          @query_count += 1
          @real_db.find_by_id(table, id)
        end

        def query_count
          @query_count
        end

        def reset_count
          @query_count = 0
        end

        private

        def log(message)
          @logger.call(message)
        end
      end

      # Caching Proxy: クエリキャッシュプロキシ
      class CachingDatabaseProxy < DatabaseQuery
        def initialize(real_db, ttl: 60)
          @real_db = real_db
          @cache = {}
          @ttl = ttl
          @stats = { hits: 0, misses: 0 }
        end

        def execute(sql)
          # executeはキャッシュしない（副作用の可能性）
          @real_db.execute(sql)
        end

        def fetch_all(table)
          cache_key = "fetch_all:#{table}"
          cached = get_cached(cache_key)
          return cached if cached

          @stats[:misses] += 1
          result = @real_db.fetch_all(table)
          set_cached(cache_key, result)
          result
        end

        def find_by_id(table, id)
          cache_key = "find:#{table}:#{id}"
          cached = get_cached(cache_key)
          return cached if cached

          @stats[:misses] += 1
          result = @real_db.find_by_id(table, id)
          set_cached(cache_key, result)
          result
        end

        def cache_stats
          total = @stats[:hits] + @stats[:misses]
          hit_rate = total.zero? ? 0 : (@stats[:hits].to_f / total * 100).round(2)
          @stats.merge(hit_rate: hit_rate)
        end

        def clear_cache
          @cache.clear
          @stats = { hits: 0, misses: 0 }
        end

        private

        def get_cached(key)
          entry = @cache[key]
          return nil unless entry
          return nil if Time.now > entry[:expires_at]

          @stats[:hits] += 1
          entry[:value]
        end

        def set_cached(key, value)
          @cache[key] = {
            value: value,
            expires_at: Time.now + @ttl
          }
        end
      end

      # Smart Proxy: 参照カウントプロキシ
      class SmartReferenceProxy < DatabaseQuery
        def initialize(real_db)
          @real_db = real_db
          @reference_count = 0
          @mutex = Mutex.new
        end

        def execute(sql)
          with_reference { @real_db.execute(sql) }
        end

        def fetch_all(table)
          with_reference { @real_db.fetch_all(table) }
        end

        def find_by_id(table, id)
          with_reference { @real_db.find_by_id(table, id) }
        end

        def reference_count
          @mutex.synchronize { @reference_count }
        end

        private

        def with_reference
          @mutex.synchronize { @reference_count += 1 }
          begin
            yield
          ensure
            @mutex.synchronize { @reference_count -= 1 }
          end
        end
      end

      # Domain Service: プロキシファクトリ
      class DatabaseProxyFactory
        LOGGING_OPTIONS = %i[logger].freeze
        CACHING_OPTIONS = %i[ttl].freeze

        def self.create(type, real_db = RealDatabaseQuery.new, **options)
          case type
          when :logging
            LoggingDatabaseProxy.new(real_db, **filter_options(options, LOGGING_OPTIONS))
          when :caching
            CachingDatabaseProxy.new(real_db, **filter_options(options, CACHING_OPTIONS))
          when :smart
            SmartReferenceProxy.new(real_db)
          when :full
            # 複数のプロキシを組み合わせ
            logging_opts = filter_options(options, LOGGING_OPTIONS)
            caching_opts = filter_options(options, CACHING_OPTIONS)
            logging = LoggingDatabaseProxy.new(real_db, **logging_opts)
            CachingDatabaseProxy.new(logging, **caching_opts)
          else
            real_db
          end
        end

        def self.filter_options(options, allowed_keys)
          options.select { |k, _| allowed_keys.include?(k) }
        end
        private_class_method :filter_options
      end
    end
  end
end
