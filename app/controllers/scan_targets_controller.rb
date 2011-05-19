class ScanTargetsController < ApplicationController
  # GET /scan_targets
  # GET /scan_targets.xml
  def index
    @scan_targets = ScanTarget.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scan_targets }
    end
  end

  # GET /scan_targets/1
  # GET /scan_targets/1.xml
  def show
    @scan_target = ScanTarget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scan_target }
    end
  end

  # GET /scan_targets/new
  # GET /scan_targets/new.xml
  def new
    @scan_target = ScanTarget.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scan_target }
    end
  end

  # GET /scan_targets/1/edit
  def edit
    @scan_target = ScanTarget.find(params[:id])
  end

  # POST /scan_targets
  # POST /scan_targets.xml
  def create
    @scan_target = ScanTarget.new(params[:scan_target])

    respond_to do |format|
      if @scan_target.save
        format.html { redirect_to(@scan_target, :notice => 'Scan target was successfully created.') }
        format.xml  { render :xml => @scan_target, :status => :created, :location => @scan_target }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scan_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scan_targets/1
  # PUT /scan_targets/1.xml
  def update
    @scan_target = ScanTarget.find(params[:id])

    respond_to do |format|
      if @scan_target.update_attributes(params[:scan_target])
        format.html { redirect_to(@scan_target, :notice => 'Scan target was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scan_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scan_targets/1
  # DELETE /scan_targets/1.xml
  def destroy
    @scan_target = ScanTarget.find(params[:id])
    @scan_target.destroy

    respond_to do |format|
      format.html { redirect_to(scan_targets_url) }
      format.xml  { head :ok }
    end
  end
end
