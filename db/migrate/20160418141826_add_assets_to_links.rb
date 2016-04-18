class AddAssetsToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :assets_count, :integer, :default => 0
  end

  def self.down
    remove_column :links, :assets_count
  end
end
