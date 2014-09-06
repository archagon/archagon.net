# Reduces the input to simple ASCII letters and numbers. Spaces are replaced with the given
# character (if provided). Accents are removed.

# require 'extend_string'

module Jekyll
    module NormalizeFilter
        def normalize(input, args = nil)
            input.urlize({:downcase => true, :convert_spaces => (args ? args : false)})
        end
    end
end

Liquid::Template.register_filter(Jekyll::NormalizeFilter)