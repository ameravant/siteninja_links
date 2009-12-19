class LinkCategory < ActiveRecord::Base
  has_permalink :title
	has_many :links
	validates_presence_of :title
	
	def to_param
	 "#{self.id}-#{self.permalink}"
	end
end
