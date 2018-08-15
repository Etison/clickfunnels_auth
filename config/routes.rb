Rails.application.routes.draw do

  # This needs to come before the other logout link so that our fake_auth one
  # will take precedence if that setting is activated.
  if ENV['ENABLE_FAKE_AUTH'] == 'true'
    get 'fake_auth' => 'fake_auth/users#index'
    post 'fake_auth/:user_id/become' => 'fake_auth/users#become', :as => :fake_auth_become_user
    post '/logout', :to => 'fake_auth/users#unbecome'
  end

  # omniauth
  get '/auth/:provider/callback', :to => 'clickfunnels_auth/user_sessions#create'
  get '/auth/failure', :to => 'clickfunnels_auth/user_sessions#failure'

  # Custom logout
  post '/logout', :to => 'clickfunnels_auth/user_sessions#destroy'

end
