class EscalatorsController < ApplicationController

  before_filter :redirect_to_root, :only => [:edit, :update]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @escalators = Escalator.all(current_user)
  end

  def show
    @escalator = Escalator.find(params[:id], current_user)
  end

  def new
    @escalator = Escalator.new
    @escalator.persisted = false
  end

  def create
    @escalator = Escalator.new(params[:escalator])
    @escalator.persisted = false
    if @escalator.save(current_user)
      redirect_to escalators_url, :notice => "Successfully created escalator."
    else
      render :action => 'new'
    end
  end

  def edit
    @escalator = Escalator.find(params[:id], current_user)
    @escalator.persisted = true
  end

  def update
    @escalator = Escalator.find(params[:id], current_user)
    @escalator.persisted = true
    if @escalator.update_attributes(current_user, params[:escalator])
      redirect_to escalators_url, :notice  => "Successfully updated escalator."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @escalator = Escalator.find(params[:id], current_user)
    @escalator.delete_record(current_user)
    redirect_to escalators_url, :notice => "Successfully destroyed escalator."
  end

end