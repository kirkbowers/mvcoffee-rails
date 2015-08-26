require 'test_helper'

require "shoulda/context"
require "execjs"

class MvcoffeeJson < ActiveSupport::TestCase
  include MVCoffee

  context "When converting MVCoffee object to json" do
    setup do
      @mvcoffee = MVCoffee::MVCoffee.new
      @department1 = departments(:one)
      @department2 = departments(:one)
      @item11 = items(:one_one)
      @item21 = items(:two_one)
      @item31 = items(:three_one)
      @item12 = items(:one_two)
      @item22 = items(:two_two)
      @item32 = items(:three_two)
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
  end
end

