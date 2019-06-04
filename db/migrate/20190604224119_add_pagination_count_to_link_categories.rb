class AddPaginationCountToLinkCategories < ActiveRecord::Migration
  def self.up
  	add_column :link_categories, :pagination_count, :integer
  end

  def self.down
  	remove_column :link_categories, :pagination_count
  end
end
