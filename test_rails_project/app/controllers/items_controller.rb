class ItemsController < ApplicationController
  before_action :set_department
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @mvcoffee.fetch_has_many @department, :items
    
    render_mvcoffee
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = @department.items.build(item_params)

    if @item.save
      @mvcoffee.set_redirect department_item_path(@department.id, @item.id), notice: 'Item was successfully created.'
    else
      @mvcoffee.set_errors @item.errors
    end

    # The :index argument is largely ignored, except when running tests.
    render_mvcoffee :index
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    if @item.update(item_params)
      @mvcoffee.set_redirect department_item_path(@department.id, @item.id), notice: 'Item was successfully updated.'
    else
      @mvcoffee.set_errors @item.errors
    end

    # The :index argument is largely ignored, except when running tests.
    render_mvcoffee  :index
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @mvcoffee.delete @item
    
    @mvcoffee.set_redirect department_items_path, notice: 'Department was successfully destroyed.'
    
    # The :index argument is largely ignored, except when running tests.
    render_mvcoffee :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @mvcoffee.find Item, params[:id]
    end

    def set_department
      @department = @mvcoffee.find Department, params[:department_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:name, :sku, :price, :department_id)
    end
end
