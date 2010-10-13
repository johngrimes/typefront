ActionController::Routing::Routes.draw do |map|
  map.resources :users,
    :only => [:create, :update, :destroy]
  map.signup_with_plan '/signup/with_plan/:subscription_level',
    :controller => 'users',
    :action => 'new'
  map.activation '/activate/:code',
    :controller => 'users',
    :action => 'activate'
  map.account '/account',
    :controller => 'users',
    :action => 'show'
  map.account_update '/account/update',
    :controller => 'users',
    :action => 'edit'

  map.resources :subscriptions,
    :only => [:edit, :update]
  map.upgrade '/upgrade',
    :controller => 'subscriptions',
    :action => 'edit'
  map.update_subscription '/subscriptions',
    :controller => 'subscriptions',
    :action => 'update',
    :conditions => { :method => :put }

  map.resources :user_sessions,
    :only => :create
  map.login '/login',
    :controller => 'user_sessions',
    :action => 'new'
  map.logout '/logout',
    :controller => 'user_sessions',
    :action => 'destroy'

  map.resources :passwords,
    :only => [:new, :create]
  map.edit_password '/account/change_password',
    :controller => 'passwords',
    :action => 'edit'
  map.edit_password_with_token '/reset_password/:token',
    :controller => 'passwords',
    :action => 'edit'
  map.update_password '/passwords',
    :controller => 'passwords',
    :action => 'update',
    :conditions => { :method => :put }

  map.resources :fonts, 
      :member => { :demo => :get, :processing => :get }, 
      :collection => { :styles => :get } do |fonts|
    fonts.resources :domains, :only => [:create, :destroy]
    fonts.resources :font_formats, :as => :formats, :only => [:update]
  end
  map.font_tab '/fonts/:id/:tab_name',
    :controller => 'fonts',
    :action => 'show'
  map.font_tab_js '/fonts/:id/:tab_name.js',
    :controller => 'fonts',
    :action => 'show',
    :format => 'js'

  map.resources :stats, :only => :index

  map.pricing '/pricing',
    :controller => 'strangers',
    :action => 'pricing'
  map.terms '/terms',
    :controller => 'strangers',
    :action => 'terms'

  map.root :controller => 'strangers', :action => 'home'
  map.page '/:id',
    :controller => 'pages',
    :action => 'show'
end
