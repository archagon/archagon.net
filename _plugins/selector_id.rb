module Jekyll
    class Post
        def store_selector_id
            self.data['selector_id'] = self.selector_id
        end

        def selector_id
            selector_id = id.gsub! "/", "_" # TODO: might need more
            selector_id = "sel_" + selector_id
            return selector_id
        end
    end
end