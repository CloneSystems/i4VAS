class OpenvasCliVasTasksController < ApplicationController

  # GET /tasks
  def index
    @tasks = OpenvasCli::VasTask.get_all
  end

  # GET /tasks/1
  def show
    @task = OpenvasCli::VasTask.get_by_id(params[:id])
    @reports = OpenvasCli::VasReport.get_by_id(@task.last_report_id)
    # @config = OpenvasCli::VasConfig.get_all(:id => @task.config_id)
    @config = OpenvasCli::VasConfig.get_by_id(@task.config_id)
    # @target = OpenvasCli::VasTarget.get_all(:id => @task.target_id)
    @target = OpenvasCli::VasTarget.get_by_id(@task.target_id)
  end

  # GET /tasks/new
  def new
    # @task = OpenvasCli::VasTask.new({:id => nil})
    @openvas_cli_vas_task = OpenvasCli::VasTask.new
  end

  # POST /tasks
  def create
    @openvas_cli_vas_task = OpenvasCli::VasTask.new(params[:openvas_cli_vas_task])
    if @openvas_cli_vas_task.save
      redirect_to(@openvas_cli_vas_task, :notice => 'Task was successfully created.')
    else
      render :action => "new"
    end
  end

  # GET /tasks/1/edit
  def edit
    @openvas_cli_vas_task = OpenvasCli::VasTask.get_by_id(params[:id])
  end

  # PUT /tasks/1
  def update
    @openvas_cli_vas_task = OpenvasCli::VasTask.get_by_id(params[:id])
    # @task.name = params[:openvas_cli_vas_task][:name] if params[:openvas_cli_vas_task][:name]
    # @task.comment = params[:openvas_cli_vas_task][:comment] if params[:openvas_cli_vas_task][:comment]
    @openvas_cli_vas_task.update_attributes(params[:openvas_cli_vas_task])
    if @openvas_cli_vas_task.create_or_update
      redirect_to(@openvas_cli_vas_task, :notice => 'Task was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /tasks/1
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to(tasks_url)
  end

end