module ActiveRecord
  module ConnectionAdapters
    module TiDB
      class SchemaCreation < MySQL::SchemaCreation
        private
          def visit_PrimaryKeyDefinition(o)
            sql = "PRIMARY KEY"
            sql << " (#{o.name.map { |name| quote_column_name(name) }.join(', ')})"
            sql <<
              if o.clustered
                " CLUSTERED"
              else
                " NONCLUSTERED"
              end
            sql
          end
      end
    end
  end
end