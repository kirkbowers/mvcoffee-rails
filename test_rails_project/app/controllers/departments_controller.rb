class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  # GET /departments
  # GET /departments.json
  def index
    @departments = @mvcoffee.all Department        
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
    redirect_to department_items_path(@department.id)
  end

  # GET /departments/new
  def new
    @department = Department.new
  end

  # GET /departments/1/edit
  def edit
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)

    if @department.save
      redirect_to department_path(@department), notice: 'Department was successfully created.'
    else
      render :show, errors: @department.errors
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    if @department.update(department_params)
      redirect_to department_path(@department), notice: 'Department was successfully updated.'
    else
      render :edit, errors: @department.errors
    end 
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @mvcoffee.delete! @department

    redirect_to departments_path, notice: 'Department was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = @mvcoffee.find Department, params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:name)
    end
end
