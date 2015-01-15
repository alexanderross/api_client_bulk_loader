module ApiClientBulkLoader
  module Client
    class PrefetchAdapter
      attr_reader :resource_model, :attribute

      def initialize(model, attribute = :id)
        @resource_model = model
        @attribute = attribute

        Thread.current[:bulk_loader] ||= ApiClientBulkLoader::Client::Loader.new
        @bulk_loader = Thread.current[:bulk_loader]
      end

      #Fetch.
      def fetch(values)
        results = @bulk_loader.fetch(self, values, @attribute)
        return results
      end

      #Push.
      def push(values)
        @bulk_loader.push(self, values, @attribute)
      end

    end
  end
end