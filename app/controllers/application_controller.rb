require 'openvas_connection'

class ApplicationController < ActionController::Base

  include OpenVas

  protect_from_forgery

  before_filter :authenticate_user!

  private

  def openvas_connect_and_login
    redirect_to(destroy_user_session_url) if current_user.blank?
    password = Rails.cache.read(current_user.username)
    redirect_to(destroy_user_session_url) if password.blank?
    oc = OpenVas::Connection.new("host"=>APP_CONFIG[:openvas_omp_host],"port"=>APP_CONFIG[:openvas_omp_port],"user"=>current_user.username,"password"=>password)
    current_user.openvas_connection = oc
  end

  def openvas_logout
    current_user.openvas_connection.logout
  end

end