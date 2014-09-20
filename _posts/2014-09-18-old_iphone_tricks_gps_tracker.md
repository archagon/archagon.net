---
layout: post
title: "Old iPhone Tricks: GPS Tracker"
date: 2014-09-18 17:28:45 +0200
comments: true
categories: []
---
This is the time of year when a lot of people are upgrading their phones. If you're a traveler and are considering selling off your old hardware, perhaps this trick will make you reconsider!

Here's a thing you might not know about your iPhone[^whynotandroid]: the GPS unit works even without a data connection. I was confused for a long time about how exactly "assisted GPS" works; my understanding was that it was impossible for the phone to figure out the location of a GPS satellite without a data connection, but as it turns out, it simply takes a lot longer.

So here's what I do with my old iPhone 4. Whenever I set out for a walk, I load up an app called myTracks and start recording. Then I chuck the phone in my bag and forget about it. At the end of the day, I retrieve my phone — more often than not, with plenty of charge remaining — and stop the recording. Finally, I can export this data as a `kml` file and put it up somewhere like Google Maps:

{% kmlasset newcastle_test.kml %}

(Incidentally, setting this viewer up was surprisingly easy. First, I exported the `kml` data from the app — in this case, EasyTrailsLT, which I'm also trying out. Next, I went and got a Google Maps Javascript API key. Finally, I wrote a quick Jekyll Liquid tag to replace `kmlasset` tags with a bit of boilerplate Javascript code calling Google Maps with the `kml` file URL. End result: drop my `kml` in a folder, add a tag, and have the map show up magically in my blog post. More on the power of Jekyll in later posts!)

Most of the GPS apps I've looked at still support iOS5, so your phone doesn't even have to be a recent model! I'd still be able to use my 3GS for this purpose if the battery was up to snuff.

It's hard to remember to do this every day, but with a bit more dilligence, I can create a map of everywhere I've walked to in the world!

[^whynotandroid]: Since I only have Apple hardware at the moment, I have no idea if this also applies to Android. Sorry!

---

<div class="new_jekyll_assets" markdown="1">

# Jekyll assets created over the course of this exercise

* [<span class="asset-name">kmlasset_tag.rb</span>][kmlasset] — A Liquid tag that feeds a `kml` file url into a Google Maps applet.

[kmlasset]: https://github.com/archagon/archagon.net/blob/master/_plugins/filterize.rb

</div>