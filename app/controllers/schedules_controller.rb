class SchedulesController < ApplicationController

  before_filter :redirect_to_root, :only => [:edit, :update]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @schedules = Schedule.all(current_user)
  end

  def show
    @schedule = Schedule.find(params[:id], current_user)
  end

  def new
    @schedule = Schedule.new
    @schedule.persisted = false
  end

  def create
    dt = Time.new(params[:schedule].delete("first_time(1i)").to_i, 
                  params[:schedule].delete("first_time(2i)").to_i,
                  params[:schedule].delete("first_time(3i)").to_i,
                  params[:schedule].delete("first_time(4i)").to_i,
                  params[:schedule].delete("first_time(5i)").to_i)
    params[:schedule][:first_time] = dt
    @schedule = Schedule.new(params[:schedule])
    @schedule.persisted = false
    if @schedule.save(current_user)
      # redirect_to @schedule, :notice => "Successfully created schedule."
      redirect_to(schedules_url, :notice => "Successfully created schedule.")
    else
      render :action => 'new'
    end
  end

  def edit
    @schedule = Schedule.find(params[:id], current_user)
  end

  def update
    @schedule = Schedule.find(params[:id], current_user)
    @schedule.persisted = true
    if @schedule.update_attributes(current_user, params[:schedule])
      redirect_to @schedule, :notice  => "Successfully updated schedule."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @schedule = Schedule.find(params[:id], current_user)
    @schedule.delete_record(current_user)
    redirect_to schedules_url, :notice => "Successfully deleted schedule."
  end

end