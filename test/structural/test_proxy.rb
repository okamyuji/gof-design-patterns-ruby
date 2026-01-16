# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/structural/proxy/proxy'

class TestProxy < GofPatternTest
  def test_real_image_loads_on_creation
    image = GofPatterns::Structural::Proxy::RealImage.new('photo.jpg')

    assert_equal 'photo.jpg', image.filename
    assert_predicate image.width, :positive?
    assert_predicate image.height, :positive?
  end

  def test_lazy_proxy_defers_loading
    proxy = GofPatterns::Structural::Proxy::LazyImageProxy.new('large_photo.jpg')

    refute_predicate proxy, :loaded?
    assert_equal 'large_photo.jpg', proxy.filename

    # displayを呼ぶと読み込まれる
    proxy.display

    assert_predicate proxy, :loaded?
  end

  def test_lazy_proxy_delegates_display
    proxy = GofPatterns::Structural::Proxy::LazyImageProxy.new('test.jpg')

    result = proxy.display

    assert_match(/Displaying image: test\.jpg/, result)
  end

  def test_lazy_proxy_delegates_dimensions
    proxy = GofPatterns::Structural::Proxy::LazyImageProxy.new('test.jpg')

    assert_predicate proxy.width, :positive?
    assert_predicate proxy.height, :positive?
    assert_predicate proxy, :loaded?
  end

  def test_protected_proxy_allows_user_read
    proxy = GofPatterns::Structural::Proxy::ProtectedImageProxy.new('private.jpg', user_role: :user)

    result = proxy.display

    assert_match(/Displaying image/, result)
  end

  def test_protected_proxy_denies_guest_read
    proxy = GofPatterns::Structural::Proxy::ProtectedImageProxy.new('private.jpg', user_role: :guest)

    assert_raises(SecurityError) do
      proxy.display
    end
  end

  def test_protected_proxy_admin_can_delete
    proxy = GofPatterns::Structural::Proxy::ProtectedImageProxy.new('to_delete.jpg', user_role: :admin)

    result = proxy.delete

    assert_match(/Deleted/, result)
  end

  def test_protected_proxy_user_cannot_delete
    proxy = GofPatterns::Structural::Proxy::ProtectedImageProxy.new('protected.jpg', user_role: :user)

    assert_raises(SecurityError) do
      proxy.delete
    end
  end

  def test_caching_proxy_caches_display
    cache = {}
    proxy = GofPatterns::Structural::Proxy::CachingImageProxy.new('cached.jpg', cache: cache)

    refute_predicate proxy, :cache_hit?

    # 最初の呼び出し
    result1 = proxy.display

    assert_predicate proxy, :cache_hit?

    # キャッシュからの呼び出し
    result2 = proxy.display

    assert_equal result1, result2
  end

  def test_caching_proxy_invalidate
    cache = {}
    proxy = GofPatterns::Structural::Proxy::CachingImageProxy.new('temp.jpg', cache: cache)

    proxy.display

    assert_predicate proxy, :cache_hit?

    proxy.invalidate_cache

    refute_predicate proxy, :cache_hit?
  end

  def test_real_database_query
    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new

    users = db.fetch_all(:users)

    assert_equal 3, users.size

    user = db.find_by_id(:users, 1)

    assert_equal 'Alice', user[:name]
  end

  def test_logging_database_proxy
    logs = []
    logger = ->(msg) { logs << msg }

    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new
    proxy = GofPatterns::Structural::Proxy::LoggingDatabaseProxy.new(db, logger: logger)

    proxy.fetch_all(:users)
    proxy.find_by_id(:users, 1)

    assert_equal 2, proxy.query_count
    assert(logs.any? { |l| l.include?('Fetching all') })
    assert(logs.any? { |l| l.include?('Finding') })
  end

  def test_logging_proxy_reset_count
    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new
    proxy = GofPatterns::Structural::Proxy::LoggingDatabaseProxy.new(db, logger: ->(_) {})

    proxy.fetch_all(:users)

    assert_equal 1, proxy.query_count

    proxy.reset_count

    assert_equal 0, proxy.query_count
  end

  def test_caching_database_proxy_hits
    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new
    proxy = GofPatterns::Structural::Proxy::CachingDatabaseProxy.new(db)

    # 最初の呼び出し（キャッシュミス）
    proxy.fetch_all(:users)

    # 2回目の呼び出し（キャッシュヒット）
    proxy.fetch_all(:users)

    stats = proxy.cache_stats

    assert_equal 1, stats[:hits]
    assert_equal 1, stats[:misses]
    assert_in_delta(50.0, stats[:hit_rate])
  end

  def test_caching_database_proxy_find_by_id
    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new
    proxy = GofPatterns::Structural::Proxy::CachingDatabaseProxy.new(db)

    user1 = proxy.find_by_id(:users, 1)
    user2 = proxy.find_by_id(:users, 1)

    assert_equal user1, user2

    stats = proxy.cache_stats

    assert_equal 1, stats[:hits]
  end

  def test_caching_database_proxy_clear
    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new
    proxy = GofPatterns::Structural::Proxy::CachingDatabaseProxy.new(db)

    proxy.fetch_all(:users)
    proxy.clear_cache

    stats = proxy.cache_stats

    assert_equal 0, stats[:hits]
    assert_equal 0, stats[:misses]
  end

  def test_smart_reference_proxy
    db = GofPatterns::Structural::Proxy::RealDatabaseQuery.new
    proxy = GofPatterns::Structural::Proxy::SmartReferenceProxy.new(db)

    assert_equal 0, proxy.reference_count

    # 同時アクセスのシミュレーション
    threads = 3.times.map do
      Thread.new do
        proxy.fetch_all(:users)
      end
    end
    threads.each(&:join)

    assert_equal 0, proxy.reference_count
  end

  def test_database_proxy_factory_logging
    proxy = GofPatterns::Structural::Proxy::DatabaseProxyFactory.create(:logging, logger: ->(_) {})

    assert_instance_of GofPatterns::Structural::Proxy::LoggingDatabaseProxy, proxy
  end

  def test_database_proxy_factory_caching
    proxy = GofPatterns::Structural::Proxy::DatabaseProxyFactory.create(:caching)

    assert_instance_of GofPatterns::Structural::Proxy::CachingDatabaseProxy, proxy
  end

  def test_database_proxy_factory_smart
    proxy = GofPatterns::Structural::Proxy::DatabaseProxyFactory.create(:smart)

    assert_instance_of GofPatterns::Structural::Proxy::SmartReferenceProxy, proxy
  end

  def test_database_proxy_factory_full
    proxy = GofPatterns::Structural::Proxy::DatabaseProxyFactory.create(:full, logger: ->(_) {})

    assert_instance_of GofPatterns::Structural::Proxy::CachingDatabaseProxy, proxy
  end

  def test_database_proxy_factory_none
    proxy = GofPatterns::Structural::Proxy::DatabaseProxyFactory.create(:none)

    assert_instance_of GofPatterns::Structural::Proxy::RealDatabaseQuery, proxy
  end
end
