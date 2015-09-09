class AddItemsUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :items_updated_at, :datetime    
  end
end
