class ReportFormatsController < ApplicationController

  before_filter :openvas_connect_and_login

  after_filter :openvas_logout

  def index
    @report_formats = ReportFormat.all(current_user)
  end

  def show
    @report_format = ReportFormat.find(params[:id], current_user)
  end

  def new
    @report_format = ReportFormat.new
    @report_format.persisted = false
  end

  def create
    @report_format = ReportFormat.new(params[:report_format])
    @report_format.persisted = false
    if @report_format.save(current_user)
      redirect_to report_formats_url, :notice => "Successfully created report format."
    else
      render :action => 'new'
    end
  end

  def edit
    @report_format = ReportFormat.find(params[:id])
    @report_format.persisted = true
  end

  def update
    @report_format = ReportFormat.find(params[:id], current_user)
    @report_format.persisted = true
    if @report_format.update_attributes(params[:report_format], current_user)
      redirect_to @report_format, :notice  => "Successfully updated report format."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @report_format = ReportFormat.find(params[:id], current_user)
    @report_format.delete_record(current_user)
    redirect_to report_formats_url, :notice => "Successfully destroyed report format."
  end

end