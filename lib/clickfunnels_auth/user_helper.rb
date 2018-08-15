module ClickfunnelsAuth
  module UserHelper

    extend ActiveSupport::Concern

    included do
      has_many :access_tokens, class_name: 'ClickfunnelsAuth::AccessToken'
    end

  end
end
