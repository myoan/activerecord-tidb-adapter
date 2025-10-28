module ActiveRecord
  module ConnectionAdapters
    module TiDB
      class SchemaCreation < MySQL::SchemaCreation
        private
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