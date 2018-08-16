module ClickfunnelsAuth
  module ControllerHelper

    extend ActiveSupport::Concern

    included do
      protect_from_forgery
      before_action :check_cookie
      helper_method :signed_in?
      helper_method :current_user
    end

    def check_cookie
      if !cookie_valid?
        session[:user_id] = nil
      end
    end

    def cookie_valid?
      cookies[:clickfunnels_login_user].present? && session[:user_id].present? && cookies[:clickfunnels_login_user].to_s == session[:user_id].to_s
    end

    def login_required
      if !current_user
        not_authorized
      end
    end

    def not_authorized
      respond_to do |format|
        format.html{ auth_redirect }
        format.json{ head :unauthorized }
      end
    end

    def is_token_older_than_current_login?(token)
      if !cookies[:clickfunnels_login_timestamp].present?
        return true
      end
      return token.updated_at < Time.at(cookies[:clickfunnels_login_timestamp].to_i)
    end

    def auth_redirect
      origin = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      # Currently Doorkeeper has a bug when the redirct contains query params, so for now
      # we'll put the origin in the session instead of the redirect url.
      #observable_redirect_to "/auth/clickfunnels?origin=#{CGI.escape(origin)}"
      session['origin'] = origin
      if ENV['ENABLE_FAKE_AUTH'] == 'true'
        observable_redirect_to "/fake_auth"
      else
        observable_redirect_to "/auth/clickfunnels"
      end
    end

    def current_user
      return nil unless session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
      token = @current_user.access_tokens.first
      puts "token = #{token}"
      puts "token.expired? = #{token.try :expired?}"
      if token.blank?
        puts "*******************************************************"
        puts "we had a user, but they did not have a token!"
        puts "*******************************************************"
        session[:user_id] = nil
        return nil
      elsif token.expired? || is_token_older_than_current_login?(token)
        begin
          puts "*******************************************************"
          puts "aobut to refresh the token!"
          puts "token.expired? : #{token.expired?}"
          puts "is_token_older_than_current_login?(token) : #{is_token_older_than_current_login?(token)}"
          puts "*******************************************************"
          token.refresh!
        rescue OAuth2::Error => e
          puts "caught error #{e}"
          token.destroy!
          session[:user_id] = nil
          return nil
        end
      end
      return @current_user
    end

    def signed_in?
      current_user.present?
    end

    private

    # These two methods help with testing
    def integration_test?
      Rails.env.test? && defined?(Cucumber::Rails)
    end

    def observable_redirect_to(url)
      if integration_test?
        render :text => "If this wasn't an integration test, you'd be redirected to: #{url}"
      else
        redirect_to url
      end
    end

  end
end
