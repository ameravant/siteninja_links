class ColumnSectionLinkCategory < ActiveRecord::Base
  belongs_to :column_section
  belongs_to :link_category
  default_scope :order => :sort_order
end
