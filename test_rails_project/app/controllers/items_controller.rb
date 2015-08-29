class ItemsController < ApplicationController
  before_action :set_department
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @mvcoffee.fetch_has_many @department, :items
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
      redirect_to department_item_path(@department.id, @item.id), notice: 'Item was successfully created.'
    else
      render :new, errors: @item.errors
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    if @item.update(item_params)
      redirect_to department_item_path(@department.id, @item.id), notice: 'Item was successfully updated.'
    else
      render :edit, errors: @item.errors
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @mvcoffee.delete! @item
    
    redirect_to department_items_path, notice: 'Department was successfully destroyed.'
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
