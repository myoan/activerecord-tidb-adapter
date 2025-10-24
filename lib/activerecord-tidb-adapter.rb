require "activerecord/tidb/adapter/version"
require "activerecord/connection_adapters/tidb_adapter"

if defined?(Rails)
  module ActiveRecord
    module ConnectionAdapters
      class TidbRailtie < ::Rails::Railtie
        ActiveSupport.on_load :active_record do
          ActiveRecord::ConnectionAdapters.register("tidb", "ActiveRecord::ConnectionAdapters::TidbAdapter", "active_record/connection_adapters/tidb_adapter")
        end
      end
    end
  end
end
