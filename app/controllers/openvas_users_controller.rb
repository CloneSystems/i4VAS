class OpenvasUsersController < ApplicationController

  before_filter :oap_connect_and_login

  after_filter :openvas_logout

  def index
    @openvas_users = OpenvasUser.all(current_user)
  end

  def show
    @openvas_user = OpenvasUser.find(params[:name], current_user)
  end

  def new
    @openvas_user = OpenvasUser.new
    @openvas_user.persisted = false
  end

  def create
    @openvas_user = OpenvasUser.new(params[:openvas_user])
    @openvas_user.persisted = false
    if @openvas_user.save(current_user)
      redirect_to openvas_users_url, :notice => "Successfully created user."
    else
      render :action => 'new'
    end
  end

  def edit
    @openvas_user = OpenvasUser.find(params[:id], current_user)
    @openvas_user.password = ''
    @openvas_user.persisted = true
  end

  def update
    @openvas_user = OpenvasUser.find(params[:id], current_user)
    @openvas_user.persisted = true
    if @openvas_user.update_attributes(current_user, params[:openvas_user])
      redirect_to openvas_users_url, :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @openvas_user = OpenvasUser.find(params[:id], current_user)
    @openvas_user.delete_record(current_user)
    redirect_to openvas_users_url, :notice => "Successfully destroyed user."
  end

end