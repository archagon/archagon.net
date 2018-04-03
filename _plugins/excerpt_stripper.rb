# thanks, http://penguindreams.org/blog/removing-footnotes-from-excerpts-in-jekyll/
# TODO: extend document and excerpt to customize behavior: 
#     * https://github.com/jekyll/jekyll/blob/e45997fb5b0454c129211a24f8b4428b1f16fc5d/lib/jekyll/document.rb#L502
#     * https://github.com/jekyll/jekyll/blob/bc2c0c4f80e34b78ed1d83b05710e770ffccf728/lib/jekyll/excerpt.rb
# TODO: data-driven filter
require 'nokogiri'

module Jekyll
    module ExcerptStripper
        def strip_footnotes(raw)
            doc = Nokogiri::HTML.fragment(raw.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => ''))

            for block in ['div', 'sup', 'a'] do
                doc.css(block).each do |ele|
                    if ele['class']
                        classes = ele['class'].split(" ")
                        
                        ele.remove if (
                            classes.include? 'footnotes' or
                            classes.include? 'footnote' or
                            classes.include? 'toc' or
                            classes.include? 'notification'
                        )
                    end
                end
            end

            for block in ['style'] do
                doc.css(block).each do |ele|
                    ele.remove
                end
            end

            doc.inner_html
        end
    end
end

Liquid::Template.register_filter(Jekyll::ExcerptStripper)
