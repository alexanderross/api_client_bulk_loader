module ApiClientBulkLoader
  module BaseModel
    module ApiTransition
      extend ActiveSupport::Concern

      included do
        after_initialize :push_api_prefetch

        def self.bind_to_api_model(api_model, accessor = :api_obj)
          raise Exception.new("Model #{api_model.name} does not support bulk prefetching!") unless api_model.api_prefetch_adapter.present?
          @api_prefetch_accessor = accessor
          @api_prefetch_binding = api_model.api_prefetch_adapter

          define_method accessor.to_s do 
          ivar = self.instance_variable_get("@#{accessor}")
          if (ivar.is_a? Proc)
            self.instance_variable_set("@#{accessor}", ivar.call)
          else
            ivar
          end
        end

        end

        def self.api_prefetch_binding
          @api_prefetch_binding
        end

        def self.api_prefetch_accessor
          @api_prefetch_accessor 
        end

      end

      def push_api_prefetch

        return nil unless self.class.api_prefetch_binding && self.id.present?

        prefetcher = self.class.api_prefetch_binding
        self.class.api_prefetch_binding.push([self.id])

        self.instance_variable_set("@#{self.class.api_prefetch_accessor}", ->{
          prefetcher.fetch([self.id]).first
        })

      end
    end
  end
end