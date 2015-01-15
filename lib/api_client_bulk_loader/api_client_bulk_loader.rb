
module ApiClientBulkLoader
  module Client
    autoload :AssociationHelper, 'api_client_bulk_loader/client/association_helper'
    autoload :AssociationAdapter, 'api_client_bulk_loader/client/association_adapter'
    autoload :PrefetchHelper , 'api_client_bulk_loader/client/prefetch_helper'
    autoload :PrefetchAdapter , 'api_client_bulk_loader/client/prefetch_adapter'
    autoload :Loader, 'api_client_bulk_loader/client/loader'
  end

  module BaseModel
    autoload :ApiTransition, 'api_client_bulk_loader/base_model/api_transition'
  end
end

JsonApiClient::Resource.send(:include, ApiClientBulkLoader::Client::AssociationHelper)
JsonApiClient::Resource.send(:include, ApiClientBulkLoader::Client::PrefetchHelper)