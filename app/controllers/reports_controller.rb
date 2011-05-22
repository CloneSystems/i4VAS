class ReportsController < ApplicationController

  before_filter :redirect_to_tasks, :except => [:show]

  # GET /reports/1
  def show
    @report = OpenvasCli::VasReport.get_by_id(params[:id])
  end

  protected

  def redirect_to_tasks
    redirect_to(tasks_url)
  end

end