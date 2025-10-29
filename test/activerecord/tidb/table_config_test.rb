require "test_helper"

class AutoIdCache < ActiveRecord::Migration[7.2]
  def change
    create_table :users, auto_id_cache: 1 do |t|
      t.string "name"
    end
  end
end

class ShardRowIdBits < ActiveRecord::Migration[7.2]
  def change
    create_table :users, clustered: false, shard_row_id_bits: 4 do |t|
      t.string "name"
    end
  end
end

class PreSplitRegions < ActiveRecord::Migration[7.2]
  def change
    create_table :users, clustered: false, shard_row_id_bits: 4, pre_split_regions: 2 do |t|
      t.string "name"
    end
  end
end

class Activerecord::Tidb::AdapterTest < Minitest::Test
  def test_auto_id_cache
    migrate(AutoIdCache)

    result = connection.execute("SHOW CREATE TABLE users")
    _, query = result.first
    expected_query = <<~QUERY.strip
      CREATE TABLE `users` (
        `id` bigint NOT NULL AUTO_INCREMENT,
        `name` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin /*T![auto_id_cache] AUTO_ID_CACHE=1 */
    QUERY
    assert_equal expected_query, query
  end

  def test_shard_row_id_bits
    migrate(ShardRowIdBits)

    result = connection.execute("SHOW CREATE TABLE users")
    _, query = result.first
    expected_query = <<~QUERY.strip
      CREATE TABLE `users` (
        `id` bigint NOT NULL AUTO_INCREMENT,
        `name` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`id`) /*T![clustered_index] NONCLUSTERED */
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin /*T! SHARD_ROW_ID_BITS=4 */
    QUERY
    assert_equal expected_query, query
  end

  def test_pre_split_regions
    migrate(PreSplitRegions)

    result = connection.execute("SHOW CREATE TABLE users")
    _, query = result.first
    expected_query = <<~QUERY.strip
      CREATE TABLE `users` (
        `id` bigint NOT NULL AUTO_INCREMENT,
        `name` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`id`) /*T![clustered_index] NONCLUSTERED */
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin /*T! SHARD_ROW_ID_BITS=4 PRE_SPLIT_REGIONS=2 */
    QUERY
    assert_equal expected_query, query
  end
end
