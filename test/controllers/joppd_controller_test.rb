require 'test_helper'

class JoppdControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get import" do
    get :import
    assert_response :success
  end

  test "should get import_create" do
    get :import_create
    assert_response :success
  end

  test "should get set_notification_seen" do
    get :set_notification_seen
    assert_response :success
  end

  test "should get export_myxml" do
    get :export_myxml
    assert_response :success
  end

  test "should get download_xlsx" do
    get :download_xlsx
    assert_response :success
  end

  test "should get download_xlsx_primjer" do
    get :download_xlsx_primjer
    assert_response :success
  end

end
