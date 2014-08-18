require 'RMagick'
include Magick

class Generator < Jekyll::Generator
    def generate(site)
        image_dir = site.config['image_dir'] || 'images'

        for post in site.posts
            post.store_selector_id() # TODO: this definitely does not belong here

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

                    icon_image = Image.read(file).first
                    # icon_image = Image.new file
                    icon_image = icon_image.scale(0.5)
                    icon_image.write(file)

                    post.data['icon_url'] = File.join("/", file)
                    post.data['icon_width'] = icon_image.page.width
                    post.data['icon_height'] = icon_image.page.height
                    post.data['using_default_icon'] = false
                end
            end
        end
    end
end