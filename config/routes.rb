ActionController::Routing::Routes.draw do |map|
  map.resources :users,
    :only => [ :create, :destroy ],
    :member => { :change_plan => :post }
  map.signup_with_plan '/signup/with_plan/:subscription_level',
    :controller => 'users',
    :action => 'new'
  map.activation '/activate/:code',
    :controller => 'users',
    :action => 'activate'
  map.account '/account',
    :controller => 'users',
    :action => 'show'

  map.resources :subscriptions 
  map.upgrade '/upgrade',
    :controller => 'subscriptions',
    :action => 'index'
  map.subscription_outcome '/subscription/:subscription_action',
    :controller => 'subscriptions',
    :action => 'outcome'
  map.update '/subscription/update',
    :controller => 'subscriptions',
    :action => 'update'

  map.signup_notify '/payments/notify',
    :controller => 'payment_notifications',
    :action => 'create',
    :method => :post

  map.resources :user_sessions,
    :only => :create
  map.login '/login',
    :controller => 'user_sessions',
    :action => 'new'
  map.logout '/logout',
    :controller => 'user_sessions',
    :action => 'destroy'

  map.resources :fonts,
    :has_many => :domains,
    :member => { :include => :get },
    :collection => { :styles => :get }

  map.resources :domains

  map.resources :documentation

  map.pricing '/pricing',
    :controller => 'strangers',
    :action => 'pricing'
  map.terms '/terms',
    :controller => 'strangers',
    :action => 'terms'
  map.home '/',
    :controller => 'strangers',
    :action => 'home'
end
