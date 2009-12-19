resources :link_categories, :as => links_path do |link_category|
  link_category.resources :links, :as => link_path, :member => { :comment => :post }, :has_many => :images
end
resources :links, :as => link_path, :member => { :comment => :post }, :has_many => :images

namespace :admin do |admin|
  admin.resources :link_categories
  admin.resources :links, :has_many => :features, :collection => { :reorder => :put } do |link|
    link.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put }
  end
end