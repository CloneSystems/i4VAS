class CredentialsController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @credentials = Credential.all(current_user)
  end

  def show
    redirect_to credentials_url
    # @credential = Credential.find(params[:id], current_user)
  end

  def new
    @credential = Credential.new
    @credential.persisted = false
  end

  def create
    @credential = Credential.new(params[:credential])
    @credential.persisted = false
    if @credential.save(current_user)
      redirect_to credentials_url, :notice => "Successfully created credential."
    else
      render :action => 'new'
    end
  end

  def edit
    @credential = Credential.find(params[:id], current_user)
    @credential.persisted = true
  end

  def update
    @credential = Credential.find(params[:id], current_user)
    @credential.persisted = true
    if @credential.update_attributes(current_user, params[:credential])
      redirect_to credentials_url, :notice  => "Successfully updated credential."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @credential = Credential.find(params[:id], current_user)
    @credential.delete_record(current_user)
    redirect_to credentials_url, :notice => "Successfully deleted credential."
  end

end