module ApiClientBulkLoader
  module Client
    #Adapts into the bulk loader. Mainly useful for storing the details of the bulk call.
    class AssociationAdapter < BulkLoadAdapter
      attr_reader :resource_model

      def initialize(res_model, attribute = nil, values_from = nil, autoload = false, is_has_one = false, limit = nil)
        @resource_model = res_model
        super(attribute, type_from, values_from, autoload, is_has_one, limit)
      end

      #Fetch.
      def fetch(values)
        results = bulk_loader.fetch(@resource_model, values, @attribute)
        return @has_one ? results.first : results
      end

      #Push.
      def push(values)
        bulk_loader.push(@resource_model, values, @attribute)
      end
    end
  end
end