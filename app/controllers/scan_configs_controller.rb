class ScanConfigsController < ApplicationController

  before_filter :redirect_to_root, :only => [:edit, :update]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @scan_configs = ScanConfig.all(current_user)
  end

  def show
    params.merge!({:show_details=>true}) # true will return Families and Preferences
    @scan_config = ScanConfig.find(params, current_user)
  end

  def new
    @scan_config = ScanConfig.new
    @scan_config.persisted = false
  end

  def create
    @scan_config = ScanConfig.new(params[:scan_config])
    @scan_config.persisted = false
    if @scan_config.save(current_user)
      redirect_to scan_configs_url, :notice => "Successfully created Scan Config."
    else
      render :action => 'new'
    end
  end

  def edit
    # @scan_config = ScanConfig.find(params, current_user)
    # @scan_config.persisted = true
  end

  def update
    # @scan_config = ScanConfig.find(params, current_user)
    # @scan_config.persisted = true
    # if @scan_config.update_attributes(params[:scan_config], current_user)
    #   redirect_to @scan_config, :notice  => "Successfully updated Scan Config."
    # else
    #   render :action => 'edit'
    # end
  end

  def destroy
    @scan_config = ScanConfig.find(params, current_user)
    @scan_config.delete_record(current_user)
    redirect_to scan_configs_url, :notice => "Successfully deleted Scan Config."
  end

end