class AddFieldsToLinks < ActiveRecord::Migration
  def self.up
  	add_column :link_categories, :link_category_id, :integer
  	add_column :link_categories, :active, :boolean, :default => true
  	add_column :links, :person_id, :integer
  	add_index :links, :link_category_id
  	add_index :links, :person_id
  	add_index :link_categories, :link_category_id
    create_table :link_categories_links, :id => false do |t|
      t.integer :link_category_id, :link_id
    end
  	add_index :link_categories_links, [:link_category_id, :link_id], :unique => true
	add_index :link_categories_links, :link_category_id
  end

  def self.down
  	remove_column :link_categories, :link_category_id
  	remove_column :link_categories, :active
  	remove_column :links, :person_id
  	remove_index :links, :link_category_id
  	remove_index :links, :person_id
  	remove_index :link_categories, :link_category_id
  	drop_table :links_link_categories
  	remove_index :links_link_categories, [:link_id, :link_category_id]
  	remove_index :links_link_categories, :link_category_id
  end
end
