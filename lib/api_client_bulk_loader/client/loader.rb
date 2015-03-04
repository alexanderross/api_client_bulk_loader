module ApiClientBulkLoader
  module Client
    #Storage class for our bulk loading. Is one per thread. 
    class Loader
      def initialize()
        #Hash with keys being a client model, pointing to hashes with id's as keys and loaded objects as values.
        @model_store = {}

        #Contains each bulk stored model, then containing the attribute to be queried by which then holds an array of values that have yet to be fetched
        @queued_model_store = {}

        #Contains a structure similar to queued model store, but stores which values have already been queried.
        @checked_model_store = {}
      end

      #Push the values into the appropriate queue store, only if they haven't been run.
      def push(model, values, attribute = :id)
        # Idempotent.
        create_model_attribute_store(model, attribute)

        # THIS IS DEBATABLE - NOW WE ASSUME THAT WE ALWAYS QUERY BY A NUMBER! 
        values = values.map{|v| v.to_i }

        # Eliminate those that have already been checked
        values -= @checked_model_store[model][attribute] if(@checked_model_store[model][attribute])

        # or in those values to the queue store.
        @queued_model_store[model][attribute] |= values
      end

      #Fetch the values, given the adapter that pertains to those values. 
      def fetch(model, values, attribute = :id)
        #If any of these values are in the queue, we have to retrieve it.
        retrieve_model_by_attribute!(model, attribute) unless (values & @queued_model_store[model][attribute]).empty?

        #Return all values for keys matching our value(s)
        return  @model_store[model].values_at(*values).compact || []
      end

      private

      #For a model's attribute, fetch all records matching the values in the queue.
      def retrieve_model_by_attribute!(model, attribute)
        return [] unless @queued_model_store[model][attribute]
        #Get our values from the queue and make the call to the client model

        values = @queued_model_store[model][attribute]

        results = if attribute != :id #Index the returned results by the attribute used to query by

          Array(model.find(attribute => values)).group_by{|obj| obj.send(attribute) }

        else #Index the results by their ids.

          Hash[ Array(model.find(values)).map{|obj| [obj.id, obj]} ]

        end

        #Merge the results in with what we may already have.
        @model_store[model] = @model_store[model].merge(results)

        #Register these values as being checked
        @checked_model_store[model][attribute] |= values
        #Clear the queue
        @queued_model_store[model][attribute] = []
      end

      def create_model_attribute_store(model, attribute)
        #base hash for the model
        @queued_model_store[model] ||= {}
        @checked_model_store[model] ||= {}

        #For criteria to be loaded by an attribute
        @queued_model_store[model][attribute] ||= []
        #For checking if criteria has already been run.
        @checked_model_store[model][attribute] ||= []
        #For storing by id.
        @model_store[model] ||= {}
      end
    end
  end
end