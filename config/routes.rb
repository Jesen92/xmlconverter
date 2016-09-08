Rails.application.routes.draw do

  get 'generate_pdf/show'

  get 'kupacs/new'

  get 'kupacs/create'

  get 'kupacs/edit'

  get 'kupacs/update'

  get 'kupacs/index'

  get 'kupacs/show'

  get 'kupacs/destroy'

  get 'export_xmls/index'

  get 'export_xmls/show'

  get 'export_xmls/new'

  get 'export_xmls/create'

  get 'export_xmls/edit'

  get 'export_xmls/update'

  get 'export_xmls/destroy'

  get 'export_xmls/import' => "export_xmls#import", :as => 'import'

  match 'export_xmls/import_create' => "export_xmls#import_create", :as => 'import_create', via: :post

  get 'export_xmls/download_pdf' => "export_xmls#download_pdf", :as => 'download_pdf'

  get 'export_xmls/download_xlsx' => "export_xmls#download_xlsx", :as => 'download_xlsx'

  get 'export_xmls/download_xlsx_primjer' => "export_xmls#download_xlsx_primjer", :as => 'download_xlsx_primjer'

  get 'export_xmls/loading_screen' => "export_xmls#import_kupac" , :as => 'import_kupac'

  get 'export_xmls/loading_screen' => "export_xmls#import_racun" , :as => 'import_racun'

  get 'exmport_xmls/set_notification_seen' => "export_xmls#set_notification_seen", :as => 'set_notification_seen'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root :to => 'export_xmls#index'

  devise_for :users, controllers: {sessions: 'users/sessions', registrations: 'users/registrations', confirmations: 'users/confirmations'}

  devise_scope :user do
    get "login", to: "devise/sessions#new"
    authenticated :user do
      root :to => 'export_xmls#index', as: :authenticated_root
      match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
    end
    unauthenticated :user do
      root :to => 'users/sessions#new', as: :unauthenticated_root
    end

  resources :export_xmls do
    put :export_myxml, on: :collection
    get :import, on: :collection
    post :import_create, on: :collection
    get :download_pdf, on: :collection
    get :download_xlsx, on: :collection
    get :download_xlsx_primjer, on: :collection
    put :import_kupac, on: :collection
    put :import_racun, on: :collection
    put :set_notification_seen, on: :collection
  end
    resources :kupacs
    resources :generate_pdf

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
    end
end
