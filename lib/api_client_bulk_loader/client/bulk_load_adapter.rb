module ApiClientBulkLoader
  module Client
    #Adapts into the bulk loader. Mainly useful for storing the details of the bulk call.
    class BulkLoadAdapter
      attr_reader :attribute, :autoload, :values_from, :limit

      def initialize(attribute = nil, values_from = nil, autoload = false, is_has_one = false, limit = nil)
        @attribute = attribute
        @autoload = autoload
        @values_from = values_from || "#{attribute}_id"
        @has_one = is_has_one
        @limit = limit
      end

      def bulk_loader
        RequestStore.store[:bulk_loader] ||= ApiClientBulkLoader::Client::Loader.new
        return RequestStore.store[:bulk_loader]
      end

      def push
        raise Exception.new("Child class should define push!")
      end

      def fetch
        raise Exception.new("Child class should define fetch!")
      end
    end
  end
end