class Generator < Jekyll::Generator
    def generate(site)
        image_dir = site.config['image_dir'] || 'images'

        for post in site.posts
            if site.config['default_icon']
                post.data['icon_url'] = File.join("/", image_dir, site.config['default_icon'])
                post.data['using_default_icon'] = true
            end

            if post.data['icon']
                icon_url = post.data['icon']
                icon_url = icon_url[1..icon_url.length] # TODO: better way to do this?

                if File.file? icon_url
                    icon_extension = File.extname(icon_url)
                    
                    file = File.join(image_dir, post.selector_id)
                    file += icon_extension # TODO: better way to do this?
                
                    FileUtils::copy(icon_url, file)
                    post.data['icon_url'] = File.join("/", file)
                    post.data['using_default_icon'] = false
                end
            end
        end
    end
end