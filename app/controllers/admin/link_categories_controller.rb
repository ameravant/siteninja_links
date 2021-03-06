class Admin::LinkCategoriesController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :find_link_category, :only => [ :edit, :update, :destroy ]
  before_filter :add_crumbs
  before_filter :start_build_options
  before_filter :build_options, :only => [ :edit, :new, :create, :update ]
  add_breadcrumb "Categories", "admin_link_categories_path", :except => [ :index, :destroy ]
  add_breadcrumb "New Category", nil, :only => [ :new, :create ]
  
  def index
    @link_categories = LinkCategory.all(:conditions => {:link_category_id => nil})
    add_breadcrumb "Categories", nil
  end

  def new
    @link_category = LinkCategory.new
    @layouts = Column.all(:conditions => {:column_location => "main_column"})
  end

  def create
    @link_category = LinkCategory.new(params[:link_category])
    if @link_category.save
      flash[:notice] = "Category \"#{@link_category.title}\" created."
      log_activity("Created \"#{@link_category.title}\"")
      redirect_to admin_link_categories_path
    else
      render :action => "new"
    end
  end

  def edit
    add_breadcrumb @link_category.title
    @layouts = Column.all(:conditions => {:column_location => "main_column"})
  end

  def update
    add_breadcrumb @link_category.title
    if @link_category.update_attributes(params[:link_category])
      flash[:notice] = "Category \"#{@link_category.title}\" updated."
      log_activity("Updated \"#{@link_category.title}\"")
      redirect_to admin_link_categories_path
    else
      render :action => "edit"
    end
  end

  def destroy
    log_activity("Deleted \"#{@link_category.title}\"")
    @link_category.destroy
    respond_to :js
  end

  def receive_drop
    @link_categories = LinkCategory.all(:conditions => {:link_category_id => nil})
    lc_id = params[:id].to_s.gsub("link_category_", "").to_i
    lc = LinkCategory.find(lc_id)
    lc.update_attributes(:link_category_id => params[:parent_id]) unless params[:parent_id].to_i == lc.id.to_i
    render :action => :index, :layout => false
    #redirect_to admin_link_categories_path
  end

  def ajax_category_list
    render :layout => false
  end

  private

  def start_build_options
    @options_for_parent_id = [['Top level category','']]
    @options_for_parent_id_level = 0
  end

  def build_options(parent_id=nil)
    unless LinkCategory.all.empty?
      children = LinkCategory.all(:conditions => {:link_category_id => parent_id})
      @options_for_parent_id_level = @options_for_parent_id_level + 1
      unless children.empty?
        for child in children
          nbsp_string = '&nbsp;' * (@options_for_parent_id_level * @options_for_parent_id_level) unless @options_for_parent_id_level == 1 
          if params[:id]
            @options_for_parent_id << ["#{nbsp_string}#{child.title}", child.id] unless child.id == LinkCategory.find(params[:id]).id
          else
            @options_for_parent_id << ["#{nbsp_string}#{child.title}", child.id] 
          end
          build_options(child.id)
        end
      end
      @options_for_parent_id_level = @options_for_parent_id_level - 1
    end
  end


  def find_link_category
    begin
      @link_category = LinkCategory.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Link category was not found. It may have been deleted."
      redirect_to admin_link_categories_path
    end
  end

  def log_activity(description)
    add_activity(controller_name.classify, @link_category.id, description)
  end

  def authorization
    authorize(@permissions['link_categories'], "Link Categories")
  end
  def add_crumbs
    add_breadcrumb @cms_config['site_settings']['links_title'], "admin_links_path"
  end
end

