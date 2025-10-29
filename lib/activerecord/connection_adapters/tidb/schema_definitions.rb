module ActiveRecord
  module ConnectionAdapters
    module TiDB
      PrimaryKeyDefinition = Struct.new(:name, :clustered) # :nodoc:

      class TableDefinition < MySQL::TableDefinition
        attr_reader :clustered, :shard_row_id_bits, :pre_split_regions

        def initialize(conn, name, charset: nil, collation: nil, clustered: nil, shard_row_id_bits: nil, pre_split_regions: nil, **)
          @clustered = clustered
          @shard_row_id_bits = shard_row_id_bits
          @pre_split_regions = pre_split_regions
          super(conn, name, charset: charset, collation: collation)
        end

        def set_primary_key(table_name, id, primary_key, **options)
          if id
            pk = primary_key || Base.get_primary_key(table_name.to_s.singularize)

            if id.is_a?(Hash)
              options.merge!(id.except(:type))
              id = id.fetch(:type, :primary_key)
            end

            if pk.is_a?(Array)
              primary_keys(pk, @clustered)
            else
              options[:clustered] = @clustered
              primary_key(pk, id, **options)
            end
          end
        end

        def primary_keys(name = nil, clustered = nil)
          @primary_keys = TiDB::PrimaryKeyDefinition.new(name, clustered) if name
          @primary_keys
        end

        def new_column_definition(name, type, **options)
          if @shard_row_id_bits
            options[:shard_row_id_bits] = @shard_row_id_bits
          end
          if @pre_split_regions
            options[:pre_split_regions] = @pre_split_regions
          end
          super(name, type, **options)
        end

        private
          def valid_column_definition_options
            super + [:clustered, :shard_row_id_bits, :pre_split_regions]
          end
      end
    end
  end
end