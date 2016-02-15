class StuffController < ClickfunnelsAuth::ApplicationController

  before_filter :login_required, :only => :private

  def public
  end

  def private
  end
end
