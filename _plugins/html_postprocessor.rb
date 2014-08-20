require 'nokogiri'

# Goal here: process HTML after generation in order to do cool things like automatic <img> caption
# generation and auto-titling. This may be a TOTALLY BORKED way to do this, but it's a start.

# class HTMLPostProcessorInjector < Jekyll::Generator
#     def generate(site)
#         for post in site.posts
#             post.extend(Jekyll::HTMLPostProcessor)
#         end
#     end
# end

# module Jekyll
#     class HTMLPostProcessor
#         def render_liquid(content, payload, info, path = nil)
#             rendered_liquid = super(content, payload, info, path)

#             html = Nokogiri::HTML(rendered_liquid)
#             html.xpath("//img").each do |img|
#                 puts "found img"
#                 puts "img: #{img}"
#                 img.replace("<p>NOT AN IMAGE!</p>")
#             end

#             rendered_liquid = "<p>not it!</p>"
#             return "<p>not it!</p>"
#         end
#     end
# end

# module Jekyll
#     class Site
#         alias_method :old_render, :render
#         def render
#             puts "rendering lol"
#             # old_render
#         end
#     end
# end

# module Jekyll
#     class Renderer
#         # alias_method :old_convert, :convert
#         def self.convert(content)
#             puts "i'm a converter lol"
#             # puts "converting #{content}"
#             # old_convert(content)
#         end
#     end
# end

# module Jekyll
#     class Post
#         alias_method :old_excerpt, :excerpt
#         def excerpt
#             return_excerpt = old_excerpt
#             puts return_excerpt
#             return return_excerpt
#         end
#     end
# end

module Jekyll
    module Convertible
        # alias_method :old_write, :write
        # def write(dest)
        #     if is_a?(Post)
        #         html = Nokogiri::HTML(self.output)
        #         html.xpath("//img").each do |img|
        #             puts "found img"
        #             puts "img: #{img}"
        #             img.replace("<p>NOT AN IMAGE!</p>")
        #         end
        #         self.output = html.to_html
        #     end
        #     old_write(dest)
        # end

        # alias_method :old_transform, :transform
        # def transform
        #     return_value = old_transform
        #     if is_a?(Post) || is_a?(Excerpt)
        #         html = Nokogiri::HTML(return_value)
        #         html.xpath("//img").each do |img|
        #             puts "found img"
        #             puts "img: #{img}"
        #             img.replace("<p>NOT AN IMAGE!</p>")
        #         end
        #         return_value = html.to_html
        #     end
        #     return return_value
        # end

        alias_method :old_do_layout, :do_layout
        def do_layout(payload, layouts)
            old_do_layout(payload, layouts)
            # if is_a?(Post)
            #     puts self.content
            # end
            # if is_a?(Post)
            #     html = Nokogiri::HTML(self.content)
            #     html.xpath("//img").each do |img|
            #         puts "found img"
            #         puts "img: #{img}"
            #         img.replace("<p>NOT AN IMAGE!</p>")
            #     end
            #     self.content = html.to_html
            # end
        end
    end
end

module Jekyll
    module Convertible
        alias_method :old_transform, :transform
        def transform
            output = old_transform
            if is_a?(Post)
                analyzer = HTMLAnalyzer.new
                analyzer.analyze(self, output)
            end
            return output
        end
    end
end

module Jekyll
    class HTMLAnalyzer
        def analyze(post, html)
            html = Nokogiri::HTML(html)
            html.xpath("//h1").each do |img|
                puts "found header: #{img}"
                post.data['title'] = img.to_html
            end
        end
    end
end

# any issues with steps after transform?
module Jekyll
    module Converters
        class HTMLPostProcessor < Converter
            # ensures we get the output HTML
            priority :lowest

            def matches(ext)
                # borrowed from Markdown converter
                markdown_rgx = '^\.(' + @config['markdown_ext'].gsub(',','|') +')$'
                markdown_check = (ext =~ Regexp.new(markdown_rgx, Regexp::IGNORECASE))
                html_check = (ext == ".html")
                return (markdown_check) || (html_check)
            end

            def output_ext(ext)
                ".html"
            end

            def post_process(nokogiri_html)
                nokogiri_html.xpath("//img").each do |img|
                    img.replace("<p>NOT AN IMAGE!</p>")
                end
            end

            def convert(content)
                html = Nokogiri::HTML(content)
                post_process(html)
                content = html.to_html
            end
        end
    end
end

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

# basically, modify post.content before the time it's used in feed.xml and other liquid tags