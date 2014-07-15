class ChangeLinksFeaturedDefaultValue < ActiveRecord::Migration
  def self.up
    change_column :links, :featured, :boolean, :default => false
  end

  def self.down
    change_column :links, :featured, :boolean, :default => true
  end
end