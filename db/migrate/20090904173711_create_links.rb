class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :title, :permalink, :null => false
      t.string :url, :link_back, :image, :blurb
      t.text :body
      t.integer :position, :default => 1
      t.boolean :featured, :public, :default => true
      t.integer :features_count, :images_count, :default => 0
      t.integer :link_category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
