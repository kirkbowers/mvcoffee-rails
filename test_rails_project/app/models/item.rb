class Item < ActiveRecord::Base
  belongs_to :department
  has_many :shopping_cart_items
  has_many :users, through: :shopping_cart_items

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, numericality: { only_integer: true, greater_than: 0 }
end
