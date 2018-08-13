module ClickfunnelsAuth
  class ApplicationController < ActionController::Base

    include ClickfunnelsAuth::Helper

    #before_filter :check_cookie
    #def check_cookie
      #if !cookie_valid?
        #session[:user_id] = nil
      #end
    #end


  end
end

