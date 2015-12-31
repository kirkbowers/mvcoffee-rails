class ApplicationController < ActionController::Base
  include MVCoffee
  
  monkeypatch_mvcoffee

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize
  
protected

  def authorize
    if session[:user_id]
      @shopping_user = User.find session[:user_id]
      @mvcoffee.merge_model_data "user", @shopping_user
      @mvcoffee.set_session shopping_user_id: @shopping_user.id
    else
      @shopping_user = nil
      @mvcoffee.set_session shopping_user_id: nil
    end
  end
end
