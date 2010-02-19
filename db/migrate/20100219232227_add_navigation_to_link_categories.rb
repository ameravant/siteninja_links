class AddNavigationToLinkCategories < ActiveRecord::Migration
  def self.up
    add_column :link_categories, :menus_count, :integer, :default => 0
    add_column :link_categories, :images_count, :integer, :default => 0
    add_column :link_categories, :features_count, :integer, :default => 0
  end

  def self.down
    remove_column :link_categories, :menus_count
    remove_column :link_categories, :images_count
    remove_column :link_categories, :features_count
  end
end
