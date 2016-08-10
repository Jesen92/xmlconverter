Rails.application.routes.draw do

  get 'export_xmls/index'

  get 'export_xmls/show'

  get 'export_xmls/new'

  get 'export_xmls/create'

  get 'export_xmls/edit'

  get 'export_xmls/update'

  get 'export_xmls/destroy'

  get 'export_xmls/import' => "export_xmls#import", :as => 'import'

  get 'export_xmls/import_create' => "export_xmls#import_create", :as => 'import_create'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root :to => 'export_xmls#index'

  devise_for :users, controllers: {sessions: 'users/sessions', registrations: 'users/registrations', confirmations: 'users/confirmations'}

  devise_scope :user do
    get "login", to: "devise/sessions#new"
    authenticated :user do
      root :to => 'export_xmls#index', as: :authenticated_root
    end
    unauthenticated :user do
      root :to => 'users/sessions#new', as: :unauthenticated_root
    end

  resources :export_xmls do
    put :export_myxml, on: :collection
    get :import, on: :collection
    put :import_create, on: :collection
  end



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
