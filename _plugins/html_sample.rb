require 'imgkit'
require 'RMagick'
include Magick

module Jekyll
  class HTMLSample < InlineAsset

    def generate(contents, retina_level=nil)
        contents += "<style>body { font-size: 50%; }</style>" #normalized font size
        # :transparent => true, 
        kit = IMGKit.new(contents, :height => nil, :width => 1000, :quality => 100)
        kit.stylesheets << 'css/_css-reset.css' # TODO: get path from somewhere
        img = kit.to_img(:png)

        cropped_img = Magick::Image.from_blob(img).first
        cropped_img.trim!

        return cropped_img.to_blob
    end

    def filename(context_id, instance_id)
        "htmlsample_#{context_id}_#{instance_id}.png"
    end

    def output_format(filepath, metadata=nil)
        # TODO: escape
        metadata_html = (metadata ? "<figcaption>#{metadata}</figcaption>" : "")
        "<p><div class='image_with_caption htmlasset'><figure><img src='#{filepath}' />#{metadata_html}</figure></div></p>"
    end
  end
end

Liquid::Template.register_tag('htmlasset', Jekyll::HTMLSample)