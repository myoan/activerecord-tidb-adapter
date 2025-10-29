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
          super + [:clustered, :shard_row_id_bits, :pre_split_regions]
        end
      end
    end
  end
end