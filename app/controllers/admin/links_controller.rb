class Admin::LinksController < AdminController
  unloadable # http://dev.rubyonrails.org/ticket/6001
  before_filter :authenticate
  before_filter :find_link, :only => [ :edit, :update, :destroy, :show ]
  before_filter :find_link_categories, :only => [ :new, :create, :edit, :update, :index ]

  def index
    if params[:q].blank?
      @links = Link.all.sort_by(&:position)
    else
      @links = Link.find(:all, :conditions => ["title like ?", "%#{params[:q]}%"])
    end
    add_breadcrumb @cms_config['site_settings']['links_title']
  end

  def show
    add_breadcrumb @cms_config['site_settings']['links_title'], admin_links_path
    @images = @link.images.find :all, :order => "position"
  end

  def new
    add_breadcrumb @cms_config['site_settings']['links_title'], admin_links_path
    add_breadcrumb "New"
    @link = Link.new
  end

  def edit
    add_breadcrumb @cms_config['site_settings']['links_title'], admin_links_path
    add_breadcrumb "Edit"
  end

  def create
    @link = Link.new(params[:link])
    if @link.save
      flash[:notice] = "Link \"#{@link.title}\" created."
      redirect_to admin_links_path
    else
      render :action => "new"
    end
  end

  def reorder
    params["tree_#{params[:link_category_id]}"].each_with_index do |id, position|
      Link.update(id, :position => position + 1)
    end
    render :nothing => true
  end

  def update
    if @link.update_attributes(params[:link])
      flash[:notice] = "Link \"#{@link.title}\" updated."
      redirect_to admin_links_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @link.destroy
    respond_to :js
  end

  private

  def find_link
    begin
      @link = Link.find(params[:id])
    rescue
      flash[:error] = "Link not found."
      redirect_to admin_links_path
    end
  end

  def find_link_categories
    @link_categories = LinkCategory.all
  end

  def authenticate
    unless current_user.has_role(["Admin"])
      flash[:error] = "You do not have access to manage Links."
      redirect_to(:back)
    end
  end

end

