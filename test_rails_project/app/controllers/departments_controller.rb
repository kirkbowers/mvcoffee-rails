class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  # GET /departments
  # GET /departments.json
  def index
    @departments = @mvcoffee.all Department
        
    render_mvcoffee
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
    @mvcoffee.set_redirect department_items_path(@department.id)
    
    render_mvcoffee
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
      @mvcoffee.set_redirect department_path(@department), notice: 'Department was successfully created.'
    else
      @mvcoffee.set_errors @department.errors
    end

    render_mvcoffee :show, status: :created, location: @deparment
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    if @department.update(department_params)
      @mvcoffee.set_redirect department_path(@department), notice: 'Department was successfully updated.'
    else
      @mvcoffee.set_errors @department.errors
    end 

    render_mvcoffee :index
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @mvcoffee.delete @department

    @mvcoffee.set_redirect departments_path, notice: 'Department was successfully destroyed.'
    
    render_mvcoffee :index
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