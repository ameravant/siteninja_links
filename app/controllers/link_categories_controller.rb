class LinkCategoriesController < LinksController
  unloadable
  def index
    
    if !params[:tag].blank?
      # Filter link by tag
      all_links = Link.active.find_tagged_with(params[:tag])
      add_breadcrumb @cms_config['site_settings']['links_title'], link_categories_path
      add_breadcrumb params[:tag]
    else
      add_breadcrumb @cms_config['site_settings']['links_title']
      all_links = Link.find(:all, :conditions => {:public => true, :featured => true}, :order => :title)
    end
    count = @cms_config['site_settings']['links_pagination_count'] ? @cms_config['site_settings']['links_pagination_count'] : 8
		@links = all_links.paginate(:page => params[:page], :per_page => count)
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml { render :xml => all_links.to_xml }
      wants.rss { render :layout => false } # uses index.rss.builder
    end
    @page = Page.find_by_permalink("links")
    @main_column = ((@page.main_column_id.blank? or Column.find_by_id(@page.main_column_id).blank?) ? Column.first(:conditions => {:title => "Default", :column_location => "main_column"}) : Column.find(@page.main_column_id))
    @main_column_sections = ColumnSection.all(:conditions => {:column_id => @main_column.id, :visible => true, :column_section_id => nil})
  end

  def show
  add_breadcrumb @cms_config['site_settings']['links_title'], 'link_categories_path'
    @page = Page.find_by_permalink("links")
    @main_column = ((@page.main_column_id.blank? or Column.find_by_id(@page.main_column_id).blank?) ? Column.first(:conditions => {:title => "Default", :column_location => "main_column"}) : Column.find(@page.main_column_id))
    @main_column_sections = ColumnSection.all(:conditions => {:column_id => @main_column.id, :visible => true, :column_section_id => nil})
    @link_category = LinkCategory.find(params[:id])
    @link_category.menus.empty? ? @menu = @page.menus.first : @menu = @link_category.menus.first
    @links = Link.find(:all, :conditions => {:link_category_id => @link_category.id, :public => true})
    add_breadcrumb @link_category.title
  end
end

