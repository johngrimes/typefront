ActionController::Routing::Routes.draw do |map|
  map.resources :users,
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
  map.upgrade '/upgrade',
    :controller => 'users',
    :action => 'select_plan'

  map.resources :payment_notifications
  map.signup_notify '/signup/notify',
    :controller => 'payment_notifications',
    :action => 'create'
  map.signup_success '/signup/success',
    :controller => 'users',
    :action => 'signup_success'
  map.signup_cancel '/signup/cancel',
    :controller => 'users',
    :action => 'signup_cancel'

  map.resources :user_sessions
  map.login '/login',
    :controller => 'user_sessions',
    :action => 'new'
  map.logout '/logout',
    :controller => 'user_sessions',
    :action => 'destroy'

  map.resources :fonts,
    :has_many => :domains,
    :member => {
      :include => :get
    },
    :collection => {
      :styles => :get
    }

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
