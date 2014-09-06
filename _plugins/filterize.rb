# TODO: site.getConverterImpl(::Jekyll::Converters::Markdown)

# Processes a block with the given Liquid filters.

module Jekyll
  class Filterize < Liquid::Block

    def initialize(tag_name, text, tokens)
        super
      
        @filters = []

        for filter in text.split("|")
            @filters.push(filter.strip)
        end
    end

    def render(context)
        output = ""
        output += "{% capture test %}"
        output += super(context)
        output += "{% endcapture %}"
        output += "{{ test"
        for filter in @filters
            output += " | #{filter}"
        end
        output += " }}"

        # TODO: is this the right way to do this?
        Liquid::Template.parse(output).render(context)
    end
  end
end

Liquid::Template.register_tag('filterize', Jekyll::Filterize)