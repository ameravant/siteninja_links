class LinksController < ApplicationController
  unloadable
  before_filter :get_links_side
  before_filter :authenticate, :only => :show
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
      all_links = Link.find(:all, :conditions => {:public => true}, :order => @cms_config['site_settings']['links_alphabetical'] ? :title : :position)
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
    #expires_in 60.minutes, :public => true
    @link = Link.find(params[:id], :conditions => {:public => true})
    @images = @link.images
    @link_category = @link.link_category
    @menu = @link_category.menus.first if !@link_category.blank? and !@link_category.menus.empty?
    add_breadcrumb @cms_config['site_settings']['links_title'], link_categories_path
    add_breadcrumb @link.link_category.title, link_category_path(@link.link_category)
    add_breadcrumb @link.title
    if !params[:page_layout].blank?
      @main_column = Column.find(params[:page_layout])
    elsif !@link_category.link_layout.blank?
      @main_column = Column.find(@link_category.link_main_column_id)
    elsif @link_category.page_layout.blank?
      if @page.page_layout.blank?
        @main_column = Column.first(:conditions => {:title => "Default", :column_location => "main_column"})
      else
        @main_column = Column.find(@page.main_column_id)
      end
    else
      @main_column = Column.find(@link_category.main_column_id)
    end
    @main_column_sections = ColumnSection.all(:conditions => {:column_id => @main_column.id, :visible => true, :column_section_id => nil})
  end

  def new
    @page = Page.find_by_permalink("link-exchange")
		@link = Link.new
  end

  def get_links_side
    if @cms_config['modules']['links']
      #render_404 unless 
      @page = Page.find_by_permalink("links")
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
        #render_404 
      end
    end

  end

  private

  def authenticate
    @link = Link.find(params[:id], :conditions => {:public => true})
    @link_category = @link.link_category
    if @cms_config['modules']['members'] && @link_category.permission_level != "everyone"
      session[:redirect] = request.request_uri
      authorize(@link_category.person_groups.collect{|p| p.title}, @link_category.title)
    end
  end

end

