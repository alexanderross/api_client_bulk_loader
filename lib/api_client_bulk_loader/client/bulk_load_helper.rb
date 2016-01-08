module ApiClientBulkLoader
  module Client
    #Included in the client base models
    module BulkLoadHelper
      extend ActiveSupport::Concern

      included do 

        include AssociationHelper
        include PolymorphicAssociationHelper

        #Getter for registered association load queues
        def self.bulk_queued_associations
          @bulk_queued_associations
        end

        def initialize(*args)
          super(*args)
          #Skip em unless we got em
          return self unless self.class.bulk_queued_associations
          self.class.bulk_queued_associations.each do |assoc, adapter|
            if adapter.class == ApiClientBulkLoader::Client::PolymorphicAssociationAdapter
              self.queue_poly_association(assoc) if adapter.autoload
            else
              self.queue_association(assoc) if adapter.autoload
            end
          end

          return self
        end
      end

      #we need to override this, as if it is called before we actually hit a bulk-loaded assocation, it will attempt to JSON serialize a proc, which isn't good.
      #To remedy this, we forcefully call each attribute and if it's a proc, we fire that bulk fetch.
      def as_json(options=nil)
        prepare_attributes_hash
        super(options)
      end

      protected

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(.*)=$/
          set_attribute($1, args.first)
        elsif has_attribute?(method)
          read_attribute(method)
        else
          super
        end
      end

      def read_attribute(name)
        value = attributes.fetch(name, nil)
        if(value.is_a? Proc)
          attributes[name] = attributes[name].call
          value = attributes[name]
        end

        return value
      end

      def prepare_attributes_hash
        return unless self.class.bulk_queued_associations.present?
        self.class.bulk_queued_associations.keys.each do |assoc|
          if(attributes[assoc].is_a? Proc)
            attributes[assoc] = attributes[assoc].call
          end
        end
      end
    end
  end
end