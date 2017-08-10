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
    
    
    if params[:default_view]
      if params[:default_view] == "paginate"
        session[:link_index] = "paginate"
        @cms_config["site_settings"]["paginate_link_index"] = true
      elsif params[:default_view] == "categories"
        session[:link_index] = "categories"
        @cms_config["site_settings"]["paginate_link_index"] = false
      end
      flash[:notice] = "Default view updated successfully."
      File.open(@cms_path, 'w') { |f| YAML.dump(@cms_config, f) }
      redirect_to(admin_links_path)
    end
    if (@cms_config['site_settings']['paginate_link_index'] or params[:paginate_link_index] or session[:link_index] == "paginate") and (params[:paginate_link_index] != "false")
      session[:link_index] = "paginate"
      @paginate_link_index = true
      if params[:letter]
        links = Link.all(:conditions => ["title like ?", "#{params[:letter]}%"])
      else
        params[:q].blank? ? links = Link.all(:order => "title") : links = Link.find(:all, :conditions => ["title like ?", "%#{params[:q]}%"], :order => "title")
      end
      @links = links.paginate(:page => params[:page], :per_page => 20)
    elsif params[:paginate_link_index] == "false"
      session[:link_index] = "categories"
      @paginate_link_index = false
    end
  end

  def show
    add_breadcrumb @cms_config['site_settings']['links_title'], admin_links_path
    @images = @link.images.find :all, :order => "position"
  end

  def new
    add_breadcrumb @cms_config['site_settings']['links_title'], admin_links_path
    add_breadcrumb "New"
    @link = Link.new
    if params[:duplicate_id]
      @link = Link.find(params[:duplicate_id]).clone
      @link.title = "#{@link.title} (Copy)"
      @link.permalink = ""
    end
  end

  def edit
    add_breadcrumb @cms_config['site_settings']['links_title'], admin_links_path
    add_breadcrumb "Edit"
  end

  def create
    @link = Link.new(params[:link])
    params[:link][:link_category_ids] ||= []
    @link.link_categories << LinkCategory.find(params[:link][:link_category_id]) unless params[:link][:link_category_id].blank? 
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
    params[:link][:link_category_ids] ||= []
    params[:link][:link_category_ids] << @link.link_category_id unless @link.link_category_id.blank?
    if @link.update_attributes(params[:link])
      #This is to removes link from categories if there are none selected
      if !params[:link].has_key?("link_category_ids")
        @link.link_categories = []
        @link.save
      end
      ac_ids = @link.link_category_ids.uniq
      @link.link_category_ids = []
      @link.link_category_ids = ac_ids
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

