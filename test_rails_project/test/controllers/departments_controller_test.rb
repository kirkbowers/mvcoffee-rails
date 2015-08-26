require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  setup do
    @department = departments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:departments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create department" do
    assert_difference('Department.count') do
      post :create, department: { name: @department.name }
    end

    # assert_redirected_to department_path(assigns(:department))
    # TODO:
    # This should assert instead that an MVCoffee redirect was issued
    # I haven't figured out how to test this with this syntax.  It is tested
    # interactively by running the application and visually verifying that the redirect
    # is in fact followed on the client.
  end

  test "should show department" do
    get :show, id: @department
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @department
    assert_response :success
  end

  test "should update department" do
    patch :update, id: @department, department: { name: @department.name }
    
    # assert_redirected_to department_path(assigns(:department))
    # TODO:
    # This should assert instead that an MVCoffee redirect was issued
    # I haven't figured out how to test this with this syntax.  It is tested
    # interactively by running the application and visually verifying that the redirect
    # is in fact followed on the client.
  end

  test "should destroy department" do
    assert_difference('Department.count', -1) do
      delete :destroy, id: @department
    end

    # assert_redirected_to departments_path
    # TODO:
    # This should assert instead that an MVCoffee redirect was issued
    # I haven't figured out how to test this with this syntax.  It is tested
    # interactively by running the application and visually verifying that the redirect
    # is in fact followed on the client.
  end
end
