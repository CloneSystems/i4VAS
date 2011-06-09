class SlavesController < ApplicationController

  before_filter :redirect_to_root, :only => [:edit, :update]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @slaves = Slave.all(current_user)
  end

  def show
    @slave = Slave.find(params[:id], current_user)
  end

  def new
    @slave = Slave.new
    @slave.persisted = false
  end

  def create
    @slave = Slave.new(params[:slave])
    @slave.persisted = false
    if @slave.save(current_user)
      redirect_to slaves_url, :notice => "Successfully created slave."
    else
      render :action => 'new'
    end
  end

  def edit
    # @slave = Slave.find(params[:id], current_user)
    # @slave.persisted = true
  end

  def update
    # @slave = Slave.find(params[:id], current_user)
    # @slave.persisted = true
    # if @slave.update_attributes(current_user, params[:slave])
    #   redirect_to slaves_url, :notice  => "Successfully updated slave."
    # else
    #   render :action => 'edit'
    # end
  end

  def destroy
    @slave = Slave.find(params[:id], current_user)
    @slave.delete_record(current_user)
    redirect_to slaves_url, :notice => "Successfully destroyed slave."
  end

end