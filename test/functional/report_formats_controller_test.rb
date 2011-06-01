require 'test_helper'

class ReportFormatsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => ReportFormat.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    ReportFormat.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    ReportFormat.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to report_format_url(assigns(:report_format))
  end

  def test_edit
    get :edit, :id => ReportFormat.first
    assert_template 'edit'
  end

  def test_update_invalid
    ReportFormat.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ReportFormat.first
    assert_template 'edit'
  end

  def test_update_valid
    ReportFormat.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ReportFormat.first
    assert_redirected_to report_format_url(assigns(:report_format))
  end

  def test_destroy
    report_format = ReportFormat.first
    delete :destroy, :id => report_format
    assert_redirected_to report_formats_url
    assert !ReportFormat.exists?(report_format.id)
  end
end
