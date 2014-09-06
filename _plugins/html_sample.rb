require 'imgkit'

module Jekyll
  class HTMLSample < Liquid::Block

    def initialize(tag_name, text, tokens)
        super
    end

    def render(context)
        html = super(context)

        kit = IMGKit.new(html, "enable-smart-width" => true, :width => nil, :height => nil)
        # kit.stylesheets << '/path/to/css/file'

        img = kit.to_img(:png)

        file = kit.to_file('images/test_html.png')

        "<img src='images/test_html.png'>"

        # IMGKit.new("hello").to_png
    end
  end
end

Liquid::Template.register_tag('htmlsample', Jekyll::HTMLSample)