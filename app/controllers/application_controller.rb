require 'openvas_connection'

class ApplicationController < ActionController::Base

  include Openvas

  protect_from_forgery

  before_filter :authenticate_user!

  private

  def redirect_to_root
    redirect_to(root_url)
  end

  def openvas_connect_and_login(oap = false)
    redirect_to(destroy_user_session_url) if current_user.blank?
    password = Rails.cache.read(current_user.username)
    redirect_to(destroy_user_session_url) if password.blank?
    if oap
      host = APP_CONFIG[:openvas_oap_host]
      port = APP_CONFIG[:openvas_oap_port]
    else
      host = APP_CONFIG[:openvas_omp_host]
      port = APP_CONFIG[:openvas_omp_port]
    end
    oc = Openvas::Connection.new("host"=>host, "port"=>port, "user"=>current_user.username, "password"=>password)
    oc.login
    current_user.openvas_connection = oc.logged_in? ? oc : nil
    # note: checking to see if the current_user is an admin on every request just seems wrong, but 
    #       openvas doesn't offer another choice, so we check and set:
    # if Rails.env.production?
      current_user.openvas_admin = false
    # else
    #   set_openvas_admin_for_user
    # end
    # FIXME perhaps we could store this in the Users table when they sign in, but there are 
    #       other openvas app's which may change the users role (such as Greenbone or openvas Client),
    #       which would not take effect until the user signs out and in again
  end

  def openvas_logout
    current_user.openvas_connection.logout
  end

  def openvas_oap_connect_and_login
    redirect_to(destroy_user_session_url) if current_user.blank?
    password = Rails.cache.read(current_user.username)
    redirect_to(destroy_user_session_url) if password.blank?
    host = APP_CONFIG[:openvas_oap_host]
    port = APP_CONFIG[:openvas_oap_port]
    oap = Openvas::Connection.new("host"=>host, "port"=>port, "user"=>current_user.username, "password"=>password)
    oap.login
    oap = oap.logged_in? ? oap : nil
    oap
  end

  def set_openvas_admin_for_user
    oap = openvas_oap_connect_and_login
    if oap.nil?
      current_user.openvas_admin = false
    else
      current_user.openvas_admin = oap.logged_in? ? true : false
      oap.logout if oap.logged_in?
    end
  end

  def oap_connect_and_login
    openvas_connect_and_login(true)
  end

end