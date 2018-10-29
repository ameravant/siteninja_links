class AddLinkLayoutToLinks < ActiveRecord::Migration
  def self.up
  	add_column :links, :link_main_column_id, :integer
  end

  def self.down
  	remove_column :links, :link_main_column_id
  end
end
