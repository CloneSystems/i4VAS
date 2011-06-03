class ScanConfigsController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @scan_configs = ScanConfig.all(current_user, :show_details=>true)
  end

  def show
    @scan_config = ScanConfig.find(params[:id], current_user)
  end

  def new
    @scan_config = ScanConfig.new
    @scan_config.persisted = false
  end

  def create
    @scan_config = ScanConfig.new(params[:scan_config])
    @scan_config.persisted = false
    if @scan_config.save(current_user)
      redirect_to scan_configs_url, :notice => "Successfully created report format."
    else
      render :action => 'new'
    end
  end

  def edit
    @scan_config = ScanConfig.find(params[:id], current_user)
    @scan_config.persisted = true
  end

  def update
    @scan_config = ScanConfig.find(params[:id], current_user)
    @scan_config.persisted = true
    if @scan_config.update_attributes(params[:scan_config], current_user)
      redirect_to @scan_config, :notice  => "Successfully updated report format."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @scan_config = ScanConfig.find(params[:id], current_user)
    @scan_config.delete_record(current_user)
    redirect_to scan_configs_url, :notice => "Successfully destroyed report format."
  end

end