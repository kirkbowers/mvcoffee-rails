require 'test_helper'

require "shoulda/context"

class UserTest < ActiveSupport::TestCase
  context "User" do
    setup do
      @user = users(:one)
      # The fixtures put item :one_one in user one's cart
      @item = items(:one_one)
    end
    
    should "set items_updated_at when created" do
      before = DateTime.now
      user = User.create(name: "Someone New")
      after = DateTime.now
      assert_not_nil user.items_updated_at
      assert before <= user.items_updated_at
      assert after >= user.items_updated_at
    end
  
    should "update items_updated_at when a new shopping cart item is created" do
      old_updated_at = @user.items_updated_at
      before = DateTime.now
      item = items(:one_two)
      item = @user.items << item
      after = DateTime.now
      assert_not_nil @user.items_updated_at
      assert before <= @user.items_updated_at
      assert after >= @user.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @user.items_updated_at
    end      
  
    should "update items_updated_at when an old item is updated" do
      old_updated_at = @user.items_updated_at
      before = DateTime.now
      @item.price = 3.99
      @item.save!
      after = DateTime.now
      @user.reload
      assert_not_nil @user.items_updated_at
      assert before <= @user.items_updated_at
      assert after >= @user.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @user.items_updated_at
    end      
  
    should "update items_updated_at when an old item is destroyed" do
      old_updated_at = @user.items_updated_at
      before = DateTime.now
      @item.destroy
      after = DateTime.now
      @user.reload
      assert_not_nil @user.items_updated_at
      assert before <= @user.items_updated_at
      assert after >= @user.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @user.items_updated_at
    end      
  
    should "update items_updated_at when an item is removed from the cart" do
      old_updated_at = @user.items_updated_at
      before = DateTime.now
      cart_item = @user.shopping_cart_items.find_by(item_id: @item.id)
      cart_item.destroy
      after = DateTime.now
      @user.reload
      assert_not_nil @user.items_updated_at
      assert before <= @user.items_updated_at
      assert after >= @user.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @user.items_updated_at
    end      
  end

end
