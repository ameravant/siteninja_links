xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@cms_config['website']['name'])
    xml.link(links_url(:format => :rss))
    # xml.description("")
    xml.language('en-us')

    for link in @links
      xml.item do
        xml.title(h(link.title))
        xml.category(h(link.link_category.title))
        unless link.images.empty?
          image = link.images.first
          "#{link_to(image_tag(image.small_featured), link_url(link))}</br>#{h(link.blurb)}"
        else
          xml.description(h(link.blurb))
        end
        xml.pubDate(link.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link(link_url(link))
        xml.guid(link_url(link))
      end
    end
  }
}
