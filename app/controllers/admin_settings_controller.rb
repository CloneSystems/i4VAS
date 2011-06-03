class AdminSettingsController < ApplicationController

  before_filter :openvas_connect_and_login
  
  after_filter :openvas_logout

  def index
    redirect_to(root_url) and return unless current_user.openvas_admin?
    oap = openvas_oap_connect_and_login
    if oap.blank?
      # user is not an admin
      redirect_to(root_url)
    else
      @settings = AdminSettings.scanner_settings(oap)
      oap.logout
    end
  end

end