class Item < ActiveRecord::Base
  belongs_to :department
  has_many :shopping_cart_items
  has_many :users, through: :shopping_cart_items

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, numericality: { only_integer: true, greater_than: 0 }

  scope :inexpensive, -> { where("price < 10.00") }

  # This is only necessary because we are trying to cache both the entire list of all
  # items for a department as well as the "inexpensive" scope.
  # If the full list is loaded after the scope is cached, it will clobber the 
  # automatically supplied inexpensive property put in place by the refresh_has_many
  # method in mvcoffee-rails.
  def to_hash
    result = as_json
    result['inexpensive'] = price < 10.0
    
    result
  end
end
