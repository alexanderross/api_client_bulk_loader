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

        def self.define_bulk_method(association)
          #define new getter for assoc that uses the proc
          define_method association.to_s do 
            ivar = self.instance_variable_get("@#{association}")
            if (ivar.is_a? Proc)
              self.instance_variable_set("@#{association}", ivar.call)
            else
              ivar
            end
          end
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
    end
  end
end