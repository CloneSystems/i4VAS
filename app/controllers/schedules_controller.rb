class SchedulesController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @schedules = Schedule.all(current_user)
  end

  def show
    @schedule = Schedule.find(params[:id])
  end

  def new
    @schedule = Schedule.new
  end

  def create
    dt = Time.new(params[:schedule].delete("first_time(1i)").to_i, 
                  params[:schedule].delete("first_time(2i)").to_i,
                  params[:schedule].delete("first_time(3i)").to_i,
                  params[:schedule].delete("first_time(4i)").to_i,
                  params[:schedule].delete("first_time(5i)").to_i)
    params[:schedule][:first_time] = dt
    @schedule = Schedule.new(params[:schedule])
    if @schedule.save
      redirect_to @schedule, :notice => "Successfully created schedule."
    else
      render :action => 'new'
    end
  end

  def edit
    @schedule = Schedule.find(params[:id])
  end

  def update
    @schedule = Schedule.find(params[:id])
    if @schedule.update_attributes(params[:schedule])
      redirect_to @schedule, :notice  => "Successfully updated schedule."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    redirect_to schedules_url, :notice => "Successfully destroyed schedule."
  end

end