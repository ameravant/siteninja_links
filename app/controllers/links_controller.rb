class LinksController < ApplicationController
  unloadable
  before_filter :get_links_side
  add_breadcrumb "Home", "root_path"

  def index
    @link_categories = LinkCategory.all(:conditions => {:link_category_id => nil})
    if !params[:tag].blank?
      # Filter link by tag
      all_links = Link.active.find_tagged_with(params[:tag])
      add_breadcrumb @cms_config['site_settings']['links_title'], link_categories_path
      add_breadcrumb params[:tag]
    else
      add_breadcrumb @cms_config['site_settings']['links_title']
      all_links = Link.find(:all, :conditions => {:public => true}, :order => :title)
    end
    count = (@cms_config['site_settings']['links_pagination_count'] and !@cms_config['site_settings']['links_pagination_count'].blank?) ? @cms_config['site_settings']['links_pagination_count'] : 20
    @links = all_links.paginate(:page => params[:page], :per_page => count)
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml { render :xml => all_links.to_xml }
      wants.rss { render :layout => false } # uses index.rss.builder
    end
  end

  def show
    expires_in 60.minutes, :public => true
    @link = Link.find(params[:id], :conditions => {:public => true})
    @images = @link.images
    @link_category = @link.link_category
    @menu = @link_category.menus.first if !@link_category.blank? and !@link_category.menus.empty?
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
      @main_column = ((@page.main_column_id.blank? or Column.find_by_id(@page.main_column_id).blank?) ? Column.first(:conditions => {:title => "Default", :column_location => "main_column"}) : Column.find(@page.main_column_id))
      @main_column_sections = ColumnSection.all(:conditions => {:column_id => @main_column.id, :visible => true, :column_section_id => nil})
      @link_categories = LinkCategory.find(:all)
      @all_links = Link.find_tagged_with(params[:id], :order => "links.created_at desc", :conditions => { :public => true })
      @links = @all_links.paginate(:page => params[:page], :per_page => 8)
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

