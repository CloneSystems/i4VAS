class ReportsController < ApplicationController

  before_filter :redirect_to_tasks, :except => [:show]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  # GET /reports/1
  def show
    @report = Report.find(params[:id], current_user)
    @formats =Report.formats(current_user)
    html_fmt_id = "b993b6f5-f9fb-4e6e-9c94-dd46c00e058d"
    # @html = Report.find_by_id_and_format(params[:id], html_fmt_id, current_user)
    @html = "*** report here ***"
  end

  protected

  def redirect_to_tasks
    redirect_to(tasks_url)
  end

end