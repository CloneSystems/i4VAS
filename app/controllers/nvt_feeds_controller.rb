class NvtFeedsController < ApplicationController

  before_filter :openvas_connect_and_login
  
  after_filter :openvas_logout

  def index
    redirect_to(root_url) and return unless current_user.openvas_admin?
    oap = openvas_oap_connect_and_login
    if oap.blank?
      # user is not an admin
      redirect_to(root_url)
    else
      @nvt_feeds = NvtFeed.describe_feed(oap)
      oap.logout
    end
  end

  def sync_feed
    redirect_to(root_url) and return unless current_user.openvas_admin?
    oap = openvas_oap_connect_and_login
    if oap.blank?
      # user is not an admin
      redirect_to(root_url)
    else
      NvtFeed.sync_feed(oap)
      oap.logout
      redirect_to(feeds_url)
    end
  end

end