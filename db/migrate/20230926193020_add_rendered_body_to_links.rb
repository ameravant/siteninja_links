class AddRenderedBodyToLinks < ActiveRecord::Migration
  def self.up
  	add_column :links, :rendered_body, :text
  end

  def self.down
  	remove_column :links, :rendered_body
  end
end

