module ClickfunnelsAuth
  module Helper

    extend ActiveSupport::Concern

    included do
      protect_from_forgery
      helper_method :signed_in?
      helper_method :current_user
    end

    def cookie_valid?
      cookies[:clickfunnels_auth].present? && session[:user_id].present? && cookies[:clickfunnels_auth].to_s == session[:user_id].to_s
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

    def auth_redirect
      origin = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      # Currently Doorkeeper has a bug when the redirct contains query params
      #observable_redirect_to "/auth/clickfunnels?origin=#{CGI.escape(origin)}"
      observable_redirect_to "/auth/clickfunnels"
    end

    def current_user
      return nil unless session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
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
