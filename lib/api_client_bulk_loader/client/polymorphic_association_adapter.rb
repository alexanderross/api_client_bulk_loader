module ApiClientBulkLoader
  module Client
    #Adapts into the bulk loader. Mainly useful for storing the details of the bulk call.
    class PolymorphicAssociationAdapter
      attr_reader :resource_translation, :attribute, :autoload, :type_from, :values_from, :limit

      def initialize(resource_translation, attribute = nil, type_from = nil, values_from = nil, autoload = false, is_has_one = false, limit = nil)
        @resource_translation = resource_translation
        @attribute = attribute
        @autoload = autoload
        @values_from = values_from
        @type_from = type_from
        @has_one = is_has_one
        @limit = limit

        Thread.current[:bulk_loader] ||= ApiClientBulkLoader::Client::Loader.new
        @bulk_loader = Thread.current[:bulk_loader]
      end

      #Fetch.
      def fetch(values, resource_type)
        results = @bulk_loader.fetch(@resource_translation[resource_type], values, @attribute)
        return @has_one ? results.first : results
      end

      #Push.
      def push(values, resource_type)
        @bulk_loader.push(@resource_translation[resource_type], values, @attribute)
      end
    end
  end
end