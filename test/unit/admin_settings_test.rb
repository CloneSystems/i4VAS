require 'test_helper'

class AdminSettingsTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert AdminSettings.new.valid?
  end
end
