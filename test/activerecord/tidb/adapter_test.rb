require "test_helper"

class CreateUser < ActiveRecord::Migration[7.2]
  def change
    create_table :users, primary_key: [:id, clustered: true] do |t|
      t.bigint "id", null: false
      t.string "name"
      t.string "city"
    end
  end
end

class Activerecord::Tidb::AdapterTest < Minitest::Test
  attr_reader :connection

  def setup
    @connection = ActiveRecord::Base.lease_connection
  end

  def teardown
    connection.drop_table :users if connection.table_exists?(:users)
  end

  def test_migration
    migrate(CreateUser)

    result = connection.execute("SHOW CREATE TABLE users")
    table_name, query = result.first
    expected_query = <<~QUERY.strip
      CREATE TABLE `users` (
        `id` bigint NOT NULL,
        `name` varchar(255) DEFAULT NULL,
        `city` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
    QUERY
    assert_equal expected_query, query
  end
end
