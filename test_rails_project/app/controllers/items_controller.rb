class ItemsController < ApplicationController
  before_action :set_department
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @items = @department.items
    
    @mvcoffee.set_model_data "department", @department
    @mvcoffee.set_model_replace_on "item", @items, department_id: @department.id
    @mvcoffee.set_session department_id: @department.id
    
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
      @mvcoffee.set_model_data "item", @item
      @mvcoffee.set_redirect department_item_path(@department.id, @item.id), notice: 'Item was successfully created.'
    else
      @mvcoffee.set_errors @item.errors
    end

    render_mvcoffee    
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    if @item.update(item_params)
      @mvcoffee.set_model_data "item", @item
      @mvcoffee.set_redirect department_item_path(@department.id, @item.id), notice: 'Item was successfully updated.'
    else
      @mvcoffee.set_errors @item.errors
    end

    render_mvcoffee    
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    
    @mvcoffee.set_model_delete "item", @item.id
    @mvcoffee.set_redirect department_items_path, notice: 'Department was successfully destroyed.'
    
    render_mvcoffee
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    def set_department
      @department = Department.find(params[:department_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:name, :sku, :price, :department_id)
    end
end
