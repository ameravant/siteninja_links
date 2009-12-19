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
		@links = all_links.paginate(:page => params[:page], :per_page => 8)
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml { render :xml => all_links.to_xml }
      wants.rss { render :layout => false } # uses index.rss.builder
    end
  end

  def show
  add_breadcrumb @cms_config['site_settings']['links_title'], 'link_categories_path'
    @page = Page.find_by_permalink("links")
    @link_category = LinkCategory.find(params[:id])
    @links = Link.find(:all, :conditions => {:link_category_id => @link_category.id})
    add_breadcrumb @link_category.title
  end
end

