---
layout: post
title: "A Trip Down the Jekyll Rabbit Hole: Design of a Trip Widget"
date: 2014-08-28 14:28:22 +0100
comments: true
categories: jekyll
---
I have just completed a little HTML widget for tracking my travels. Behold!

    TODO: rsscutoff

<p>
{% assign timeline-template-trips = site.data.trips | where: "id", "europe-2014" %}
{% include timeline-template.html %}
</p>

(Do try changing the width of the page.)

I've only marginally dabbled in HTML and CSS before, so I'm quite proud of this little thing. And it's actually a whole lot more interesting than it looks.

## [HTML/CSS](#id)

First of all, if you look at the raw HTML, you'll notice that it's nothing fancy — just a bunch of nested lists. In other words, almost everything is semantic. I didn't want `div` soup if I could help it.

The main HTML/CSS challenges here were, **a)** to display all the cities horizontally and continuously despite them being in different city lists, **b)** have the cities wrap across lines even if they're in the middle of a country list (i.e. be in the document text flow), and **c)** have a colored highlight around each city list, including across line breaks.

All my research pointed to `display: inline` being the only way for text to naturally wrap across lines, so I had to set that property on all my city list `ul`s. (This also solved the problem of making them flowing horizontally.) The actual city `li`s, however, were marked up as `display: inline-block`, so that I could adjust the height and appearance freely.

My initial design caused me a bit of a problem with the colored borders around all the country lists. Since my lists were `inline`, their height automatically collapsed to height 0. This meant that setting the background color and padding on the list didn't have the desired effect in regards to the colored highlight:

{% htmlasset %}

    <style>
        div {
            display: inline-block;
        }
        ul {
            padding: 0;
            margin: 0;
            text-align: center;
            vertical-align: middle;
            display: inline;
            padding: 0.5em;
            border-radius: 0.5em;

            background-color: #77dd77;
        }
        li {
            height: 2em;
            display: inline-block;
            text-align: center;
            vertical-align: middle;
            list-style-type: none;
            padding-left: 1em;
            padding-right: 1em;
            border-radius: 0.4em;
            font-size: 2em;
            font-family: Tahoma, Geneva, sans-serif;
            line-height: 2em;
            margin-left: 0.25em;
            margin-right: 0.25em;

            color: #1b6d1b;
            background-color: #b4ecb4;
        }
    </style>
    
    <div>
        <ul>
            <li>Alabama</li>
            <li>Alaska</li>
            <li>Arizona</li>
            <li>Arkansas</li>
        </ul>
    </div>

{% endhtmlasset %}

I could sort of work around this problem by increasing the padding until it overlapped the top and bottom of each cell, but this required a ton of manual adjustment and variables (including for things like line height) and didn't even work consistently across browsers.

So instead I went for the "stupid, but works" approach. I moved the CSS that defined each city cell out of its `li` and into an inner `span`. Then, I gave each `li` margins of 0 and the highlight stylings that used to be in the list itself. Finally, the first and last `li` (using `last-item` and `nth-item`) were given border radii only on the corners facing out. This scheme gave the *appearance* of one continuous colored highlight applied to the list, but was actually a fake highlight applied to all the individual `li`s. I couldn't quite get `word-spacing` and `line-height` to work with this, but setting `padding-left`/`padding-right` and `margin-top`/`margin-bottom` worked perfectly fine for that purpose.

{% htmlasset "The construction of the list with the margins blown up for demonstration purposes." %}

    <style>
        div {
            display: inline-block;
        }
        ul {
            padding: 0;
            margin: 0;
            text-align: center;
            vertical-align: middle;
            display: inline;
            <!-- padding: 0.5em; -->
            <!-- border-radius: 0.5em;             -->
        }
        li {
            display: inline-block;
            <!-- height: 4em; -->
            text-align: center;
            vertical-align: middle;
            list-style-type: none;
            
            margin: 0;
            padding: 0.5em;

            background-color: #77dd77;
        }
        li:nth-child(1) {
            border-top-left-radius: 0.5em;
            border-bottom-left-radius: 0.5em;
        }
        li:last-child {
            border-top-right-radius: 0.5em;
            border-bottom-right-radius: 0.5em;
        }
        li > span {
            height: 2em;
            display: inline-block;
            padding-left: 1em;
            padding-right: 1em;
            border-radius: 0.4em;
            font-size: 2em;
            font-family: Tahoma, Geneva, sans-serif;
            line-height: 2em;
            margin-left: 0.25em;
            margin-right: 0.25em;

            color: #1b6d1b;
            background-color: #b4ecb4;
        }
    </style>

    <div>
        <ul>
            <li><span>Alabama</span></li>
            <li><span>Alaska</span></li>
            <li><span>Arizona</span></li>
            <li><span>Arkansas</span></li>
        </ul>
    </div>

