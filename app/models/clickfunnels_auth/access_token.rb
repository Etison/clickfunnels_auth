module ClickfunnelsAuth
  class AccessToken < ActiveRecord::Base
    self.table_name = "clickfunnels_auth_access_tokens"

    belongs_to :user

    def refresh!
      new_token = oauth_token.refresh!
      self.save_token_data(new_token)
    end

    def save_token_data(token)
      self.update_attributes({
        token: token.token,
        refresh_token: token.refresh_token,
        expires_at: Time.at(token.expires_at)
      })
    end

    def validate_token!
      user_data = oauth_token.get(ENV['AUTH_PROVIDER_ME_URL']).parsed
      user_id = user_data['id']
      puts "we got a user_id = #{user_id}"
    rescue OAuth2::Error => e
      puts "caught an error #{e}"
      puts e.as_json
      self.destroy
    end

    def expired?
      oauth_token.expired?
    end

    protected

    def oauth_token
      OAuth2::AccessToken.from_hash(oauth_client, {
        :token_type=>"bearer",
        :access_token=>self.token,
        :refresh_token=>self.refresh_token,
        :expires_at=>self.expires_at
      })
    end

    def oauth_client
      # TODO : Is there some way we can retrieve this already configured, instead of creating a new one?
      @oauth_client ||= OAuth2::Client.new(ENV['AUTH_PROVIDER_APPLICATION_ID'], ENV['AUTH_PROVIDER_SECRET'], {site: ENV['AUTH_PROVIDER_URL']})
    end
  end
end
