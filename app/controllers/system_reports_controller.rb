class SystemReportsController < ApplicationController

  before_filter :redirect_to_root, :except => [:index, :show]

  before_filter :openvas_connect_and_login
  
  after_filter :openvas_logout

  def index
    @system_reports = SystemReport.all(current_user, :brief=>true)
  end

  def show
    @system_report = SystemReport.find(params[:id], current_user)
  end

  def new; end
  def create; end
  def edit; end
  def update; end
  def destroy; end

end
# 7.42.3 Example: Get listing of available system reports
# Client
#  <get_system_reports brief="1"/>
# Manager
#  <get_system_reports_response status="200"
#                               status_text="OK">
#    <system_report>
#      <name>proc</name>
#      <title>Processes</title>
#    </system_report>
#    <system_report>
#      <name>load</name>
#      <title>System Load</title>
#    </system_report>
#    <system_report>
#      <name>cpu_0</name>
#      <title>CPU Usage: CPU 0</title>
#    </system_report>
#    ...
#  </get_system_reports_response>
# 
# 7.42.3 Example: Get a system report
# Client
#  <get_system_reports name="proc"/>
# Manager
#  <get_system_reports_response status="200"
#                               status_text="OK">
#    <system_report>
#      <name>proc</name>
#      <title>Processes</title>
#      <report format="png"
#              duration="86400">
#        iVBORw0KGgoAAAANSUhEUgAAArkAAAE...2bEdAAAAAElFTkSuQmCC
#      </report>
#    </system_report>
#  </get_system_reports_response>
