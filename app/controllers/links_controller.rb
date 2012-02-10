class LinksController < ApplicationController
  unloadable
  before_filter :get_links_side
  add_breadcrumb "Home", "root_path"

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
		@links = all_links.paginate(:page => params[:page], :per_page => 20)
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml { render :xml => all_links.to_xml }
      wants.rss { render :layout => false } # uses index.rss.builder
    end
  end

  def show
    @link = Link.find(params[:id])
    @images = @link.images
    @link_category = @link.link_category
    add_breadcrumb @cms_config['site_settings']['links_title'], link_categories_path
    add_breadcrumb @link.link_category.title, link_category_path(@link.link_category)
    add_breadcrumb @link.title
  end

  def new
    @page = Page.find_by_permalink("link-exchange")
		@link = Link.new
  end

  def get_links_side
    if @cms_config['modules']['links']
      render_404 unless @page = Page.find_by_permalink("links")
      @link_categories = LinkCategory.find(:all)
      @all_links = Link.find_tagged_with(params[:id], :order => "links.created_at desc", :conditions => { :public => true })
      @links = @all_links.paginate(:page => params[:page], :per_page => 8)
      @link_tags = Link.active.tag_counts
    else
      if @page = Page.find_by_permalink('links') and params[:action] == "index"
        get_page_defaults(@page)
        render 'pages/show'
      else
        render_404 
      end
    end

  end
end

