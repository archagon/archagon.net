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
        # alias_method :old_transform, :transform
        # def transform
        #     old_transform_output = old_transform
        #     return old_transform_output
        # end

        alias_method :old_render_all_layouts, :render_all_layouts
        def render_all_layouts(layouts, payload, info)
            HTMLProcessor.analyze_pre_render(self)
            old_render_all_layouts_output = old_render_all_layouts(layouts, payload, info)
            HTMLProcessor.analyze_post_render(self)
            return old_render_all_layouts_output
        end
    end
end

module Jekyll
    module HTMLProcessor
        def self.is_valid_to_analyze?(post)
            # no Excerpt, because it's only used for includes
            return post.is_a?(Post) || (post.is_a?(Page) && post.ext != ".xml")
        end

        def self.analyze_pre_render(post)
            self.analyze(post, true)
        end

        def self.analyze_post_render(post)
            self.analyze(post, false)
        end

        def self.analyze(post, pre)
            if self.is_valid_to_analyze?(post)
                nokogiri_html = Nokogiri::HTML(post.output)

                if pre
                    self.pre_render_callback(post, nokogiri_html)
                else
                    self.post_render_callback(post, nokogiri_html)
                end

                post.output = nokogiri_html.to_html
            end
        end

        def self.pre_render_callback(post, nokogiri_html)
            # puts "analyzing pre for #{post.name}.#{post.ext}"
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

        def self.post_render_callback(post, nokogiri_html)
        end
    end
end

# # any issues with steps after transform?
# module Jekyll
#     module Converters
#         class HTMLPostProcessor < Converter
#             # ensures we get the output HTML
#             priority :lowest

#             def matches(ext)
#                 # borrowed from Markdown converter
#                 markdown_rgx = '^\.(' + @config['markdown_ext'].gsub(',','|') +')$'
#                 markdown_check = (ext =~ Regexp.new(markdown_rgx, Regexp::IGNORECASE))
#                 html_check = (ext == ".html")
#                 return (markdown_check) || (html_check)
#             end

#             def output_ext(ext)
#                 ".html"
#             end

#             def post_process(nokogiri_html)
#                 nokogiri_html.xpath("//img").each do |img|
#                     # img.replace("<p>NOT AN IMAGE!</p>")
#                     img.replace "<style>.border{background-color:red;}</style><div class='border'>#{img}test</div>"
#                 end
#             end

#             def convert(content)
#                 html = Nokogiri::HTML(content)
#                 post_process(html)
#                 content = html.to_html
#             end
#         end
#     end
# end

# module Jekyll
#     class Excerpt
#         alias_method :old_output_ext, :output_ext
#         def output_ext
#             rval = old_output_ext
#             puts "old excerpt output ext: #{rval}"
#             return rval
#         end
#     end
# end

# module Jekyll
#     class Converter
        
#         alias_method :old_output_ext, :output_ext
#         def output_ext(ext)
#             old_output = old_output_ext(ext)
#             if old_output == ".html"
#                 puts "post-processing!"
#             end
#             return old_output
#         end

        # def post_process(nokogiri_html)
        #     nokogiri_html.xpath("//img").each do |img|
        #         # img.replace("<p>NOT AN IMAGE!</p>")
        #         img.replace "<style>.border{background-color:red;}</style><div class='border'>#{img}test</div>"
        #     end
        # end

        # def convert(content)
        #     html = Nokogiri::HTML(content)
        #     post_process(html)
        #     content = html.to_html
        # end
#     end
# end

# module Jekyll
#     module Converters
#         class ImageCaptionAdder < HTMLPostProcessor
#             def post_process(nokogiri_html)
#                 nokogiri_html.xpath("//img").each do |img|
#                     img.replace("<p>NOT AN IMAGE!</p>")
#                 end
#             end
#         end
#     end
# end
