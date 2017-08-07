---
layout: post
title: "Old iPhone Tricks: GPS Tracker"
date: 2014-09-18 17:28:45 +0200
comments: true
categories: ["technology", "travel"]
---
This is the time of year when a lot of people are upgrading their phones. If you are, don't chuck your old phone just yet!

Here's a thing you might not know about your iPhone[^WhyNotAndroid]: the GPS unit works even without a data connection. I was confused for a long time about what "assisted GPS" actually meant. My understanding was that it was impossible for an AGPS phone (which the iPhone is) to acquire a GPS signal without a data connection. Turns out it works fine — you just have to wait a bit longer for the phone to find a satellite.

<!--more-->

So here's what I do with my old iPhone 4. Whenever I set out for a walk, I load up an app called [myTracks][myTracks] and hit the Record button. Then I chuck the phone in my bag and forget about it. At the end of the day, I retrieve the phone — more often than not with plenty of charge remaining — and stop the recording. Finally, I can connect my phone to my computer and export this data as a `kml` file (among several others) to use with Google Maps:

{% kmlasset newcastle_test.kml %}

(Incidentally, setting this viewer up was surprisingly easy. First, I exported the `kml` data from the app — in this case, [EasyTrailsLT][EasyTrails], which I'm also trying out. Next, I went and got a [Google Maps Javascript API key][GoogleMapsSetup]. Finally, I wrote a quick Jekyll plugin to replace `kmlasset` tags with a bit of boilerplate Javascript code that calls Google Maps. End result: I can drop my `kml` in a folder, add a tag, and have the map show up magically in my blog post. This is just a small example of how Jekyll makes doing data-heavy blogging a lot more simple, which I'll delve into in later posts!)

Most of the GPS apps I've looked at still support iOS5, so your phone doesn't even have to be a recent model. I'd still use my 3GS for this purpose if the battery was up to snuff.

People always panic when Google or Apple slips up and caches a bit of your location data, but I feel the opposite. With an old iPhone and just a bit of dilligence, I can create a map of everywhere I've walked in the world!

[^WhyNotAndroid]: Since I only have Apple hardware at the moment, I have no idea if this also applies to Android. Sorry!

[myTracks]: http://itunes.apple.com/en/app/mytracks-the-gps-logger/id358697908?mt=8
[EasyTrails]: https://itunes.apple.com/us/app/easytrails-gps-lite/id325929832?mt=8
[GoogleMapsSetup]: https://developers.google.com/maps/documentation/javascript/tutorial

---

<div class="new-jekyll-assets" markdown="1">

# Jekyll assets created over the course of this exercise

* [<span class="asset-name">kmlasset_tag.rb</span>][kmlasset] — A Liquid tag that feeds a `kml` file url into a Google Maps applet.

[kmlasset]: https://github.com/archagon/archagon.net/blob/master/_plugins/kmlasset_tag.rb

</div>