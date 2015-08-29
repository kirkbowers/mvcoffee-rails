require 'test_helper'

require "shoulda/context"
require "execjs"

class MvcoffeeJson < ActiveSupport::TestCase
  include MVCoffee

  context "When converting MVCoffee object to json" do
    setup do
      @mvcoffee = ::MVCoffee::MVCoffee.new
      @department1 = departments(:one)
      @department2 = departments(:two)
      @item11 = items(:one_one)
      @item21 = items(:two_one)
      @item31 = items(:three_one)
      @item12 = items(:one_two)
      @item22 = items(:two_two)
      @item32 = items(:three_two)
            
      Department.class_eval do
        define_method :to_hash do
          {
            id: id,
            name: name,
            item: items
          }
        end
      end
    end
  
    should "have the current version number" do
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.mvcoffee_version'
      
      assert_equal '1.0.0', result
    end
  
    should "set the redirect" do
      url = "/path_to_redirect_to"
      @mvcoffee.set_redirect url
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.redirect'
      
      assert_equal url, result
    end
    
    should "set the redirect with a flash message" do
      url = "/path_to_redirect_to"
      notice = "This is a notice!"
      @mvcoffee.set_redirect url, notice: notice
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.redirect'      
      assert_equal url, result
      
      result = js.eval 'mvcoffee.flash.notice'
      assert_equal notice, result      
    end
    
    should "set the redirect with errors" do
      url = "/path_to_redirect_to"
      errors = ["Something went wrong!"]
      @mvcoffee.set_redirect url, errors: errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.redirect'      
      assert_equal url, result
      
      result = js.eval 'mvcoffee.errors'
      assert_equal errors, result      
    end
    
    should "set the redirect with flash and errors" do
      url = "/path_to_redirect_to"
      notice = "This is a notice!"
      errors = ["Something went wrong!"]
      @mvcoffee.set_redirect url, notice: notice, errors: errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.redirect'      
      assert_equal url, result
      
      result = js.eval 'mvcoffee.flash.notice'
      assert_equal notice, result      

      result = js.eval 'mvcoffee.errors'
      assert_equal errors, result      
    end
    
    should "set the errors" do
      errors = ['Something went wrong', 'Major malfunction']
      @mvcoffee.set_errors errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.errors.length'
      assert_equal 2, result
            
      result = js.eval 'mvcoffee.errors[0]'
      assert_equal errors[0], result
      
      result = js.eval 'mvcoffee.errors[1]'
      assert_equal errors[1], result
    end
    
    should "replace the errors with set_errors" do
      errors = ['Something went wrong', 'Major malfunction']
      @mvcoffee.set_errors errors
    
      error_replacement = ['Something went horribly awry']
      @mvcoffee.set_errors error_replacement
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.errors.length'
      assert_equal 1, result
            
      result = js.eval 'mvcoffee.errors[0]'
      assert_equal error_replacement[0], result
    end

    should "set the errors with append_errors if none existed" do
      errors = ['Something went wrong', 'Major malfunction']
      @mvcoffee.append_errors errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.errors.length'
      assert_equal 2, result
            
      result = js.eval 'mvcoffee.errors[0]'
      assert_equal errors[0], result
      
      result = js.eval 'mvcoffee.errors[1]'
      assert_equal errors[1], result
    end
    
    should "append to the errors with append_errors" do
      errors = ['Something went wrong', 'Major malfunction']
      @mvcoffee.set_errors errors
    
      extra_errors = ['Something went horribly awry']
      @mvcoffee.append_errors extra_errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.errors.length'
      assert_equal 3, result
            
      result = js.eval 'mvcoffee.errors[0]'
      assert_equal errors[0], result
      
      result = js.eval 'mvcoffee.errors[1]'
      assert_equal errors[1], result

      result = js.eval 'mvcoffee.errors[2]'
      assert_equal extra_errors[0], result
    end

    should "set the errors with real ActiveRecord errors" do
      @item11.name = ''
      refute @item11.save
      errors = @item11.errors
      @mvcoffee.set_errors errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.errors.length'
      assert_equal 1, result
            
      result = js.eval 'mvcoffee.errors[0]'
      # This always strikes me as fragile!  If a future version of Rails changes the
      # error message for validates presence, this will produce a false negative.
      assert_equal "Name can't be blank", result
    end

    should "set append errors with real ActiveRecord errors" do
      @item11.name = ''
      refute @item11.save
      @mvcoffee.set_errors @item11.errors
    
      @item21.price = -1.99
      refute @item21.save
      @mvcoffee.append_errors @item21.errors
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.errors.length'
      assert_equal 2, result
            
      result = js.eval 'mvcoffee.errors[0]'
      assert_equal "Name can't be blank", result
            
      result = js.eval 'mvcoffee.errors[1]'
      assert_equal "Price must be greater than or equal to 0", result
    end
    
    should "set the flash" do
      notice = 'All is peachy'
      @mvcoffee.set_flash notice: notice
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.flash["notice"]'
      assert_equal notice, result
    end
    
    should "set the flash with more than one value" do
      notice = 'All is peachy'
      status = '5 by 5'
      @mvcoffee.set_flash notice: notice, status: status
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.flash["notice"]'
      assert_equal notice, result
      
      result = js.eval 'mvcoffee.flash["status"]'
      assert_equal status, result
    end
    
    should "merge the flash when called more than once" do
      notice = 'All is peachy'
      status = '5 by 5'
      @mvcoffee.set_flash notice: notice
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.flash["notice"]'
      assert_equal notice, result
      
      result = js.eval 'mvcoffee.flash["status"]'
      assert_equal nil, result
      
      @mvcoffee.set_flash status: status
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.flash["notice"]'
      assert_equal notice, result
      
      result = js.eval 'mvcoffee.flash["status"]'
      assert_equal status, result
    end
    
    
    should "set the session" do
      @mvcoffee.set_session department_id: 42
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.session["department_id"]'
      assert_equal 42, result
    end
    
    should "set the session with more than one value" do
      @mvcoffee.set_session department_id: 42, item_id: 256
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.session["department_id"]'
      assert_equal 42, result
      
      result = js.eval 'mvcoffee.session["item_id"]'
      assert_equal 256, result
    end
    
    should "merge the session when called more than once" do
      @mvcoffee.set_session department_id: 42
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.session["department_id"]'
      assert_equal 42, result
      
      result = js.eval 'mvcoffee.session["item_id"]'
      assert_equal nil, result
      
      @mvcoffee.set_session item_id: 256
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.session["department_id"]'
      assert_equal 42, result
      
      result = js.eval 'mvcoffee.session["item_id"]'
      assert_equal 256, result
    end
    
    #--------------------------------------------------------------------------
    #
    # set_model_data
    #
    
    should "set model data with only one model" do
      @mvcoffee.set_model_data 'item', @item11
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.data.id'
      assert_equal @item11.id, result
      
      result = js.eval 'mvcoffee.models.item.data.department_id'
      assert_equal @item11.department.id, result
      
      result = js.eval 'mvcoffee.models.item.data.name'
      assert_equal @item11.name, result
      
      result = js.eval 'mvcoffee.models.item.data.sku'
      assert_equal @item11.sku, result
      
      result = js.eval 'mvcoffee.models.item.data.price'
      assert_equal @item11.price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data.updated_at'
      assert_not_nil result
    end
      
    should "set model data with a collection of models" do
      items = @department1.items
      @mvcoffee.set_model_data 'item', items
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.data.length'
      assert_equal 3, result
      
      result = js.eval 'mvcoffee.models.item.data[0].id'
      assert_equal items[0].id, result
      
      result = js.eval 'mvcoffee.models.item.data[0].department_id'
      assert_equal items[0].department.id, result
      
      result = js.eval 'mvcoffee.models.item.data[0].name'
      assert_equal items[0].name, result
      
      result = js.eval 'mvcoffee.models.item.data[0].sku'
      assert_equal items[0].sku, result
      
      result = js.eval 'mvcoffee.models.item.data[0].price'
      assert_equal items[0].price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data[0].updated_at'
      assert_not_nil result
      
      result = js.eval 'mvcoffee.models.item.data[1].id'
      assert_equal items[1].id, result
      
      result = js.eval 'mvcoffee.models.item.data[1].department_id'
      assert_equal items[1].department.id, result
      
      result = js.eval 'mvcoffee.models.item.data[1].name'
      assert_equal items[1].name, result
      
      result = js.eval 'mvcoffee.models.item.data[1].sku'
      assert_equal items[1].sku, result
      
      result = js.eval 'mvcoffee.models.item.data[1].price'
      assert_equal items[1].price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data[1].updated_at'
      assert_not_nil result
      
      result = js.eval 'mvcoffee.models.item.data[2].id'
      assert_equal items[2].id, result
      
      result = js.eval 'mvcoffee.models.item.data[2].department_id'
      assert_equal items[2].department.id, result
      
      result = js.eval 'mvcoffee.models.item.data[2].name'
      assert_equal items[2].name, result
      
      result = js.eval 'mvcoffee.models.item.data[2].sku'
      assert_equal items[2].sku, result
      
      result = js.eval 'mvcoffee.models.item.data[2].price'
      assert_equal items[2].price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data[2].updated_at'
      assert_not_nil result
    end
      
    should "set model data with a to_hash and hierarchical data" do    
      @mvcoffee.set_model_data 'department', @department1
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
    

      result = js.eval 'mvcoffee.models.department.data.id'
      assert_equal @department1.id, result
    
      result = js.eval 'mvcoffee.models.department.data.name'
      assert_equal @department1.name, result
    
      # Here's the real clincher!  The to_hash override excludes this.
      result = js.eval 'mvcoffee.models.department.data.updated_at'
      assert_nil result

    
      # Plus, we should get hierarchical data here
      result = js.eval 'mvcoffee.models.department.data.item.length'
      assert_equal 3, result      

      items = @department1.items

      result = js.eval 'mvcoffee.models.department.data.item[0].id'
      assert_equal items[0].id, result      

      result = js.eval 'mvcoffee.models.department.data.item[0].name'
      assert_equal items[0].name, result      

      result = js.eval 'mvcoffee.models.department.data.item[1].id'
      assert_equal items[1].id, result      

      result = js.eval 'mvcoffee.models.department.data.item[1].name'
      assert_equal items[1].name, result      

      result = js.eval 'mvcoffee.models.department.data.item[2].id'
      assert_equal items[2].id, result      

      result = js.eval 'mvcoffee.models.department.data.item[2].name'
      assert_equal items[2].name, result      
    end
      
    
    should "set collection model data with a to_hash and hierarchical data" do   
      departments = Department.all 
      @mvcoffee.set_model_data 'department', Department.all
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
    

      result = js.eval 'mvcoffee.models.department.data.length'
      assert_equal 2, result
    
      result = js.eval 'mvcoffee.models.department.data[0].id'
      assert_equal departments[0].id, result
    
      result = js.eval 'mvcoffee.models.department.data[0].name'
      assert_equal departments[0].name, result
    
      # Here's the real clincher!  The to_hash override excludes this.
      result = js.eval 'mvcoffee.models.department.data[0].updated_at'
      assert_nil result

    
      # Plus, we should get hierarchical data here
      result = js.eval 'mvcoffee.models.department.data[0].item.length'
      assert_equal 3, result      

      items = departments[0].items

      result = js.eval 'mvcoffee.models.department.data[0].item[0].id'
      assert_equal items[0].id, result      

      result = js.eval 'mvcoffee.models.department.data[0].item[0].name'
      assert_equal items[0].name, result      

      result = js.eval 'mvcoffee.models.department.data[0].item[1].id'
      assert_equal items[1].id, result      

      result = js.eval 'mvcoffee.models.department.data[0].item[1].name'
      assert_equal items[1].name, result      

      result = js.eval 'mvcoffee.models.department.data[0].item[2].id'
      assert_equal items[2].id, result      

      result = js.eval 'mvcoffee.models.department.data[0].item[2].name'
      assert_equal items[2].name, result      


      result = js.eval 'mvcoffee.models.department.data[1].id'
      assert_equal departments[1].id, result
    
      result = js.eval 'mvcoffee.models.department.data[1].name'
      assert_equal departments[1].name, result
    
      # Here's the real clincher!  The to_hash override excludes this.
      result = js.eval 'mvcoffee.models.department.data[1].updated_at'
      assert_nil result

    
      # Plus, we should get hierarchical data here
      result = js.eval 'mvcoffee.models.department.data[1].item.length'
      assert_equal 3, result      

      items = departments[1].items

      result = js.eval 'mvcoffee.models.department.data[1].item[0].id'
      assert_equal items[0].id, result      

      result = js.eval 'mvcoffee.models.department.data[1].item[0].name'
      assert_equal items[0].name, result      

      result = js.eval 'mvcoffee.models.department.data[1].item[1].id'
      assert_equal items[1].id, result      

      result = js.eval 'mvcoffee.models.department.data[1].item[1].name'
      assert_equal items[1].name, result      

      result = js.eval 'mvcoffee.models.department.data[1].item[2].id'
      assert_equal items[2].id, result      

      result = js.eval 'mvcoffee.models.department.data[1].item[2].name'
      assert_equal items[2].name, result      
    end
      
    should "set replace on model data with a collection of models" do
      items = @department1.items
      @mvcoffee.set_model_replace_on 'item', items, department_id: @department1.id
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.replace_on.department_id'
      assert_equal @department1.id, result
      
      result = js.eval 'mvcoffee.models.item.data.length'
      assert_equal 3, result
      
      result = js.eval 'mvcoffee.models.item.data[0].id'
      assert_equal items[0].id, result
      
      result = js.eval 'mvcoffee.models.item.data[0].department_id'
      assert_equal items[0].department.id, result
      
      result = js.eval 'mvcoffee.models.item.data[0].name'
      assert_equal items[0].name, result
      
      result = js.eval 'mvcoffee.models.item.data[0].sku'
      assert_equal items[0].sku, result
      
      result = js.eval 'mvcoffee.models.item.data[0].price'
      assert_equal items[0].price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data[0].updated_at'
      assert_not_nil result
      
      result = js.eval 'mvcoffee.models.item.data[1].id'
      assert_equal items[1].id, result
      
      result = js.eval 'mvcoffee.models.item.data[1].department_id'
      assert_equal items[1].department.id, result
      
      result = js.eval 'mvcoffee.models.item.data[1].name'
      assert_equal items[1].name, result
      
      result = js.eval 'mvcoffee.models.item.data[1].sku'
      assert_equal items[1].sku, result
      
      result = js.eval 'mvcoffee.models.item.data[1].price'
      assert_equal items[1].price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data[1].updated_at'
      assert_not_nil result
      
      result = js.eval 'mvcoffee.models.item.data[2].id'
      assert_equal items[2].id, result
      
      result = js.eval 'mvcoffee.models.item.data[2].department_id'
      assert_equal items[2].department.id, result
      
      result = js.eval 'mvcoffee.models.item.data[2].name'
      assert_equal items[2].name, result
      
      result = js.eval 'mvcoffee.models.item.data[2].sku'
      assert_equal items[2].sku, result
      
      result = js.eval 'mvcoffee.models.item.data[2].price'
      assert_equal items[2].price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data[2].updated_at'
      assert_not_nil result
    end
      
    should "set delete on a single model" do
      @mvcoffee.set_model_delete 'item', @item11.id
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.delete.length'
      assert_equal 1, result
    
      result = js.eval 'mvcoffee.models.item.delete[0]'
      assert_equal @item11.id, result
    end    
      
    should "set delete on a Array of models" do
      deletes = [@item11.id, @item21.id]
      @mvcoffee.set_model_delete 'item', deletes
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.delete.length'
      assert_equal 2, result
    
      result = js.eval 'mvcoffee.models.item.delete[0]'
      assert_equal @item11.id, result
    
      result = js.eval 'mvcoffee.models.item.delete[1]'
      assert_equal @item21.id, result
    end    
      
    should "set delete on a two single models added separately" do
      @mvcoffee.set_model_delete 'item', @item11.id
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.delete.length'
      assert_equal 1, result
    
      result = js.eval 'mvcoffee.models.item.delete[0]'
      assert_equal @item11.id, result
      
      @mvcoffee.set_model_delete 'item', @item21.id

      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.delete.length'
      assert_equal 2, result
    
      result = js.eval 'mvcoffee.models.item.delete[0]'
      assert_equal @item11.id, result
    
      result = js.eval 'mvcoffee.models.item.delete[1]'
      assert_equal @item21.id, result
    end    
    
    # ----------------------------------------------------------------------
    # Check pass through on set data
    
    should "pass through fetched data on set_model_data" do
      fetched = Department.all
      
      returned = @mvcoffee.set_model_data 'department', fetched
      
      assert_equal fetched, returned
    end
    
    should "pass through fetched data on set_model_replace_on" do
      fetched = Department.all
      
      returned = @mvcoffee.set_model_replace_on 'department', fetched, {}
      
      assert_equal fetched, returned
    end

    # ----------------------------------------------------------------------
    # Check convenience fetchers
    #
    
    should "return the correct entity from find" do
      id = @department1.id
      
      fetched = @mvcoffee.find Department, id
      
      assert_equal @department1, fetched
    end
    
    should "set the session for the fetched entity on find" do
      id = @department1.id
      
      fetched = @mvcoffee.find Department, id
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.session.department_id'
      assert_equal id, result
    end
    
    should "populate the JSON using find" do
      id = @item11.id
      
      fetched = @mvcoffee.find Item, id

      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.data.id'
      assert_equal @item11.id, result
      
      result = js.eval 'mvcoffee.models.item.data.department_id'
      assert_equal @item11.department.id, result
      
      result = js.eval 'mvcoffee.models.item.data.name'
      assert_equal @item11.name, result
      
      result = js.eval 'mvcoffee.models.item.data.sku'
      assert_equal @item11.sku, result
      
      result = js.eval 'mvcoffee.models.item.data.price'
      assert_equal @item11.price.to_s, result
      
      result = js.eval 'mvcoffee.models.item.data.updated_at'
      assert_not_nil result
    end
      
    should "return the correct entities from all" do
      departments = Department.all
      
      fetched = @mvcoffee.all Department
      
      assert_equal departments, fetched
    end
    
    should "populate the JSON using all" do
      departments = Department.all
      
      fetched = @mvcoffee.all Department
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.department.data.length'
      assert_equal 2, result      
      
      result = js.eval 'mvcoffee.models.department.data[0].name'
      assert_equal departments[0].name, result      
      
      result = js.eval 'mvcoffee.models.department.data[1].name'
      assert_equal departments[1].name, result      
      
      result = js.eval 'mvcoffee.models.department.replace_on'
      assert_equal Hash.new, result      
    end

    should "return the correct entities from fetch_has_many with singular symbol" do
      department = @department1
      items = department.items
      
      fetched = @mvcoffee.fetch_has_many department, :item
      
      assert_equal items, fetched
    end
    
    should "return the correct entities from fetch_has_many with plural symbol" do
      department = @department1
      items = department.items
      
      fetched = @mvcoffee.fetch_has_many department, :items
      
      assert_equal items, fetched
    end

    should "return the correct entities from fetch_has_many with singular string" do
      department = @department1
      items = department.items
      
      fetched = @mvcoffee.fetch_has_many department, 'item'
      
      assert_equal items, fetched
    end
    
    should "return the correct entities from fetch_has_many with plural string" do
      department = @department1
      items = department.items
      
      fetched = @mvcoffee.fetch_has_many department, 'items'
      
      assert_equal items, fetched
    end
    
    should "set the session for the fetched has_many entity on find" do
      department = @department1
      
      fetched = @mvcoffee.fetch_has_many department, :items
    
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.session.department_id'
      assert_equal @department1.id, result
    end
    
    should "populate the JSON using fetch_has_many with singular symbol" do
      department = @department1
      items = department.items
      
      fetched = @mvcoffee.fetch_has_many department, :item
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.data.length'
      assert_equal 3, result      
      
      result = js.eval 'mvcoffee.models.item.data[0].name'
      assert_equal items[0].name, result      
      
      result = js.eval 'mvcoffee.models.item.data[1].name'
      assert_equal items[1].name, result      
      
      result = js.eval 'mvcoffee.models.item.data[2].name'
      assert_equal items[2].name, result      
      
      expected_replace_on = { "department_id" => department.id}
      result = js.eval 'mvcoffee.models.item.replace_on'
      assert_equal expected_replace_on, result      
    end
    
    should "populate the JSON using fetch_has_many with plural symbol" do
      department = @department1
      items = department.items
      
      fetched = @mvcoffee.fetch_has_many department, :items
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.item.data.length'
      assert_equal 3, result      
      
      result = js.eval 'mvcoffee.models.item.data[0].name'
      assert_equal items[0].name, result      
      
      result = js.eval 'mvcoffee.models.item.data[1].name'
      assert_equal items[1].name, result      
      
      result = js.eval 'mvcoffee.models.item.data[2].name'
      assert_equal items[2].name, result      
      
      expected_replace_on = { "department_id" => department.id}
      result = js.eval 'mvcoffee.models.item.replace_on'
      assert_equal expected_replace_on, result      
    end

    should "destroy a record using the convenience delete method" do
      @mvcoffee.delete! @department1
      
      departments = Department.all
      
      assert_equal 1, departments.count
      assert_equal @department2, departments[0]
    end

    should "set delete in the JSON using the convenience delete method" do
      @mvcoffee.delete! @department1
      
      script = "mvcoffee = " + @mvcoffee.to_json
      js = ExecJS.compile(script)
      
      result = js.eval 'mvcoffee.models.department.delete.length'
      assert_equal 1, result
    
      result = js.eval 'mvcoffee.models.department.delete[0]'
      assert_equal @department1.id, result
    end    

  end
end

