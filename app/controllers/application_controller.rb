require 'connection'

class ApplicationController < ActionController::Base

  include OpenVas

  protect_from_forgery

  before_filter :authenticate_user!

  private

  def cache_openvas_session
    if session['warden.user.user.key']
      logger.info "\n\n ApplicationController#cache_openvas_session ... session=#{session.inspect}\n\n"
    end
  end

  def get_openvas_connection
    redirect_to(destroy_user_session_url) if current_user.blank?
    password = Rails.cache.read(current_user.username)
    redirect_to(destroy_user_session_url) if password.blank?
    oc = OpenVas::Connection.new("host"=>APP_CONFIG[:openvas_omp_host],"port"=>APP_CONFIG[:openvas_omp_port],"user"=>current_user.username,"password"=>password)
    current_user.openvas_connection = oc
  end

end