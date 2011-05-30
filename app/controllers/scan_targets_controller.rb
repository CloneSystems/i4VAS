class ScanTargetsController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  # GET /scan_targets
  def index
    @scan_targets = ScanTarget.all(current_user)
  end

  # GET /scan_targets/1
  def show
    @scan_target = ScanTarget.find(params[:id])
  end

  # GET /scan_targets/new
  def new
    @scan_target = ScanTarget.new
  end

  # POST /scan_targets
  def create
    @scan_target = ScanTarget.new(params[:scan_target])
    if @scan_target.save
      redirect_to(@scan_target, :notice => 'Scan target was successfully created.')
    else
      render :action => "new"
    end
  end

  # GET /scan_targets/1/edit
  def edit
    @scan_target = ScanTarget.find(params[:id], current_user)
    @scan_target.persisted = true
  end

  # PUT /scan_targets/1
  def update
    @scan_target = ScanTarget.find(params[:id])
    if @scan_target.update_attributes(params[:scan_target])
      redirect_to(@scan_target, :notice => 'Scan target was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /scan_targets/1
  def destroy
    @scan_target = ScanTarget.find(params[:id])
    @scan_target.destroy
    redirect_to(scan_targets_url)
  end

end