class ScanConfigsController < ApplicationController
  # GET /scan_configs
  # GET /scan_configs.xml
  def index
    @scan_configs = ScanConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scan_configs }
    end
  end

  # GET /scan_configs/1
  # GET /scan_configs/1.xml
  def show
    @scan_config = ScanConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scan_config }
    end
  end

  # GET /scan_configs/new
  # GET /scan_configs/new.xml
  def new
    @scan_config = ScanConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scan_config }
    end
  end

  # GET /scan_configs/1/edit
  def edit
    @scan_config = ScanConfig.find(params[:id])
  end

  # POST /scan_configs
  # POST /scan_configs.xml
  def create
    @scan_config = ScanConfig.new(params[:scan_config])

    respond_to do |format|
      if @scan_config.save
        format.html { redirect_to(@scan_config, :notice => 'Scan config was successfully created.') }
        format.xml  { render :xml => @scan_config, :status => :created, :location => @scan_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scan_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scan_configs/1
  # PUT /scan_configs/1.xml
  def update
    @scan_config = ScanConfig.find(params[:id])

    respond_to do |format|
      if @scan_config.update_attributes(params[:scan_config])
        format.html { redirect_to(@scan_config, :notice => 'Scan config was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scan_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scan_configs/1
  # DELETE /scan_configs/1.xml
  def destroy
    @scan_config = ScanConfig.find(params[:id])
    @scan_config.destroy

    respond_to do |format|
      format.html { redirect_to(scan_configs_url) }
      format.xml  { head :ok }
    end
  end
end
