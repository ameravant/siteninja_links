class LinkCategory < ActiveRecord::Base
  has_permalink :title
	has_many :links
	validates_presence_of :title
	has_many :images, :as => :viewable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :menus, :as => :navigatable, :dependent => :destroy
  default_scope :order => "title"
  
	def to_param
	 "#{self.id}-#{self.permalink}"
	end
	def name
	  self.title
	end
end
