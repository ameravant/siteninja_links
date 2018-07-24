class AddPermissionsToLinkCategories < ActiveRecord::Migration
  def self.up
    add_column :link_categories, :permission_level, :string, :default => "everyone"
    create_table :link_categories_person_groups, :id => false do |t|
      t.integer :person_group_id
      t.integer :link_category_id
    end
  end

  def self.down
    remove_column :link_categories, :permission_level
    drop_table :link_categories_person_groups
  end
end
