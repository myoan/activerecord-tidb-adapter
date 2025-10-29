module ActiveRecord
  module ConnectionAdapters
    module TiDB
      module SchemaStatements
        def schema_creation
          TiDB::SchemaCreation.new(self)
        end

        def create_table_definition(name, **options)
          TiDB::TableDefinition.new(self, name, **options)
        end

        def valid_table_definition_options # :nodoc:
          super + [:auto_id_cache, :clustered, :pre_split_regions, :shard_row_id_bits]
        end
      end
    end
  end
end