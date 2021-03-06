class TasksController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  # GET /tbd/1
  def tbd
    redirect_to root_url, :notice => "*** under development ***"
  end

  # GET /tasks
  def index
    @tasks = Task.all(current_user)
    # conn = current_user.openvas_connection # for OMP version
    # # conn = openvas_connect_and_login(true) # for OAP version
    # @version = Task.version(conn)
  end

  # GET /start_task/1
  def start_task
    @task = Task.find(params[:id], current_user)
    @task.start(current_user)
    redirect_to(tasks_url)
  end

  # GET /pause_task/1
  def pause_task
    @task = Task.find(params[:id], current_user)
    @task.pause(current_user)
    redirect_to(tasks_url)
  end

  # GET /resume_paused_task/1
  def resume_paused_task
    @task = Task.find(params[:id], current_user)
    @task.resume_paused(current_user)
    redirect_to(tasks_url)
  end

  # GET /stop_task/1
  def stop_task
    @task = Task.find(params[:id], current_user)
    @task.stop(current_user)
    redirect_to(tasks_url)
  end

  # GET /resume_stopped_task/1
  def resume_stopped_task
    @task = Task.find(params[:id], current_user)
    @task.resume_stopped(current_user)
    redirect_to(tasks_url)
  end

  # GET /tasks/1
  def show
    @task = Task.find(params[:id], current_user)
  end

  # GET /tasks/new
  def new
    @task = Task.new
    @task.persisted = false
  end

  # POST /tasks
  def create
    @task = Task.new(params[:task])
    @task.persisted = false
    if @task.save(current_user)
      redirect_to(@task, :notice => 'Task was successfully created.')
    else
      render :action => "new"
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id], current_user)
    @task.persisted = true
  end

  # PUT /tasks/1
  def update
    @task = Task.find(params[:id], current_user)
    @task.persisted = true
    if @task.update_attributes(current_user, params[:task])
      # redirect_to(@task, :notice => 'Task was successfully updated.')
      redirect_to(tasks_url, :notice => 'Task was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /tasks/1
  def destroy
    @task = Task.find(params[:id], current_user)
    @task.delete_record(current_user)
    redirect_to(tasks_url)
  end

end