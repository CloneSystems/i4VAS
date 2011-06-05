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
      resp = NvtFeed.sync_feed(oap)
      oap.logout
      if NvtFeed.extract_value_from("//@status", resp) =~ /20\d/
        redirect_to feeds_url, :notice => "Successfully submitted request to synchronize with NVT feed."
      else
        redirect_to feeds_url, :notice => "Error: " + NvtFeed.extract_value_from("//@status_text", resp)
      end
    end
  end

end