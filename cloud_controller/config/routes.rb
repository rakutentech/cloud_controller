# The priority is based upon order of creation:
# first created -> highest priority.
# Routes with asterisks should go at the end of the file if they are ambiguous.
CloudController::Application.routes.draw do
  get    'info'                      => 'default#info',         :as => :cloud_info
  get    'info/services'             => 'default#service_info', :as => :cloud_service_info
  get    'info/runtimes'             => 'default#runtime_info', :as => :cloud_runtime_info
  get    'users'                     => 'users#list',           :as => :list_users
  post   'users'                     => 'users#create',         :as => :create_user
  get    'users/*email'              => 'users#info',           :as => :user_info
  delete 'users/*email'              => 'users#delete',         :as => :delete_user
  put    'users/*email'              => 'users#update',         :as => :update_user
  post   'users/*email/tokens'       => 'user_tokens#create',   :as => :create_token
  post   'apps'                      => 'apps#create',          :as => :app_create
  get    'apps'                      => 'apps#list',            :as => :list_apps
  get    'apps/:name'                => 'apps#get',             :as => :app_get
  put    'apps/:name'                => 'apps#update',          :as => :app_update
  delete 'apps/:name'                => 'apps#delete',          :as => :app_delete

  put    'apps/:name/application'    => 'apps#upload',          :as => :app_upload
  get    'apps/:name/crashes'        => 'apps#crashes',         :as => :app_crashes
  post   'resources'                 => 'resource_pool#match',  :as => :resource_match
  get    'apps/:name/application'    => 'apps#download',        :as => :app_download
  get    'staged_droplets/:id/:hash' => 'apps#download_staged', :as => :app_download_staged
  get    'apps/:name/instances'      => 'apps#instances',       :as => :app_instances
  get    'apps/:name/stats'          => 'apps#stats',           :as => :app_stats
  get    'apps/:name/update'         => 'apps#check_update'
  put    'apps/:name/update'         => 'apps#start_update'

  #bulk APIs for health manager v.2 and billing
  #retrieving batches of items. An opaque token is returned with every request to resume the retrieval
  #from where the last request left off.
  get    'bulk/apps'                 => 'bulk#apps',            :as => :bulk_apps
  get    'bulk/users'                => 'bulk#users',           :as => :bulk_users
  get    'bulk/counts'               => 'bulk#counts',          :as => :bulk_counts

  # Stagers interact with the CC via these urls
  post   'staging/droplet/:id/:upload_id' => 'staging#upload_droplet', :as => :upload_droplet
  get    'staging/app/:id'                => 'staging#download_app',   :as => :download_unstaged_app

  get    'services/v1/offerings'                     => 'services#list',           :as => :service_list
  post   'services/v1/offerings'                     => 'services#create',         :as => :service_create
  delete 'services/v1/offerings/:label(/:provider)'              => 'services#delete',         :as => :service_delete,         :label => /[^\/]+/, :provider => /[^\/]+/
  get    'services/v1/offerings/:label(/:provider)/handles'      => 'services#list_handles',   :as => :service_list_handles,   :label => /[^\/]+/, :provider => /[^\/]+/
  get    'services/v1/offerings/:label(/:provider)'              => 'services#get',            :as => :service_get,            :label => /[^\/]+/, :provider => /[^\/]+/
  post   'services/v1/offerings/:label(/:provider)/handles/:id'  => 'services#update_handle',  :as => :service_update_handle,  :label => /[^\/]+/, :provider => /[^\/]+/
  post   'services/v1/configurations'                => 'services#provision',      :as => :service_provision
  delete 'services/v1/configurations/:id'            => 'services#unprovision',    :as => :service_unprovision,    :id    => /[^\/]+/
  post   'services/v1/bindings'                      => 'services#bind',           :as => :service_bind
  post   'services/v1/bindings/external'             => 'services#bind_external',  :as => :service_bind_external
  delete 'services/v1/bindings/:binding_token'       => 'services#unbind',         :as => :service_unbind,         :binding_token => /[^\/]+/
  post   'services/v1/binding_tokens'                => 'binding_tokens#create',   :as => :binding_token_create
  get    'services/v1/binding_tokens/:binding_token' => 'binding_tokens#get',      :as => :binding_token_get,      :binding_token => /[^\/]+/
  delete 'services/v1/binding_tokens/:binding_token' => 'binding_tokens#delete',   :as => :binding_token_delete,   :binding_token => /[^\/]+/
  # Brokered Services
  get    'brokered_services/v1/offerings' => 'services#list_brokered_services',   :as => :service_list_brokered_services

  # Service lifecycle apis
  post   'services/v1/configurations/:id/snapshots'          => 'services#create_snapshot',      :as => :service_create_snapshot,       :id   => /[^\/]+/
  get    'services/v1/configurations/:id/snapshots'          => 'services#enum_snapshots',       :as => :service_enum_snapshots,        :id   => /[^\/]+/
  get    'services/v1/configurations/:id/snapshots/:sid'     => 'services#snapshot_details',     :as => :service_snapshot_details,      :id   => /[^\/]+/, :sid => /[^\/]+/
  put    'services/v1/configurations/:id/snapshots/:sid'     => 'services#rollback_snapshot',    :as => :service_rollback_snapshot,     :id   => /[^\/]+/, :sid => /[^\/]+/
  delete 'services/v1/configurations/:id/snapshots/:sid'     => 'services#delete_snapshot',      :as => :service_delete_snapshot,     :id   => /[^\/]+/, :sid => /[^\/]+/
  post   'services/v1/configurations/:id/serialized/url/snapshots/:sid'     => 'services#create_serialized_url',       :as => :service_create_serialized_url,    :id   => /[^\/]+/, :sid => /[^\/]+/
  get    'services/v1/configurations/:id/serialized/url/snapshots/:sid'     => 'services#serialized_url',       :as => :service_serialized_url,    :id   => /[^\/]+/, :sid => /[^\/]+/
  put    'services/v1/configurations/:id/serialized/url'     => 'services#import_from_url',      :as => :service_import_from_url,       :id   => /[^\/]+/
  put    'services/v1/configurations/:id/serialized/data'    => 'services#import_from_data',     :as => :service_import_from_data,      :id   => /[^\/]+/
  get    'services/v1/configurations/:id/jobs/:job_id'       => 'services#job_info',             :as => :service_job_info,              :id   => /[^\/]+/, :job_id => /[^\/]+/


  # Legacy services implementation (for old vmc)
  get     'services'        => 'legacy_services#list',        :as => :legacy_service_list
  post    'services'        => 'legacy_services#provision',   :as => :legacy_service_provision
  delete  'services/:alias' => 'legacy_services#unprovision', :as => :legacy_service_unprovision, :alias => /[^\/]+/
  get     'services/:alias' => 'legacy_services#get',         :as => :legacy_service_get,         :alias => /[^\/]+/
  # Not yet re-implemented
  post    'services/:label/tokens' => 'default#not_implemented'
  delete  'services/:label/tokens' => 'default#not_implemented'

  # download app files from a DEA instance
  get 'apps/:name/instances/:instance_id/files'       => 'apps#files'
  get 'apps/:name/instances/:instance_id/files/*path' => 'apps#files'

  # Index route should be last.
  root :to => "default#index"

  match '*a', :to => 'default#route_not_found'

end
