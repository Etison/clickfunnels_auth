module FakeAuth
  class UsersController < ApplicationController
    def index
      session[:user_id] = nil
      @users = User.all.limit(20)
    end

    def become
      @user = User.find params[:user_id]

      @user.access_tokens.destroy_all

      @user.access_tokens.create!({
        token: 'a-fake-auth-token',
        refresh_token: 'a-fake-auth-refresh-token',
        expires_at: Time.now + 1.year
      })

      session[:user_id] = @user.id

      redirect_to root_path
    end

    def unbecome
      redirect_to '/fake_auth'
    end
  end
end
