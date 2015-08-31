require 'test_helper'

require "shoulda/context"

class DepartmentTest < ActiveSupport::TestCase
  context "Department" do
    setup do
      @department = departments(:one)
      @item = items(:one_one)
    end
    
    should "set items_updated_at when created" do
      before = DateTime.now
      department = Department.create(name: "Something New")
      after = DateTime.now
      assert_not_nil department.items_updated_at
      assert before <= department.items_updated_at
      assert after >= department.items_updated_at
    end
  
    should "update items_updated_at when a new item is created" do
      old_updated_at = @department.items_updated_at
      before = DateTime.now
      item = @department.items.create(name: "An Item", sku: 1234, price: 1.99)
      after = DateTime.now
      assert_not_nil @department.items_updated_at
      assert before <= @department.items_updated_at
      assert after >= @department.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @department.items_updated_at
    end      
  
    should "update items_updated_at when an old item is updated" do
      old_updated_at = @department.items_updated_at
      before = DateTime.now
      @item.price = 3.99
      @item.save!
      after = DateTime.now
      @department.reload
      assert_not_nil @department.items_updated_at
      assert before <= @department.items_updated_at
      assert after >= @department.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @department.items_updated_at
    end      
  
    should "update items_updated_at when an old item is destroyed" do
      old_updated_at = @department.items_updated_at
      before = DateTime.now
      @item.destroy
      after = DateTime.now
      @department.reload
      assert_not_nil @department.items_updated_at
      assert before <= @department.items_updated_at
      assert after >= @department.items_updated_at
      assert old_updated_at.nil? or old_updated_at < @department.items_updated_at
    end      
  end

end
