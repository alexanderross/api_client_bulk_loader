module ApiClientBulkLoader
  module Client
    #Included in the client base models
    module AssociationHelper
      extend ActiveSupport::Concern

      included do 
        #manually push values into the queue.
        def self.bulk_queue_values_for_association(values, association)
          raise Exception.new("Cannot find bulk-enabled association #{association} in class.") unless @bulk_queued_associations[association]
          @bulk_queued_associations[association].push(values)
        end

        #Register an association as one to be batch loaded
        #Required:
        # association - the association that is being bulk loaded.
        # api_client_model - the model to fetch the association with (what you call .find on)
        #Optional
        # attribute - The attribute of the associated model to search by. Defults to id. This could be used to query by an FK - If you have a User class and a user has many Cars, then under User you could do
        #     bulk_load :cars, Client::Cars, attribute: user_id
        #     This would cause user.cars to trigger a query of cars.json?user_id=<the users id> instead of the default cars.json?ids=[user.car_ids]
        #     Use this when the length of .<>_ids exceeds the uri length limit.
        # from - The attribute of the client model to use to fetch values. eg. :assoc_ids 
        # autoload - if the ids for the association will be queued on the item's initialization. Else, you call obj.queue_association(:assoc_to_load) manually.
        # is_has_one - Overrides the default of returning an array for the association, instead it returns the first item.

        def self.bulk_load(association, api_client_model, attribute: :id, autoload: false, from: :id, is_has_one: false, limit: nil)
          @bulk_queued_associations ||= {}
          @bulk_queued_associations[association] = ApiClientBulkLoader::Client::AssociationAdapter.new(api_client_model, attribute, from, autoload, is_has_one, limit)
        end

        #Shorthand to the above, but automatically sets 'is_has_one' to true.
        def self.bulk_load_has_one(*args, **kwargs)
          self.bulk_load(*args,**kwargs.merge({is_has_one: true}))
        end

        def queue_association(association, limit = nil)
          adapter = self.class.bulk_queued_associations[association]
          #Probably just raise an exception if it doesnt respond to the target.
          values = Array(self.send(adapter.values_from))
          limit ||= adapter.limit

          values = values.first(limit) if limit.present?


          if !values.nil?
            adapter.push(values)
            attributes[association] = ->{
              adapter.fetch(values)
            }
          end
        end

      end

    end
  end
end