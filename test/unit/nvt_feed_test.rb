require 'test_helper'

class NvtFeedTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert NvtFeed.new.valid?
  end
end
