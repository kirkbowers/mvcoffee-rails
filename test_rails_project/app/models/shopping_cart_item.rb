class ShoppingCartItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  def to_hash
    {
      id: id,
      user_id: user_id,
      item_id: item_id,
      item: item.as_json
    }
  end
end
