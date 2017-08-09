require 'RMagick'
include Magick

class Generator < Jekyll::Generator
    def generate(site)
        baseurl = site.config['baseurl']
        image_dir = site.config['image_dir'] || 'images'

        for post in site.posts.docs
            post.store_selector_id() # TODO: this definitely does not belong here

            if site.config['default_icon']
                post.data['icon_url'] = File.join(baseurl, image_dir, site.config['default_icon'])
                post.data['using_default_icon'] = true
            end

            if post.data['icon']
                local_icon_url = File.join(image_dir, post.data['icon'])

                # if File.file? local_icon_url
                #     # get output filename
                #     icon_extension = File.extname(local_icon_url)
                #     new_icon_name = post.selector_id + icon_extension
                #     local_new_icon_url = File.join(image_dir, new_icon_name)

                #     FileUtils::copy(local_icon_url, local_new_icon_url)

                #     # image processing
                #     icon_image = Image.read(local_new_icon_url).first
                #     # icon_image = Image.new file
                #     icon_image = icon_image.scale(0.5)
                #     icon_image.write(local_new_icon_url)

                #     # data update
                #     post.data['icon_url'] = File.join(baseurl, image_dir, new_icon_name)
                #     post.data['icon_width'] = icon_image.page.width
                #     post.data['icon_height'] = icon_image.page.height
                #     post.data['using_default_icon'] = false
                # end
            end
        end
    end
end