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
    connection = OpenVas::Connection.new("host"=>'192.168.1.2',"port"=>'9390',"user"=>current_user.username,"password"=>password)
    current_user.connection = connection
  end

end