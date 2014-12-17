class LinkCategory < ActiveRecord::Base
  has_permalink :title
	has_many :links
	has_and_belongs_to_many :links
  has_many :link_categories
  belongs_to :link_category
	validates_presence_of :title
	has_many :images, :as => :viewable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :menus, :as => :navigatable, :dependent => :destroy
  has_many :column_section_link_categories
  has_many :column_sections, :through => :column_section_link_categories
  default_scope :order => "title"
  
	def to_param
	 "#{self.id}-#{self.permalink}"
	end
	def name
	  self.title
	end
end
