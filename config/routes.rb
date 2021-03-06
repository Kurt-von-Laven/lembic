Lembic::Application.routes.draw do
  
  resources :models
  
  root to: 'user#login', as: 'login'
  
  match '/logout', to: 'user#logout', as: 'logout'

  match '/register', to: 'user#register', as: 'register'
  match '/view_editor/edit_block', to: 'view_editor#edit_block', as: 'blocks'

  match '/view_editor/edit_question', to: 'view_editor#edit_question', as: 'edit_question'
  match '/view_editor/delete_block', to: 'view_editor#delete_block', as: 'delete_block'
  match '/view_editor/create_workflow', to: 'view_editor#create_workflow', as: 'create_workflow'
    
  match '/home', to: 'home#home', as: 'home'
  match '/help', to: 'help#help', as: 'help'
  match '/equation_editor/equations', to: 'editor#equations', as: 'equations'
  match '/equation_editor/variable', to: 'editor#variable', as: 'variable'
  match '/equation_editor/create_events', to: 'editor#create_events', as: 'create_events'
  match '/equation_editor/delete_variable', to: 'editor#delete_variable', as: 'delete_variable'
  match '/equation_editor/delete_relationship/:id', to: 'editor#delete_relationship', as: 'delete_relationship'
  match '/evaluator', to: 'workflow#evaluate', as: 'evaluator'
  match '/run/:id', to: 'workflow#start_run', as: 'run'
  match '/workflow', to: 'workflow#expert_workflow', as: 'workflow'
  match '/workflow/post_block_input', to: 'workflow#expert_workflow', as: 'post_block_input'
  match '/workflow/set_current', to: 'workflow#set_current', as: 'set_current_workflow'
  match '/models/create', to:'models#create', as: 'create'
  match '/models/show', to:'models#show', as: 'show'
  match '/models/set_current', to: 'models#set_current', as: 'set_current_model'
  match '/full_variable', to: 'editor#full_variable', as: 'full_variable'
  
  resources :editor do
    collection do
      get :find_variable_names
    end
  end
  
  resources :view_editor do
    collection do
      get :find_block_names
    end
  end
  
  resources :view_editor

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
