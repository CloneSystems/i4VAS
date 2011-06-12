class OverridesController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @overrides = Override.all(current_user)
  end

  def show
    @override = Override.find(params[:id], current_user)
  end

  def new
    @override = Override.new
  end

  def create
    @override = Override.new(params[:override])
    if @override.save
      redirect_to @override, :notice => "Successfully created override."
    else
      render :action => 'new'
    end
  end

  def edit
    redirect_to overrides_url, :notice => "*** edit is under development ***"
    # @override = Override.find(params[:id], current_user)
  end

  def update
    @override = Override.find(params[:id], current_user)
    if @override.update_attributes(params[:override])
      redirect_to @override, :notice  => "Successfully updated override."
    else
      render :action => 'edit'
    end
  end

  def destroy
    redirect_to overrides_url, :notice => "*** delete is under development ***"
    # @override = Override.find(params[:id], current_user)
    # @override.destroy
    # redirect_to overrides_url, :notice => "Successfully destroyed override."
  end

end