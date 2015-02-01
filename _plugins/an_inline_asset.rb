# TODO: avoid re-generation unless explicitly requested
# TODO: rename???

module Jekyll
  class InlineAsset < Liquid::Block

    def filename(context_id, instance_id)
        # override me!
    end

    def output_format(filepath, metadata=nil)
        # override me!
    end

    def asset_path(config)
        "generated/"
        # TODO: assets, recursive dir
    end

    def generate(contents, retina_level=nil)
        # override me!
    end

    #######################################################
    # DON'T TOUCH THESE UNLESS YOU KNOW WHAT YOU'RE DOING #
    #######################################################

    @@generated = {}

    def initialize(tag_name, text, tokens)
        if !text.empty?
            text = text.strip
            text = text[1...-1]
            @caption = text
        end

        @contents = tokens[0]

        super

        token_count = 0
        for token in tokens
            token_count += token.scan("end#{tag_name}").length
        end
        @instance_id = token_count
    end

    def render(context)
        site = context.registers[:site]
        page = context.registers[:page]

        # preliminary sanity check
        should_proceed = (page['selector_id'] != nil)

        if should_proceed
            filename = filename(page['selector_id'], @instance_id)
            return _create_asset(site.config, filename)
        end

        # TODO: use normalized permalinks everywhere for id
        puts "WARNING: could not generate #{self.class.to_string} for id"
        return super(context)
    end

    # for use in links
    def _site_path(config, filename)
        "#{config['baseurl']}/#{asset_path(config)}#{filename}"
    end

    # for use in the script
    def _local_path(config, filename)
        # TODO: move directly to _site?
        "#{asset_path(config)}#{filename}"
    end

    def _needs_update?(local_path)
        if !@@generated[local_path]
            return true
        else
            return false
        end
    end

    def _create_asset(config, filename)
        local_path = _local_path(config, filename)
        site_path = _site_path(config, filename)

        if File.exists?(local_path)
            puts "WARNING: file #{filename} already exists"
            if _needs_update?(local_path)
                _generate_asset(local_path, site_path)
            end
            return output_format(site_path, @caption)
        else
            _generate_asset(local_path, site_path)
            return output_format(site_path, @caption)
        end

        return ""
    end

    def _generate_asset(local_path, site_path)
        puts "STATUS: generating #{local_path}"

        generated = generate(@contents)
        File.open(local_path, 'w') do |asset|
            asset.puts generated
        end

        @@generated[local_path] = true
    end
  end
end