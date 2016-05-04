$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_client_bulk_loader/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_client_bulk_loader"
  s.version     = ApiClientBulkLoader::VERSION
  s.authors     = ["alex"]
  s.email       = ["alex@avvo.com"]
  s.homepage    = "http://github.com/alexanderross/api_client_bulk_loader"
  s.summary     = "Bulk association fetching ability for API and Hybrid API models"
  s.description = "todo."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", "> 4.0"
  s.add_dependency "request_store", "1.1.0"
  s.add_dependency "json_api_client"
end
