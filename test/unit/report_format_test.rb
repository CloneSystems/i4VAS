require 'test_helper'

class ReportFormatTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ReportFormat.new.valid?
  end
end
