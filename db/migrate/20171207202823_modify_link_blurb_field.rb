class ModifyLinkBlurbField < ActiveRecord::Migration
  def self.up
  	change_column :links, :blurb, :text, :limit => nil
  end

  def self.down
  	change_column :links, :blurb, :string
  end
end
