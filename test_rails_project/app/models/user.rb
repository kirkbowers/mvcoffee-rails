class User < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :shopping_cart_items
  has_many :items, through: :shopping_cart_items

  # This does a lot.
  # It creates a new method in this class, an after action callback in this class,
  # plus a new method and a couple of after actions in both the Item class
  # and the ShoppingCartItem class
  caches_via_mvcoffee :items, through: :shopping_cart_items
end
