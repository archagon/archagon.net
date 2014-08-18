module Jekyll
    class Post
        def selector_id
            selector_id = id.gsub! "/", "_" # TODO: might need more

            # remove '_' from beginning of id
            while true
                if selector_id[0] == '_'
                    selector_id = selector_id[1..id.length]
                else
                    break
                end
            end
            
            return selector_id
        end
    end
end