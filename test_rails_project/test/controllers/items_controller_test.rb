require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @department = departments(:one)
    @item = items(:one_one)
  end

  test "should get index" do
    get :index, department_id: @department
    assert_response :success
    assert_not_nil assigns(:items)
  end

  test "should get new" do
    get :new, department_id: @department
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post :create, 
        department_id: @department,
        item: { 
          name: 'Something unique', 
          price: @item.price, 
          sku: @item.sku
        }
    end

    assert_redirected_to department_item_path(assigns(:department), assigns(:item))
  end

  test "should show item" do
    get :show, department_id: @department, id: @item
    assert_response :success
  end

  test "should get edit" do
    get :edit, department_id: @department, id: @item
    assert_response :success
  end

  test "should update item" do
    patch :update, 
      department_id: @department,
      id: @item, 
      item: { 
        name: @item.name, 
        price: @item.price, 
        sku: @item.sku 
      }
      
    assert_redirected_to department_item_path(assigns(:department), assigns(:item))
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, department_id: @department, id: @item
    end

    assert_redirected_to department_items_path(assigns(:department))
  end
end
