require 'nokogiri'

# Goal here: process HTML after generation in order to do cool things like automatic <img> caption
# generation and auto-titling. This may be a TOTALLY BORKED way to do this, but it's a start.

# What to convert? Any pages, any posts — basically, anything that ends up as HTML.

# IF CONTENT IS PROCESSED, post excerpts will be processed TWICE when included in pages
# IF OUTPUT IS PROCESSED... excerpts in non-html documents won't be correct, INCLUDING ON INDEX PAGE???
# OUTPUT seems more correct
# EXCERPTS... must not be rendered???

# anytime post.content or post.excerpt is used, it either needs
    # to be processed, AND the outside page not processed, or
    # not to be processed, AND the outside page processed

module Jekyll
    module Convertible
        alias_method :old_read_yaml, :read_yaml
        def read_yaml(base, name, opts = {})
            old_read_yaml(base, name, opts)
            if self.data['title']
                self.data['title'] = 'replaced'
            end
        end

        # alias_method :old_transform, :transform
        # def transform
        #     old_transform_output = old_transform
        #     return old_transform_output
        # end

        alias_method :old_do_layout, :do_layout
        def do_layout(payload, layouts)
            old_do_layout(payload, layouts)
            if !place_in_layout?
                puts "no place in layout for #{self.name}, #{self.class.name}"
                do_html_preprocessing
            end
        end

        alias_method :old_render_all_layouts, :render_all_layouts
        def render_all_layouts(layouts, payload, info)
            do_html_preprocessing # place_in_layout? == true
            old_render_all_layouts_output = old_render_all_layouts(layouts, payload, info)
            return old_render_all_layouts_output
        end

        # this has to be called before layouts are rendered
        def do_html_preprocessing
            TitleFinder.analyze_pre_render(self)
            ImageCaptionAdder.analyze_pre_render(self)
        end
    end
end

module Jekyll
    class HTMLProcessor
        def self.is_valid_to_analyze?(post)
            # no Excerpt, because it's only used for includes TODO: why?
            for converter in post.converters
                if converter.output_ext(nil) == ".html"
                    return true
                end
            end
            return false
        end

        def self.analyze_pre_render(post)
            self.analyze(post, true)
        end

        def self.analyze(post, pre)
            if self.is_valid_to_analyze?(post)
                nokogiri_html = Nokogiri::HTML(post.output)
                self.pre_render_callback(post, nokogiri_html)
                post.output = nokogiri_html.to_html
            end
        end

        def self.pre_render_callback(post, nokogiri_html)
        end
    end
end

module Jekyll
    class TitleFinder < HTMLProcessor
        def self.pre_render_callback(post, nokogiri_html)
            nokogiri_html.xpath("//h1").each do |img|
                # post.data['title'] = "replaced"
            end
        end
    end
end

module Jekyll
    class ImageCaptionAdder < HTMLProcessor
        def self.pre_render_callback(post, nokogiri_html)
            nokogiri_html.xpath("//img").each do |img|
                css = "<style>.border
                        {
                            border-style: solid;
                            border-width: 5px;
                            padding: 10px;
                        }
                        .caption {
                            background-color: blue;
                            margin: 4px;
                        }
                        </style>"
                div = "<div class='border'>#{img}<span class='caption'>caption goes here</span></div>"
                img.replace "#{css}#{div}"
            end
        end
    end
end