Rails.application.routes.draw do
  # omniauth
  get '/auth/:provider/callback', :to => 'clickfunnels_auth/user_sessions#create'
  get '/auth/failure', :to => 'clickfunnels_auth/user_sessions#failure'

  # Custom logout
  post '/logout', :to => 'clickfunnels_auth/user_sessions#destroy'
end
