require 'resque/server'
Webauto::Application.routes.draw do


  # TODO: KLUDGE: MANUALLY BRING THE TYPUS ROUTES IN
  #       Typus used to provide :
  #           Typus::Routes.draw(map)
  #       But that is no longer the case.
  scope "admin", :module => :admin, :as => "admin" do

    match "/" => "dashboard#show", :as => "dashboard"
    match "user_guide" => "base#user_guide"

    if Typus.authentication == :session
      resource :session, :only => [:new, :create, :destroy], :controller => :session
      resources :account, :only => [:new, :create, :show, :forgot_password] do
        collection do
          get :forgot_password
          post :send_password
        end
      end
    end

    Typus.models.map { |i| i.to_resource }.each do |resource|
      match "#{resource}(/:action(/:id(.:format)))", :controller => resource
    end

    Typus.resources.map { |i| i.underscore }.each do |resource|
      match "#{resource}(/:action(/:id(.:format)))", :controller => resource
    end
  end
  # END KLUDGE


  mount Resque::Server.new, at: "/resque"

  devise_for :users, skip: [:session, :password, :registration, :confirmation], :controllers => {
    omniauth_callbacks: "omniauth_callbacks"
  }
  #match '/auth/:provider/callback' => 'authentications#create'
  scope '(:locale)' do
    authenticated :user do
      root :to => 'cars#index'
    end
    root :to => "cars#index"
    devise_for :users, :controllers => {:registrations => "registrations",:sessions=> "sessions",:passwords=>"passwords"}, skip: [:omniauth_callbacks]
    resources :users,:except => [:show] do
      member do
        get :show_phone
        post :contact
      end
    end
    match "/users/dashboard" => "users#show", :as => :dashboard
    as :user do
      get '/users/settings' => 'users#edit',:as=>:settings
      get '/users/profile' => 'devise/registrations#edit', :as => :profile
      
    end
    
    #match '/cars'=>'cars#index',:as=>:cars
    #resource :dashboard, :controller => :users, :only => :show
    match '/contact'=>'contact_forms#new',:as=>:contact
    match '/terms-conditions'=>'home#terms',:as=>:terms
    match '/privacy-policy'=>'home#privacy',:as=>:privacy
    match '/about'=>'home#about',:as=>:about
    match '/sitemap'=>'home#site_map',:as=>:site_map
    match '/seller-safety'=>'home#seller_safety',:as=>:safety
    match '/create_advert(/:id)'=>'home#create_ad',:as=>:create_ad
    match '/popular-searches'=>'home#popular',:as=>:popular
    match '/searches/destroy_all' => 'searches#destroy_all', :as=>:destroy_all
    match '/searches/show_more(/:id)'=>'searches#show_more',:as=>:show_more
    match '/searches/show_more_deleted(/:id)'=>'searches#show_more_deleted',:as=>:show_more_deleted
    #match "/ads(/:page)" => "users#ads", :as => :ads
    match 'searches/new(/:search)(/:value)(/:model)'=>'searches#new',:as=>:new_search
    match 'vehicles/update_region_select/:id', :controller=>'vehicles', :action => 'update_region_select'
    match "vehicles/find_details",:controller=>'vehicles', :action => 'find_details'
    get "vehicles/show_states",:as=> 'show_states'
    get "vehicles/show_cities",:as=> 'show_cities'
    get "vehicles/show_regions_in_search",:as=> 'show_regions_in_search'
    get "vehicles/update_states",:as=> 'update_states'
    match "vehicles/get_recently_viewed_vehicles",:controller=>'vehicles',:action=>'get_recently_viewed_vehicles'
    match 'help/buying-a-car'=>'help#buying-a-car',:as=>:buying_a_car
    match 'help/selling-a-car'=>'help#selling-a-car',:as=>:selling_a_car
    match 'dealers/page(/:page)',:to=> 'dealers#index',:as => :dealers
    match 'dealers/:id(/:sort)(/:page)',:to=>'dealers#show',:as => :dealer,:via => [:post,:get]
    match 'dealers/:id/search(/:search_id)(/:sort)(/:page)',:to=>'dealers#show',:as => :search_dealer,:via => [:post,:get]
    #match 'dealers/(:id)/contact' => 'dealers#contact',:as=>:contact_dealer,:via=>[:post]
    #match 'inquiries/dealer_message_create',:to=>'inquiries#dealer_message_create',:as=>:user_inquiries
    resources :cars do
      match 'search(/:id)(/:sort)(/:page)' => 'cars#search',:via => [:post,:get], :as => :search,:on => :collection
      match 'solr_search'=>'cars#solr_search',:as=>:solr_search,:on => :collection
      member do
        get :save, :watch,:unsave,:compare,:uncompare
      end
    end
    resources :authentications,:only => [:destroy]
    resources :orders
    resources :services
    resources :line_items
    resources :carts
    resources :garage_items 
    resources :adverts do
      match 'page(/:page)' => 'adverts#index',:via => [:post,:get],:on => :collection
      member do
        get :statistics,:remove,:restore,:preview,:checkout,:really_destroy,:activate,:deactivate
      end
    end
    match 'adverts/details(/:id)'=>'adverts#details',:as=>:details_advert
    match 'adverts/features(/:id)'=>'adverts#features',:as=>:features_advert
    match 'adverts/photos(/:id)'=>'adverts#photos',:as=>:photos_advert
    match 'adverts/contact(/:id)'=>'adverts#contact',:as=>:contact_advert
    match 'adverts/new(/:ad_type)(/:g_id)'=>'adverts#new',:as=>:new_advert
    #get '/adverts', to: 'adverts#index', as: 'adverts'
    resources :bikes do
      match 'search(/:id)(/:sort)(/:page)' => 'bikes#search',:via => [:post,:get], :as => :search,:on => :collection
    end
    resources :searches do
      collection do
        get :remove_all,:popular,:expensive
      end
    end
    
    #get '/saved_searches', to: 'searches#index', as: 'searches'
    resources :vehicles do
      resources :inquiries, :only => [:create]
      resources :comments,:only=>[:new,:create,:destroy]
      match 'search(/:id)(/:sort)(/:page)' => 'vehicles#search',:via => [:post,:get], :as => :search,:on => :collection
      member do
         post :sort_photos
         get :show_interesting,:show_similar,:show_more_dealer,:show_viewed,:show_reg_nr,:show_vin
       end

    end
    resources :compared_items,:only=> [:index,:destroy]
  match "/compare" => "compared_items#index",:as=>:compare
    #match 'vehicle_steps/:id', :controller=>'vehicle_steps', :action => 'index',:as=>:vehicle_steps
    resources :pictures do
       collection do
         get :fail_upload
       end
    end
       resources :dealer_pictures do
       collection do
         get :fail_upload
       end
    end
    resources :photos, only: [:new, :create, :index, :destroy]
    resources :saved_items do
      collection do
        get 'remove_all'
      end
    end
    get '/saved_adverts', to: 'saved_items#index', as: 'saved_items'
    resources :contact_forms
    resources :search_alerts,:only=>[:index,:show]
  end
end