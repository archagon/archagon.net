module Jekyll
  class Divify < Liquid::Block

    def initialize(tag_name, text, tokens)
        super
      
        @filters = []

        for filter in text.split("|")
            @filters.push(filter.strip)
        end
    end

    def render(context)
        output = ""
        output += "<p>"
        output += "<div class=\""
        for filter in @filters
            output += "#{filter} "
        end
        output += "\">"

        site = context.registers[:site]
        converter = site.getConverterImpl(::Jekyll::Converters::Markdown)
        converted = converter.convert(super(context))
        output += converted

        # TODO: remove outer <p>

        output += "</div>"
        output += "</p>"
        output

        # TODO: is this the right way to do this?
        # Liquid::Template.parse(output).render(context)
    end
  end
end

Liquid::Template.register_tag('divify', Jekyll::Divify)