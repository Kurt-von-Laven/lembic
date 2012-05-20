Lembic::Application.routes.draw do
    
  root to: 'user#login', as: 'login'
	
	match '/workflow', to: 'workflow#expertworkflow', as: 'workflow'  
  match '/logout', to: 'user#logout', as: 'logout'
  match '/register', to: 'user#register', as: 'register'
  match '/editblock', to: 'view_editor#editblock', as: 'editblock'
  match '/editquestion', to: 'view_editor#editquestion', as: 'editquestion'
  match '/home', to: 'home#home', as: 'home'
  match '/help', to: 'help#help', as: 'help'
  match '/editor/equations', to: 'editor#equations', as: 'equations'
  match '/editor/delete_variable', to: 'editor#delete_variable', as: 'delete_variable'
  match '/editor/delete_relationship', to: 'editor#delete_relationship', as: 'delete_relationship'
  match '/evaluator', to: 'workflow#evaluate', as: 'evaluator'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
  # Sample resource route with options:
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
  
  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end
  
  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end
  
  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  
  # See how all your routes lay out with "rake routes"
  
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
