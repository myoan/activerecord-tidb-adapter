$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "activerecord/tidb/adapter"
require "activerecord-tidb-adapter"
require "active_record"

require "minitest/autorun"

conn_opt = {
  adapter: "tidb",
  database: "tidb_test",
  host: "127.0.0.1",
  port: 4000,
  username: "root",
  password: ""
}

ActiveRecord::ConnectionAdapters.register("tidb", "ActiveRecord::ConnectionAdapters::TidbAdapter", "active_record/connection_adapters/tidb_adapter")
ActiveRecord::Base.establish_connection(**conn_opt)

class Minitest::Test
  def migrate(migration, direction: :up, version: 1)
    schema_migration = ActiveRecord::Base.connection_pool.schema_migration
    schema_migration.create_table
    schema_migration.delete_all_versions
    migration.version ||= 123

    args = [schema_migration, ActiveRecord::Base.connection_pool.internal_metadata]
    ActiveRecord::Migrator.new(direction, [migration], *args).migrate
    true
  end
end