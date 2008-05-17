module Merb
  module EntriesHelper

    def to_html(entry)
      html_escape "<a href=\"#{host_url(entry.image.url(:original))}\">\n" +
                  "  <img src=\"#{host_url(entry.image.url(:thumb))}\" alt=\"#{entry.image.original_filename}\" />\n" +
                  "</a>"
    end
    
    def to_lightbox(entry)
      html_escape "<a href=\"#{host_url(entry.image.url(:original))}\" rel=\"lightbox\" title=\"#{entry.image.original_filename}\">\n" +
                  "  <img src=\"#{host_url(entry.image.url(:thumb))}\" alt=\"#{entry.image.original_filename}\" />\n" +
                  "</a>"
    end
    
    def to_bbcode(entry)
      "[url=#{host_url(entry.image.url(:original))}]\n" +
      "  [img]#{host_url(entry.image.url(:thumb))}[/img]\n" +
      "[/url]"
    end
    
    def host_url(path)
      request.protocol + request.host + path
    end
    
    def dimensions(style)
      geoms ||= {}
      geoms[style] ||= Paperclip::Geometry.parse(style)
      puts ".#{geoms[style].width.class}."
      geoms[style]
    end
  end
end
