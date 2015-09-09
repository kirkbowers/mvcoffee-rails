class User < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :shopping_cart_items
  has_many :items, through: :shopping_cart_items

end
