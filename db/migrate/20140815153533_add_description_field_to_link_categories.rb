class AddDescriptionFieldToLinkCategories < ActiveRecord::Migration
  def self.up
    add_column :link_categories, :description, :text
  end

  def self.down
    remove_column :link_categories, :description
  end
end