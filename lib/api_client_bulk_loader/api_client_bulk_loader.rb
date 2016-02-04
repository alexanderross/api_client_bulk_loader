require "request_store"

module ApiClientBulkLoader
  module Client
    autoload :AssociationHelper, 'api_client_bulk_loader/client/association_helper'
    autoload :AssociationAdapter, 'api_client_bulk_loader/client/association_adapter'
    autoload :PolymorphicAssociationHelper, 'api_client_bulk_loader/client/polymorphic_association_helper'
    autoload :PolymorphicAssociationAdapter, 'api_client_bulk_loader/client/polymorphic_association_adapter'
    autoload :BulkLoadAdapter, 'api_client_bulk_loader/client/bulk_load_adapter'
    autoload :BulkLoadHelper, 'api_client_bulk_loader/client/bulk_load_helper'
    autoload :Loader, 'api_client_bulk_loader/client/loader'
  end

end

JsonApiClient::Resource.send(:include, ApiClientBulkLoader::Client::BulkLoadHelper)