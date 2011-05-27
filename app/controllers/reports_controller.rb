class ReportsController < ApplicationController

  before_filter :redirect_to_tasks, :except => [:show]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  # GET /reports/1
  def show
    # @report = OpenvasCli::VasReport.get_by_id(params[:id])
    @report = Report.find(params[:id], current_user)
  end

  protected

  def redirect_to_tasks
    redirect_to(tasks_url)
  end

end