{% endhtmlasset %}

This technique inadvertedly solved another ornery problem I was having. After thinking about the best way to designate the country for each list without having lots of intrusive text, I settled on a subtle 2-letter country code at the start of each list. Before I added the extra `span` to solve the highlight problem, I was using a `before` pseudo-element on the list to add those letters. This worked fine, but it behaved like another `li`, which meant that the first city cell could wrap to the next line and leave the country code dangling behind.

However, with the extra `span` in each `li` now containing the actual city cell styling information, I could move the country code to the `before` pseudo-element on the first `li` of each country list. Since the country code now belonged to the `li` and not the list, it wrapped together with the fist cell.

I was seeing another minor problem: there were little slivers of whitespace between all my cells, just like in the example above. I learned after doing a bit of research that setting list elements to `inline-block` suddenly made the whitespace (and newlines!) between them relevant. StackOverflow provided a number of hacky solutions, including writing all your HTML like this:

{% highlight html %}

<ul
    ><li>This</li
    ><li>hurts</li
    ><li>my</li
    ><li>head.</li
></ul>

{% endhighlight %}

Ultimately, I decided on a better solution: simply use a Liquid filter to automatically strip and remove newlines from the sections in which this matters. Note that this isn't the same as an overall minification step: since the whitespace becomes relevant in this situation, an explicit strip Liquid tag is important to get the correct meaning across.

## SASS

The next trick is leveraging the power of SASS. In case you don't know, SASS is a CSS preprocessor that lets you do things like save variables, do math, nest selectors, use macros, and many other powerful features. It makes potentially complicated and repetitive CSS very easy to maintain.

Here's a good example of the power of SASS. If you look at the CSS for the city widget, you'll see that each country class has its own set of colors for the background, text, and border. Figuring out these colors manually and typing them all out would have been an unmaintainable mess. By using SASS, I can codify the relationship between each set of colors:

{% highlight sass %}

