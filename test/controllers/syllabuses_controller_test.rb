require "test_helper"

class SyllabusesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get syllabuses_index_url
    assert_response :success
  end

  test "should get show" do
    get syllabuses_show_url
    assert_response :success
  end

  test "should get new" do
    get syllabuses_new_url
    assert_response :success
  end

  test "should get create" do
    get syllabuses_create_url
    assert_response :success
  end

  test "should get edit" do
    get syllabuses_edit_url
    assert_response :success
  end

  test "should get update" do
    get syllabuses_update_url
    assert_response :success
  end

  test "should get destroy" do
    get syllabuses_destroy_url
    assert_response :success
  end
end
