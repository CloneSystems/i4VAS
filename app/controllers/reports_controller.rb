class ReportsController < ApplicationController

  before_filter :redirect_to_tasks, :except => [:show, :view_report]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  # GET /reports/1
  def show
    @report = Report.find(params[:id], current_user)
    @formats = Report.formats(current_user)
  end

  # GET /view_report/1
  def view_report
    @report = Report.find(params[:id], current_user)
    formats = Report.formats(current_user)
    html_fmt_id = ''
    formats.each do |f|
      if f.name.downcase == 'html'
        html_fmt_id = f.id
        break
      end
    end
    @html = Report.find_by_id_and_format(params[:id], html_fmt_id, current_user)
    render :layout => false
  end

  protected

  def redirect_to_tasks
    redirect_to(tasks_url)
  end

end