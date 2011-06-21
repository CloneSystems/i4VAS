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
    @override.persisted = false
    @override.report_id           = params[:report_id]
    @override.task_id             = params[:task_id]
    @override.task_name           = params[:task_name]
    @override.result_id           = params[:result_id]
    @override.result_description  = params[:result_description]
    @override.nvt_oid             = params[:nvt_oid]
    @override.hosts               = params[:hosts]
    @override.port                = params[:result_port]
    @override.threat              = params[:threat]
  end

  def create
    @override = Override.new(params[:override])
    @override.persisted = false
    if @override.save(current_user)
      redirect_to overrides_url, :notice => "Successfully created override."
    else
      render :action => 'new'
    end
  end

  def edit
    @override = Override.find(params[:id], current_user)
    @override.persisted = true
    @override.task_name           = params[:task_name]
    @override.result_description  = params[:result_description]
    @override.hosts               = params[:hosts]
    @override.port                = params[:result_port]
    @override.threat              = params[:threat]
  end

  def update
    @override = Override.find(params[:id], current_user)
    @override.persisted = true
    if @override.update_attributes(current_user, params[:override])
      redirect_to overrides_url, :notice  => "Successfully updated override."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @override = Override.find(params[:id], current_user)
    @override.delete_record(current_user)
    redirect_to overrides_url, :notice => "Successfully deleted override."
  end

end