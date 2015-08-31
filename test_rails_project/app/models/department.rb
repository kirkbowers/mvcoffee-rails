class Department < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :items

  # This does a lot.
  # It creates a new method in this
  caches_via_mvcoffee :items
end
