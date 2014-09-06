module Jekyll
    class DateCalculatorTag < Liquid::Tag
        def initialize(tag_name, text, tokens)
            super

            params = text.split(" ")

            if params.count != 3
                puts "ERROR: invalid number of parameters in #{self.class.name}"
                return
            end

            if params[0] == "sub"
                @operator = params[0]
            else
                puts "ERROR: invalid param \"#{params[0]}\" in #{self.class.name}"
                return
            end

            @arg1 = params[1]
            @arg2 = params[2]
        end

        def render(context)
            if @operator
                if !context[@arg1] || !context[@arg2]
                    puts "ERROR: invalid Liquid variable in #{self.class.name}"
                    return ""
                end

                begin
                    date1 = DateTime.iso8601(context[@arg1])
                    date2 = DateTime.iso8601(context[@arg2])
                rescue
                    puts "ERROR: invalid date"
                    return ""
                end

                if @operator == "sub"
                    return "#{(date1 - date2).to_i + 1}"
                end
            else
                return ""
            end
        end
    end
end

Liquid::Template.register_tag('date_calculator', Jekyll::DateCalculatorTag)