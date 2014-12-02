Rails.application.routes.draw do

  # /...
  post 'register', to: 'users#register'
  post 'login', to: 'users#login'
  
  # /users/...
  resources :users do
    member do
      post 'location/visibility', to: 'users#updateuservisibility'
      get 'location', to: 'users#location'
      post 'location', to: 'users#updatelocation'
      namespace :caravans do
        get '/', to: '/users#caravans'
        get 'requests/', to: '/users#caravanRequests'
      end
    end
    resources :friends do
      collection do
        get 'requests', to: 'users#requests'
        post 'add/:other_user_id', to: 'users#add'
        post 'delete/:other_user_id', to: 'users#delete'
        post 'accept/:other_user_id', to: 'users#accept'
        post 'deny/:other_user_id', to: 'users#deny'
        post 'searchForFriend', to: 'users#searchForFriend'
        get '/', to: 'users#friends'
      end
    end
  end
  
  # /caravans/...
  resources :caravans do
    collection do
      post 'create/:user_id', to: 'caravans#create'
    end
    member do
      post 'invite/:user_id', to: 'caravans#invite'
      post 'accept/:user_id', to: 'caravans#accept'
      post 'deny/:user_id', to: 'caravans#deny'
      post 'leave/:user_id', to: 'caravans#leave'
      post 'destination/:destination', to: 'caravans#set_destination'
    end
  end

  root 'users#login'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
