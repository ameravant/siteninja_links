class AddMainColumnIdToLinkCategories < ActiveRecord::Migration
  def self.up
  	add_column :link_categories, :main_column_id, :integer
  	add_column :link_categories, :link_main_column_id, :integer
  end

  def self.down
  	remove_column :link_categories, :main_column_id
  	remove_column :link_categories, :link_main_column_id
  end
end
