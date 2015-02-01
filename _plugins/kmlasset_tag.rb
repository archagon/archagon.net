module Jekyll
    class KMLAssetTag < Liquid::Tag
        include Filters

        def initialize(tag_name, text, tokens)
            super
            @asset_name = text.strip
        end

        def render(context)
            site = context.registers[:site]
            page = context.registers[:page]
            assets_dir = site.config['assets_dir']
            selector_id = page['selector_id']
            normalized_name = @asset_name.urlize({:downcase => true, :convert_spaces => true})
            escaped_name = uri_escape(@asset_name) # TODO: is this the correct filter?
            asset_url = "#{site.config['url']}#{site.config['baseurl']}/#{assets_dir}/kml/#{escaped_name}"
            id = "google-map-#{selector_id}-#{normalized_name}"

"<p>
<style type='text/css'>
    ##{id} { width: 100%; height: 400px; margin: 0; padding: 0;}
</style>
<script type='text/javascript'
    src='https://maps.googleapis.com/maps/api/js?key=AIzaSyCVe3O2OawYpG6wixMFLsdbmnLBsJgSuNA'>
</script>
<script type='text/javascript'>
    function initialize() {
        var fullPath = '#{asset_url}'
        var mapOptions = {
            // center: { lat: 54.966667, lng: -1.6 },
            // zoom: 14,
            // mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById('#{id}'),
            mapOptions);
        var kmzLayer = new google.maps.KmlLayer(fullPath);
        kmzLayer.setMap(map);
    }
    google.maps.event.addDomListener(window, 'load', initialize);
</script>
<div id='#{id}'></div>
<noscript></noscript>
</p>"
        end
    end
end

Liquid::Template.register_tag('kmlasset', Jekyll::KMLAssetTag)
