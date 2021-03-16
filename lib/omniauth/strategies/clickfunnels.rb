require 'omniauth-oauth2'
module OmniAuth
  module Strategies
    class Clickfunnels < OmniAuth::Strategies::OAuth2

      CUSTOM_PROVIDER_URL = ENV['AUTH_PROVIDER_URL'] || "http://custom-provider-goes-here"
      CUSTOM_PROVIDER_ME_URL = ENV['AUTH_PROVIDER_ME_URL'] || "/api/attributes/me.json"

      option :client_options, {
        :site =>  CUSTOM_PROVIDER_URL,
        :authorize_url => "#{CUSTOM_PROVIDER_URL}/oauth/authorize",
        :access_token_url => "#{CUSTOM_PROVIDER_URL}/oauth/token"
      }

      uid {
        raw_info['id']
      }

      info do
        {
          :email => raw_info['email'],
          :admin => raw_info['admin'],
          :member_level => raw_info['funnelflix_member_level'],
          :internal_affiliate_id => raw_info['internal_affiliate_id'],
          :accounts => raw_info['accounts']
        }
      end

      extra do
        {
          #:current_sign_in_at => raw_info['extra']['current_sign_in_at'],
          #:name => raw_info['extra']['name']
          #:first_name => raw_info['extra']['first_name'],
          #:last_name  => raw_info['extra']['last_name']
        }
      end

      def raw_info
        @raw_info ||= access_token.get(CUSTOM_PROVIDER_ME_URL).parsed
      end

      # Omniauth-oauth2 > 1.3 breaks the callback url with extra parameter options
      # https://github.com/omniauth/omniauth-oauth2/issues/81
      # and  also https://github.com/omniauth/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f#commitcomment-13935631
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

