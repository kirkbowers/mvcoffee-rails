class AddItemsUpdatedAtToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :items_updated_at, :datetime    
  end
end
