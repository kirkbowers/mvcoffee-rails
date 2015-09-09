class ShoppingCartItemsController < ApplicationController
  def create
    if @shopping_user
      @item = Item.find(params[:item_id])
      @shopping_user.items << @item
      redirect_to user_path(@shopping_user), notice: "#{ @item.name } added to cart"
    end
  end

  def destroy
    if @shopping_user
      cart_item = ShoppingCartItem.find_by(user_id: @shopping_user.id, item_id: params[:item_id])
      if cart_item
        cart_item.destroy
        redirect_to user_path(@shopping_user), notice: "Item has been removed"
      end
    end
  end
end
