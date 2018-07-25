class LinkCategoriesController < LinksController
  unloadable

  before_filter :authenticate, :only => :show

  def index
    #expires_in 60.minutes, :public => true
    if !params[:tag].blank?
      # Filter link by tag
      all_links = Link.active.find_tagged_with(params[:tag])
      add_breadcrumb @cms_config['site_settings']['links_title'], link_categories_path
      add_breadcrumb params[:tag]
    elsif params[:letter]
      add_breadcrumb @cms_config['site_settings']['links_title']
      all_links = Link.all(:conditions => ["title like ? and public = ?", "#{params[:letter]}%", true], :order => @cms_config['site_settings']['links_alphabetical'] ? :title : :position)
    else
      add_breadcrumb @cms_config['site_settings']['links_title']
      all_links = Link.find(:all, :conditions => {:public => true}, :order => @cms_config['site_settings']['links_alphabetical'] ? :title : :position)
    end
    count = (@cms_config['site_settings']['links_pagination_count'] and !@cms_config['site_settings']['links_pagination_count'].blank?) ? @cms_config['site_settings']['links_pagination_count'] : 8
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
  #expires_in 60.minutes, :public => true
  add_breadcrumb @cms_config['site_settings']['links_title'], 'link_categories_path'
    @page = Page.find_by_permalink("links")
    #@main_column = ((@page.main_column_id.blank? or Column.find_by_id(@page.main_column_id).blank?) ? Column.first(:conditions => {:title => "Default", :column_location => "main_column"}) : Column.find(@page.main_column_id))
    @link_category = LinkCategory.find(params[:id])
    @link_category.menus.empty? ? @menu = @page.menus.first : @menu = @link_category.menus.first
    if !params[:page_layout].blank?
      @main_column = Column.find(params[:page_layout])
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
    @links = @link_category.links.active
    add_breadcrumb @link_category.title
  end

  private

  def authenticate
    @link_category = LinkCategory.find(params[:id])
    if @link_category.link_category_id.blank?
      @parent_category = @link_category
    else
      find_parent(@link_category.link_category)
    end
    if @cms_config['modules']['members'] && @parent_category.permission_level != "everyone"
      session[:redirect] = request.request_uri
      authorize(@parent_category.person_groups.collect{|p| p.title}, @parent_category.title)
    end
  end

  def find_parent(link_category)
    if link_category.link_category.blank?
      @parent_category = link_category
    else
      find_parent(link_category.link_category)
    end
  end

end

