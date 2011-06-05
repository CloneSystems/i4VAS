class SystemReportsController < ApplicationController
  def index
    @system_reports = SystemReport.all
  end
end
