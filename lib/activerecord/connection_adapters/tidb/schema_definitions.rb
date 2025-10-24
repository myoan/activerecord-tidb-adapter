module ActiveRecord
  module ConnectionAdapters
    module TiDB
      PrimaryKeyDefinition = Struct.new(:name, :clustered) # :nodoc:

      class TableDefinition < MySQL::TableDefinition
        def set_primary_key(table_name, id, primary_key, **options)
          # NOTE: primary_key array might include hash
          # ex: [:id, clustered: false]
          pp options
          pkey_opt =
            if primary_key && primary_key.length > 0 && primary_key.last.class == Hash
              primary_key.pop
            else
              {}
            end

          if id
            pk = primary_key || Base.get_primary_key(table_name.to_s.singularize)

            if id.is_a?(Hash)
              options.merge!(id.except(:type))
              id = id.fetch(:type, :primary_key)
            end

            if pk.is_a?(Array)
              primary_keys(pk, clustered: pkey_opt[:clustered])
            else
              options[:clustered] = pkey_opt[:clustered] if pkey_opt.key(:clustered)
              primary_key(pk, id, pkey_opt[:clustered], **options)
            end
          end
        end

        def primary_keys(name = nil, clustered = nil)
          @primary_keys = TiDB::PrimaryKeyDefinition.new(name, clustered[:clustered]) if name
          @primary_keys
        end

        def primary_key(name, type = :primary_key, clustered = nil, **options)
          super(name, type, **options)

          @primary_keys = TiDB::PrimaryKeyDefinition.new(@primary_keys.name, clustered) if clustered && @primary_keys
        end
      end
    end
  end
end