@mixin sublist-style($country-class, $color) {
    // sub-list cells; also includes non-list cells for blank call
    #{$country-class} li > span {
        color: darken($color, 40%);
        background-color: lighten($color, 15%);
        // background-color: mix($color, white, 50%);
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
        display: none;
    }
    #{$country-class}.sub-list li > span > a {
        background-color: lighten($color, 20%);
    }
}
@include sublist-style("", gray);
@include sublist-style(".united-states", lightblue);
@include sublist-style(".canada", #77DD77);
@include sublist-style(".united-kingdom", #FFB347);
@include sublist-style(".spain", #F49AC2);
@include sublist-style(".france", #CB99C9);

{% endhighlight %}

All the colors are automatically generated from a base color that I provide. The "mixin" (macro) does the rest!

SASS also allows me to very easily do things like limit the scope of all my CSS to the timeline widget, add variables to the top of the file for easier tweaking, add mixins to style all header elements simultaneously, and set relationships between different values by using math. It's easy and intuitive and it makes me sad that it's not part of the official CSS spec!

<p><div class="code-source" markdown="1">

You can find [the full SASS file here][sass].

[sass]: https://github.com/archagon/archagon.net/blob/master/_sass/_timeline-map.scss

</div></p>

## Templating & Data

Here's the final trick, and probably the most interesting one. Initially, I was writing out all my data in raw HTML, by hand. But this ultimately seemed inelegant. Using the power of Jekyll, I was able to move my data to a simple JSON file and then use Jekyll's built-in Liquid templating engine to automatically generate each trip section.

So now a trip starts out looking like this:

{% highlight json %}

"name": "To The Moon",
"id": "moon-1917",
"places": [
    {
        "name": "Moon",
        "country": "US",
        "date-start": "2013-8-12",
        "date-end": "2013-8-20"
    }
]

{% endhighlight %}

And gets turned into HTML that looks like this (with newlines and whitespace re-added for clarity):

{% highlight html %}

<section>
    <h2>To The Moon</h2>
    <ul>
        <li class="sub-list united-states">
            <h3>United States</h3>
            <ul>
                <li><span>Moon&nbsp;<span class="days">2</span></li>
            </ul>
        </li>
    </ul>
</section>

{% endhighlight %}

(If you're curious about how "US" gets turned into "united-states", I have an additional data file mapping country codes to countries.)

With this change, everything in my widget is decoupled. I can make a small addition to my trip JSON and have the change propagate to every instance of the widget throughout my entire site. I can change the HTML without changing the data. I can modify the CSS without affecting the markup. If I decide to add a new data field to my trip JSON at a later time, I don't have to manually edit a bunch of HTML files by hand.

I think this is fundamentally what keeps me so interested in programming: getting to a point in your project where you can basically move mountains with just one little change in a text file!

<p><div class="code-source" markdown="1">

You can find the [templated HTML file here][template] and the [trip JSON file here][data].

[template]: https://github.com/archagon/archagon.net/blob/master/_includes/timeline-template.html
[data]: https://github.com/archagon/archagon.net/blob/master/_data/trips.json

</div></p>

## Conclusion

I realized over the course of this widget's construction that I was pulling more and more features from Jekyll. This made me happy: I wasn't 100% on static blogging before this experiment, but now I see now that Jekyll is almost perfectly suited for extensible, data-driven blogging. With relative ease, I can inject completely custom content into my blog posts that has a centralized source of truth somewhere in my code. No need for updating multiple blog posts manually. No need for a Javascript crutch. Once I type `jekyll build`, my site has a fully-working snapshot (literally — when using Git!) that can be uploaded anywhere and doesn't require any server-side dependencies aside from Apache.

With something like Wordpress, this would be impossible without a bunch of custom plugins; and even worse, the implementation details of all the gem, software, and plugin version numbers would be forever tied to your site. It would be a living project, not a finished product. Personally, I can never curb my anxiety with running a server. It's much nicer to just throw a bunch of HTML files on my subdomain and not have to worry about it.

If this post seems overly verbose, I'm sorry. I only hope that it might help clarify why a platform like Jekyll is so exciting, and how you can build up an interesting project from bare HTML/CSS all the way to a robust, extensible, data-driven widget that can be used throughout your site.

<p><div class="code-source" markdown="1">

As a bit of a meta addendum, this Markdown post is a test bed for a bunch of custom plugins I've been writing. Check out [the Markdown for this blog post here][markdown]!

[markdown]: https://raw.githubusercontent.com/archagon/archagon.net/master/_posts/2014-08-28-design-of-a-trip-widget.md

</div></p>

---

<div class="new-jekyll-assets" markdown="1">

# Jekyll assets created over the course of this exercise

* [<span class="asset-name">filterize.rb</span>][filterize] — A Liquid block tag that applies filters to a block of text. Makes doing things like `scssify` easier — no more `capture` boilerplate.
* [<span class="asset-name">whitespace_compressor.rb</span>][whitespace_compressor] — A filter that cuts out newlines and whitespace around each line.
* [<span class="asset-name">date_calculator.rb</span>][date_calculator] — A Liquid tag that does basic math (currently just subtraction) with ~~ISO~~ dates.
* [<span class="asset-name">normalize.rb</span>][normalize] — A filter that hooks into a slightly modified [extend-string.rb][extend-string] in order to normalize text. (Remove accents, replace spaces, retain only basic letters and numbers.)
* [<span class="asset-name">divify.rb</span>][divify] — A Liquid block tag that wraps the containing text in a div with the provided classes. (Not necessary since I discovered that you could add `markdown="1"` to `div`s in some Markdown processors in order to continue parsing inside HTML, but still potentially useful.)
* [<span class="asset-name">inline_asset.rb</span>][html_sample] — A Liquid block class that generates inline assets. Avoids asset regeneration unless necessary. Useful for inline rendering of things like HTML examples, Lilypond markup, and so much more.
* [<span class="asset-name">html_sample.rb</span>][html_sample] — An inline asset that renders out the given HTML into a PNG.

[filterize]: https://github.com/archagon/archagon.net/blob/master/_plugins/filterize.rb
[whitespace_compressor]: https://github.com/archagon/archagon.net/blob/master/_plugins/whitespace_compressor_filter.rb
[date_calculator]: https://github.com/archagon/archagon.net/blob/master/_plugins/date_calculator.rb
[normalize]: https://github.com/archagon/archagon.net/blob/master/_plugins/normalize_filter.rb
[extend-string]: https://github.com/archagon/archagon.net/blob/master/_plugins/extend_string.rb
[divify]: https://github.com/archagon/archagon.net/blob/master/_plugins/divify.rb
[html_sample]: http://google.com

</div>