class Link < ActiveRecord::Base
  belongs_to :link_category
  has_and_belongs_to_many :link_categories
  has_permalink :title
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_presence_of :link_category, :on => :create, :message => "You must have a link category selected"
  acts_as_taggable
  named_scope :active, {:conditions => {:public => true}}
  named_scope :featured, {:conditions => {:featured => true, :public => true}}
  has_many :images, :as => :viewable, :dependent => :destroy
  has_many :assets, :as => :attachable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  has_many :menus, :as => :navigatable, :dependent => :destroy
  belongs_to :link_layout, :class_name => "Column", :foreign_key => :link_main_column_id
  default_scope :order => :position
  accepts_nested_attributes_for :images
  
  def to_param
    "#{self.id}-#{self.permalink}"
  end
  
  def description
    self.blurb
  end
  
  def active
    self.public
  end
  
  def smart_body
    unless self.body.blank?
      self.body
    else
      self.blurb
    end
  end
  def name
    self.title
  end
  if RAILS_ENV == "production"
    def to_liquid
      {'title' => self.title, 'blurb' => self.blurb, 'body' => self.body}
    end
  end
end
