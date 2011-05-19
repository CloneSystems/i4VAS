class TasksController < ApplicationController

  # GET /tasks
  def index
    @tasks = Task.all
  end

  # GET /tasks/1
  def show
    @task = Task.find(params[:id])
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
    if @task.save
      redirect_to(@task, :notice => 'Task was successfully created.')
    else
      render :action => "new"
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
    @task.persisted = true
  end

  # PUT /tasks/1
  def update
    @task = Task.find(params[:id])
    @task.persisted = true
    if @task.update_attributes(params[:task])
      redirect_to(@task, :notice => 'Task was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /tasks/1
  def destroy
    @task = Task.find_as_vastask(params[:id])
    @task.delete_record
    redirect_to(tasks_url)
  end

end