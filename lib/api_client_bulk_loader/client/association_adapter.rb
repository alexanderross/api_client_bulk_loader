module ApiClientBulkLoader
  module Client
    #Adapts into the bulk loader. Mainly useful for storing the details of the bulk call.
    class AssociationAdapter
      attr_reader :resource_model, :attribute, :autoload, :values_from, :limit

      def initialize(res_model, attribute = nil, values_from = nil, autoload = false, is_has_one = false, limit = nil)
        @resource_model = res_model
        @attribute = attribute
        @autoload = autoload
        @values_from = values_from
        @has_one = is_has_one
        @limit = limit

        Thread.current[:bulk_loader] ||= ApiClientBulkLoader::Client::Loader.new
        @bulk_loader = Thread.current[:bulk_loader]
      end

      #Fetch.
      def fetch(values)
        results = @bulk_loader.fetch(@resource_model, values, @attribute)
        return @has_one ? results.first : results
      end

      #Push.
      def push(values)
        @bulk_loader.push(@resource_model, values, @attribute)
      end
    end
  end
end