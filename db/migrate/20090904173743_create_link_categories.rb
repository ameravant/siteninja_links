class CreateLinkCategories < ActiveRecord::Migration
  def self.up
    create_table :link_categories do |t|
      t.string :title, :null => false
      t.string :permalink
      t.integer :position, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :link_categories
  end
end
