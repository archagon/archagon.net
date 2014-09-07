---
layout: post
title: "Design of a Trip Widget"
date: 2014-08-28 14:28:22 +0100
comments: true
categories: jekyll
trip: "us-2013"
city: "toronto"
---
# Jekyll: Design of a Trip Widget

    TODO: each item links to either cateogry or to the solo post (INTERNET)
        TODO: separate city category (INTERNET)
    TODO: disabled look (INTERNET)
    TODO: template variables? (INTERNET)
    TODO: trip widget tag
    TODO: circle around current item in jquery
    TODO: autoanchor headers

I have just completed a little HTML widget for tracking my travels. Behold!

<p>
{% if page.trip and page.city %}
    {% assign timeline-template-trips = site.data.trips | where:"id", page.trip %}
    {% assign timeline-template-city = page.city %}
    {% include timeline-template.html %}
{% endif %}
</p>

I've only marginally dabbled in HTML and CSS before, so I'm quite proud of this little thing. And it's actually a whole lot more interesting than it looks.

## HTML/CSS

First of all, if you look at the raw HTML, you'll notice that it's nothing fancy — just a bunch of nested lists. In other words, almost everything is semantic. I didn't want `div` soup if I could help it.

The main HTML/CSS challenges here were, **a)** to display all the cities horizontally and continuously despite them being in different city lists, **b)** have the cities wrap across lines even if they're in the middle of a country list, and **c)** have a colored highlight around each city list, including across line breaks.

All my research pointed to `display: inline` being the only way for text to naturally wrap across lines, so I had to set that property on all my city list `ul` elements. (This also solved the problem of them flowing horizontally instead of vertically.) The actual city `li`s, however, were marked up as `display: inline-block`, so that I could adjust the height and appearance freely.

My initial design caused me a bit of a problem with feature c), that being colored borders around all the country lists. Since my lists were `inline`, their height automatically collapsed to height 0. This meant that setting the background color and padding on the list didn't have the desired effect in regards to the colored highlight:



<!--<style>
    div {
        display: inline-block;
        width: 400px;   
    }
    ul {
        display: inline;
        padding: 25px;
        background-color: yellow;
    }
    li {
        display: inline-block;
        background-color: salmon;
        height: 20px;
        padding: 10px;
    }
</style>

<div>
    <ul>
        <li>Alabama</li>
        <li>Alaska</li>
        <li>Arizona</li>
        <li>Arkansas</li>
    </ul>
</div>-->



I could sort of work around this problem by increasing the padding until it overlapped the top and bottom of each cell, but this required a ton of manual adjustment and variables (including for things like line height) and didn't even work consistently across browsers.

So instead I went for the "stupid, but works" approach. I moved the CSS that defined each city cell out of its `li` and into an inner `span`. Then, I gave each `li` margins of 0 and the highlight stylings that used to be in the list itself. Finally, the first and last `li` (using `last-item` and `nth-item`) were given border radii only on the corners facing out. This scheme gave the *appearance* of one continuous colored highlight applied to the list, but was actually a fake highlight applied to all the individual `li`s. I couldn't quite get `word-spacing` and `line-height` to work with this, but setting `padding-left`/`padding-right` and `margin-top`/`margin-bottom` worked perfectly fine for that purpose.

This technique inadvertedly solved another ornery problem I was having. After thinking about the best way to designate the country for each list without having lots of intrusive text, I settled on a subtle 2-letter country code at the start of each list. Before I added the extra `span` to solve the highlight problem, I was using a `before` pseudo-element on the list to add those letters. This worked fine, but it behaved like another `li`, which meant that the first city cell could wrap to the next line and leave the country code dangling behind:

~~~example 2~~~

However, with the extra `span` in each `li` now containing the actual city cell styling information, I could move the country code to the `before` pseudo-element on the first `li` of each country list. Since the country code now belonged to the `li` and not the list, it wrapped together with the fist cell.

I was seeing another minor problem: there were little slivers of whitespace between all my cells! This was obvious whenever the first element was wrapped:

~~~example 3~~~

I learned after doing a bit of research that setting list elements to `inline-block` suddenly made the whitespace (and newlines!) between them relevant. StackOverflow provided a number of hacky solutions, including writing all your HTML like this:

    <ul
        ><li>This</li
        ><li>hurts</li
        ><li>my</li
        ><li>head.</li
    ></ul>

Ultimately, I decided on a better solution: simply use a Liquid filter to automatically strip and remove newlines from the sections in which this matters. Note that this isn't the same as an overall minification step: since the whitespace becomes relevant in this situation, an explicit strip Liquid tag is important to get the correct meaning across.

## SASS

The next trick is leveraging the power of SASS. In case you don't know, SASS is a CSS preprocessor that lets you do things like save variables, do math, nest selectors, use macros, and many other powerful features. It makes potentially complicated and repetitive CSS very easy to maintain.

