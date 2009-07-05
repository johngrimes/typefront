ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.user_home '/home',
    :controller => 'users',
    :action => 'home'
  map.signup '/signup',
    :controller => 'users',
    :action => 'new'

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

  map.home '/',
    :controller => 'strangers',
    :action => 'home'
end
