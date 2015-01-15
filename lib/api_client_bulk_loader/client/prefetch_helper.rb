module ApiClientBulkLoader
  module Client
    module PrefetchHelper
      extend ActiveSupport::Concern

      included do 
        #Getter for registered association load queues
        def self.bulk_queued_associations
          @bulk_queued_associations
        end

        def self.api_prefetch_adapter
          @api_prefetch_adapter ||= ApiClientBulkLoader::Client::PrefetchAdapter.new(self, :id)
        end

        def self.prefetch(values)
          api_prefetch_adapter.push(values)
        end

        def self.retrieve(conditions)
          api_prefetch_adapter.fetch(Array(conditions))
        end

      end

    end
  end
end