Here's a good example of the power of SASS. If you look at the CSS for the city widget, you'll see that each country class has its own set of colors for the background, text, and border. Figuring out these colors manually and typing them all out would have been an unmaintainable mess. By using SASS, I can codify the relationship between each set of colors:

    @mixin sublist-style($country-class, $country-name, $color) {
        // sub-list cells; also includes non-list cells for blank call
        #{$country-class} li > span {
            color: darken($color, 40%);
            background-color: lighten($color, 15%);
            border-color: darken($color, 30%);
        }
        // days font color
        #{$country-class} .days {
            color: darken($color, 15%);
        }
        // sub-list background
        #{$country-class}.sub-list > ul > li {
            background-color: $color;
        }
        // sub-list cell header
        #{$country-class}.sub-list li:nth-child(1)::before {
            color: darken($color, 20%);

            @if not $country-name {
                display: none;
            }
            @else {
                content: $country-name;
            }
        }
    }
    @include sublist-style("", none, gray);
    @include sublist-style(".united-states", "US", lightblue);
    @include sublist-style(".canada", "CA", #77DD77);
    @include sublist-style(".united-kingdom", "UK", #FFB347);
    @include sublist-style(".spain", "ES", #F49AC2);
    @include sublist-style(".france", "FR", #CB99C9);

All the colors are automatically generated from a base color that I provide. The "mixin" (macro) does the rest, including setting the country code text!

SASS also allows me to very easily do things like limit the scope of all my CSS to the timeline widget, add variables to the top of the file for easier tweaking, add mixins to style all header elements simultaneously, and set relationships between different values by using math. It's easy and intuitive and it makes me sad that it's not part of the official CSS spec!

{% divify code-source %}

You can find [the full SASS file here][sass].

[sass]: https://github.com/archagon/archagon.net/blob/master/_sass/_timeline-map.scss

{% enddivify %}

## Templating & Data

I was initially writing the HTML for the widget by hand, but now that I was using templating anyway, it made sense to switch to templates fully. After all, even bare-bones HTML makes it hard to read and edit the actual data. (It's the whole reason Markdown is around!)

Here's the final trick, and probably the most interesting one. Using the power of Jekyll, I am able to store my data in a simple JSON file and use the powerful Liquid templating engine to automatically generate each trip section based on the data.

One final note: the dates in my trip JSON file are stored as ISO 2-letter country codes. Since I needed the full country name for certain things (selectors, for example), I added an additional JSON data file that maps 2-letter country codes to the full country name.

templates

With these components in place, all I now have to worry about is updating my JSON file. When I do, every page that includes this widget will update automatically! I also have the freedom to add any additional metadata I wish — hostels, weather, star ranking, anything I wish — and only have to worry about changing one little template.

I think this is fundamentally what keeps me so interested in programming: getting to a point in your project where you can basically move mountains with just one little change in a text file.




The original goal for this widget was not to sit on a single standalone page, but to embed (possibly in parts) in my travel-related blog posts. With something like Wordpress, this would be impossible without a bunch of custom plugins. But with Jekyll's powerful static stack, I can edit a single item in my well-ordered JSON file and have my HTML update automatically for every single post and page. Now *that's* the power of static blogging!

{% divify code-source %}

You can find the [templated HTML file here][template] and the [trip JSON file here][data].

[template]: https://github.com/archagon/archagon.net/blob/master/_includes/timeline-template.html
[data]: https://github.com/archagon/archagon.net/blob/master/_data/trips.json

{% enddivify %}

## Conclusion

I realized over the course of this widget's construction that I was pulling more and more features from Jekyll. This made me happy: I wasn't 100% on static blogging before this experiment, but now I see now that Jekyll is almost perfectly suited for extensible, data-driven blogging. With relative ease, I can inject completely custom content into my blog posts that nevertheless has a centralized source of truth somewhere in my code. No need for updating multiple blog posts manually. No need for a Javascript crutch. Once I type `jekyll build`, my site has a fully-working snapshot that can be uploaded anywhere and doesn't require any server-side dependencies aside from Apache.

If this post seems overly verbose, I'm sorry. I only hope that it might help clarify why a platform like Jekyll is so exciting, and how you can build up an interesting project from bare HTML/CSS all the way to a robust, extensible, data-driven widget that can be used throughout your site.

{% divify code-source %}

As a bit of a meta addendum, check out the pieces coming together in [the Markdown for this blog post here][markdown]!

[markdown]: https://github.com/archagon/archagon.net/blob/master/_posts/2014-08-28-design-of-a-trip-widget.md

{% enddivify %}

<style>

hr {
    display:block;
    border:0px;
    height: 15px;
    margin: 40px 0 40px 0;
    background-position: center;
    background-repeat: no-repeat;
    background-image:url("/images/Decoration.svg");
}

</style>

---

<div class="new_jekyll_assets" markdown="1">

# Jekyll assets created over the course of this exercise

* [<span class="asset-name">filterize.rb</span>][filterize] — A Liquid block tag that applies filters to a block of text. Makes doing things like `scssify` easier — no more `capture` boilerplate.
* [<span class="asset-name">whitespace_compressor.rb</span>][whitespace_compressor] — A filter that cuts out newlines and whitespace around each line.
* [<span class="asset-name">date_calculator.rb</span>][date_calculator] — A Liquid tag that does basic math (currently just subtraction) with ~~ISO~~ dates.
* [<span class="asset-name">normalize.rb</span>][normalize] — A filter that hooks into a slightly modified [extend-string.rb</span>][extend-string] in order to normalize text. (Remove accents, replace spaces, retain only basic letters and numbers.)
* [<span class="asset-name">divify.rb</span>][divify] — A Liquid block tag that wraps the containing text in a div with the provided classes. (To make this box!)
* [<span class="asset-name">html_sample.rb</span>][html_sample] — A Liquid block tag that renders out the given HTML into a PNG.

[filterize]: https://github.com/archagon/archagon.net/blob/master/_plugins/filterize.rb
[whitespace_compressor]: https://github.com/archagon/archagon.net/blob/master/_plugins/whitespace_compressor_filter.rb
[date_calculator]: https://github.com/archagon/archagon.net/blob/master/_plugins/date_calculator.rb
[normalize]: https://github.com/archagon/archagon.net/blob/master/_plugins/normalize_filter.rb
[extend-string]: https://github.com/archagon/archagon.net/blob/master/_plugins/extend_string.rb
[divify]: https://github.com/archagon/archagon.net/blob/master/_plugins/divify.rb
[html_sample]: http://google.com

</div>