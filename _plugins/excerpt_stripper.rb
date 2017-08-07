# thanks, http://penguindreams.org/blog/removing-footnotes-from-excerpts-in-jekyll/
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

            doc.inner_html
        end
    end
end

Liquid::Template.register_filter(Jekyll::ExcerptStripper)
