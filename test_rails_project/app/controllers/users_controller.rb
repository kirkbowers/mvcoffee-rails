class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :login]

  # GET /users
  # GET /users.json
  def index
    @users = @mvcoffee.all User
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @mvcoffee.fetch_has_many @user, :shopping_cart_item
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to user_path(@user), notice: 'User was successfully created.'
    else
      render :new, errors: @user.errors
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, errors: @user.errors
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @mvcoffee.delete! @user
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  def login
    if @user
      session[:user_id] = @user.id
      redirect_to departments_path, notice: "Now logged in as #{ @user.name }"
    else
      session[:user_id] = nil
      redirect_to users_path, notice: "Invalid attempt to log in"
    end
  end
  
  def logout
    session[:user_id] = nil
    redirect_to users_path, notice: "User logged out"
  end    

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = @mvcoffee.find User, params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end
end
