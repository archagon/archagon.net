# Elminiates newlines and strips whitespace around lines.
# To be used for syntactic things like removing whitespace between inline-block elements.
# For general minificaiton, you'll be better off using another solution.

module Jekyll
    module WhitespaceCompressorFilter
        def compress(input)
            output = ""
            for line in input.each_line
                output += line.strip
            end
            output
        end
    end
end

Liquid::Template.register_filter(Jekyll::WhitespaceCompressorFilter)