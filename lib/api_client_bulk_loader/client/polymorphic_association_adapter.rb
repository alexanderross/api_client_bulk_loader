module ApiClientBulkLoader
  module Client
    #Adapts into the bulk loader. Mainly useful for storing the details of the bulk call.
    class PolymorphicAssociationAdapter < BulkLoadAdapter
      attr_reader :resource_translation

      def initialize(resource_translation, attribute = nil, type_from = nil, values_from = nil, autoload = true, is_has_one = false, limit = nil)
        @resource_translation = resource_translation
        super(attribute, type_from, values_from, autoload, is_has_one, limit)
      end
      
      #Fetch.
      def fetch(values, resource_type)
        results = bulk_loader.fetch(@resource_translation[resource_type], values, @attribute)
        return @has_one ? results.first : results
      end

      #Push.
      def push(values, resource_type)
        bulk_loader.push(@resource_translation[resource_type], values, @attribute)
      end
    end
  end
end