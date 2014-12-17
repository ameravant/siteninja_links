class Admin::LinkCategoriesController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authorization
  before_filter :find_link_category, :only => [ :edit, :update, :destroy ]
  before_filter :add_crumbs
  before_filter :build_options, :only => [ :edit, :new, :create, :update ]
  add_breadcrumb "Categories", "admin_link_categories_path", :except => [ :index, :destroy ]
  add_breadcrumb "New Category", nil, :only => [ :new, :create ]
  
  def index
    @link_categories = LinkCategory.all
    add_breadcrumb "Categories", nil
  end

  def new
    @link_category = LinkCategory.new
  end

  def create
    @link_category = LinkCategory.new(params[:link_category])
    if @link_category.save
      flash[:notice] = "Category \"#{@link_category.title}\" created."
      redirect_to admin_link_categories_path
    else
      render :action => "new"
    end
  end

  def edit
    add_breadcrumb @link_category.title
  end

  def update
    add_breadcrumb @link_category.title
    if @link_category.update_attributes(params[:link_category])
      flash[:notice] = "Category \"#{@link_category.title}\" updated."
      redirect_to admin_link_categories_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @link_category.destroy
    respond_to :js
  end

  private


  def build_options(parent_id=nil)
    children = LinkCategory.all(:conditions => {:link_category_id => parent_id})
    @options_for_parent_id_level = @options_for_parent_id_level + 1
    unless children.empty?
      for child in children
        nbsp_string = '&nbsp;' * (@options_for_parent_id_level * @options_for_parent_id_level) unless @options_for_parent_id_level == 1 
        if params[:id]
          @options_for_parent_id << ["#{nbsp_string}#{child.title}", child.id] unless child.id == ColumnSection.find(params[:id]).id
        else
          @options_for_parent_id << ["#{nbsp_string}#{child.title}", child.id] 
        end
        build_options(child.id)
      end
    end
    @options_for_parent_id_level = @options_for_parent_id_level - 1
  end


  def find_link_category
    @options_for_parent_id = [['Top level category','']]
    @options_for_parent_id_level = 0
    begin
      @link_category = LinkCategory.find(params[:id])
      
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Link category was not found. It may have been deleted."
      redirect_to admin_link_categories_path
    end
  end

  def authorization
    authorize(@permissions['link_categories'], "Link Categories")
  end
  def add_crumbs
    add_breadcrumb @cms_config['site_settings']['links_title'], "admin_links_path"
  end
end

