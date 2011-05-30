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
    fmt = 'html' if params[:fmt].blank?
    fmt = params[:fmt] unless params[:fmt].blank?
    @report = Report.find(params[:id], current_user)
    formats = Report.formats(current_user)
    format_id = format = ''
    formats.each do |f|
      if f.name.downcase == fmt
        format_id = f.id
        format = f.name
        break
      end
    end
    report = Report.find_by_id_and_format(params[:id], format_id, current_user)
    if fmt.downcase == 'pdf'
      send_data report, :type => 'application/pdf', :file_name => "report_#{params[:id]}.pdf", :disposition => 'inline'
    elsif fmt.downcase == 'html'
      # chop off everything before the body tag (keep the body tag as it has styling):
      b = report.index('<body ', 0)
      @html_body = report[b..report.length] unless b.nil?
      @html_body = report if b.nil?
      render :layout => false
    else
      render :text => report, :layout => false
    end
  end

  protected

  def redirect_to_tasks
    redirect_to(tasks_url)
  end

end