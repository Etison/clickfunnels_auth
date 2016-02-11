Rails.application.routes.draw do
  # omniauth
  get '/auth/:provider/callback', :to => 'techlahoma_auth/user_sessions#create'
  get '/auth/failure', :to => 'techlahoma_auth/user_sessions#failure'

  # Custom logout
  post '/logout', :to => 'techlahoma_auth/user_sessions#destroy'
end
