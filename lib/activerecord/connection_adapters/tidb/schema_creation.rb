module ActiveRecord
  module ConnectionAdapters
    module TiDB
      class SchemaCreation < MySQL::SchemaCreation
        private
          def add_table_options!(create_sql, o)
            if o.shard_row_id_bits
              create_sql << " SHARD_ROW_ID_BITS = #{o.shard_row_id_bits}"
            end
            if o.pre_split_regions
              create_sql << " PRE_SPLIT_REGIONS = #{o.pre_split_regions}"
            end
          end

          def visit_PrimaryKeyDefinition(o)
            sql = "PRIMARY KEY"
            sql << " (#{o.name.map { |name| quote_column_name(name) }.join(', ')})"
            sql <<
              case o.clustered
              when true
                " CLUSTERED"
              when false
                " NONCLUSTERED"
              else
                ""
              end
            sql
          end

          def add_column_options!(sql, options)
            sql = super(sql, options)
            if options[:primary_key] == true
              sql <<
                case options[:clustered]
                when true
                  " CLUSTERED"
                when false
                  " NONCLUSTERED"
                else
                  ""
                end
            end
            sql
          end
      end
    end
  end
end