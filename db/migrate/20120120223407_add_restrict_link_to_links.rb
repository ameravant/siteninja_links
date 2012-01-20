class AddRestrictLinkToLinks < ActiveRecord::Migration
  def self.up
    begin
      add_column :links, :restrict_link, :boolean, :default => false
    rescue
      #do nothing
    end
  end

  def self.down
    remove_column :links, :restrict_link
  end
end
