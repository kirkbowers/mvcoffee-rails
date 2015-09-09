class Department < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :items

  # This does a lot.
  # It creates a new method in this class, an after action callback in this class,
  # plus a new method and a couple of after actions in the Item class
  caches_via_mvcoffee :items
end
