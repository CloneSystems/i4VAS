class ReportsController < ApplicationController

  before_filter :redirect_to_root, :except => [:show, :view_report]

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index; end
  def new; end
  def create; end
  def edit; end
  def update; end
  def destroy; end

  # GET /reports/1
  def show
    @report = Report.find(params[:id], current_user)
    format_id = ReportFormat.find_id_for_name(current_user, 'xml')
    report = Report.find_by_id_and_format(params[:id], 'xml', format_id, current_user)
    @report_body = report
    # format_id = ReportFormat.find_id_for_name(current_user, 'html')
    # report = Report.find_by_id_and_format(params[:id], 'html', format_id, current_user)
    # report.gsub!("This file was automatically generated.", '')
    # b = report.index('Port Summary for Host', 0)
    # e = report.index('</body>', 0)
    # @report_body = report[b-4..e-1] unless b.nil? || e.nil?
    # @report_body = report if b.nil?
  end

  # GET /view_report/1
  def view_report
    fmt = 'html' if params[:fmt].blank?
    fmt = params[:fmt] unless params[:fmt].blank?
    @report = Report.find(params[:id], current_user)
    format_id = ReportFormat.find_id_for_name(current_user, fmt)
    report = Report.find_by_id_and_format(params[:id], fmt.downcase, format_id, current_user)
    if fmt.downcase == 'html'
      # chop off everything before the body tag (keep the body tag as it has styling):
      b = report.index('<body ', 0)
      @html_body = report[b..report.length] unless b.nil?
      @html_body = report if b.nil?
      render :layout => false
    else
      ext = fmt.downcase
      send_data report, :type => "application/#{ext}", :filename => "report_#{params[:id]}.#{ext}", :disposition => 'attachment'
      # render :text => report, :layout => false
    end
  end

end