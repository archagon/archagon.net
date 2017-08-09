module Jekyll
    class Document
        def store_selector_id
            self.data['selector_id'] = self.selector_id
        end

        def selector_id
            return_id = id.urlize({:downcase => true, :convert_spaces => true})
            return_id = "sel_" + return_id
            return return_id
        end
    end
end