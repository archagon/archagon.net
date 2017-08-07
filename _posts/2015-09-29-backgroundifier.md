---
layout: post
title: "Backgroundifier"
date: 2015-09-29 17:36:37 -0700
comments: true
categories: releases
---

I made a Mac app! It's called [Backgroundifier](http://backgroundifier.archagon.net), and it turns any image into a desktop background. (But it's better for fine art and illustration.)

<!--more-->

You can pass an image like this...

<img src="{{ site.baseurl }}/images/bgify-1.jpg" class="content" width="400px" />

...through the droplet...

<img src="{{ site.baseurl }}/images/bgify-2.png" class="content" width="600px" />

...to get something like this:

<img src="{{ site.baseurl }}/images/bgify-3.jpg" class="content" width="400px" />

I collect lots of art from websites like [/r/imaginarycityscapes](https://www.reddit.com/r/ImaginaryCityscapes) and artist blogs. Unfortunately, there never seems to be enough time in the day to actually sit down and look through it all. As a result, it mostly sits and gathers dust in a directory in my Dropbox — not a great place for art to be.

So I've been thinking of ways to get it in front of my eyes. On a Mac, the desktop background seemed like the perfect place to put it, especially since OSX natively supports randomly rotating your desktop background from a directory of images. Unfortunately, since all my art was in different sizes and aspect ratios, it looked ugly with the default letterbox color that OSX added to compensate.

After seeing the visual design of [tomkinstinch's Artful app](https://news.ycombinator.com/item?id=8723120), I realized that images could be framed more cleverly. By processing the image instead of using a solid color, you could create a background that hinted at contents of the image while still being subdued enough to serve as a backdrop. But Artful didn't support local files; it pulled its art from the web. Furthermore, like many Mac users, I'm a proponent of keeping things close to the defaults. What I wanted was a basic utility that could simply input my images and output the backgrounds, allowing the OS do the background rotation for me. No need to keep any apps open; no compatibility issues; nothing but a basic command line utility with a bit of GUI attached.

So that's what I made. In addition to the GUI, the app actually supports command line mode. If you Terminal into the MacOS directory inside the package, you can run the Backgroundifier executable straight from the command line. (On my machine, I've even set up an Automator script to watch my input image directory and automatically convert any new arrivals.) Unfortunately, due to sandboxing restrictions, you can only read and write to the ~/Pictures directory unless you use the GUI... but check in the Resources directory in the bundle and you might find something a bit more robust!

This was mostly a small side project for me, but I couldn't help but implement a few bits of UI bling. One is the animation of the droplet:

<img src="{{ site.baseurl }}/images/bgify-demo2.gif" />

(That shadow looks better when it's not in a gif!)

Unfortunately, doing this on OSX is a bit more tricky than on iOS. Whereas in UIKit, you can access (and transform!) each view's layer without any issues, this is disabled by default in AppKit. And even if you do enable layer-backed views, transforming them is not officially allowed. One of the reasons UIKit feels so good is because layers are supported on the most fundamental level; I hope that we get a similar framework update for OSX sometime in the near future. Visually, the current tech stack feels like it's stuck in the 90's.

[The app is mostly open source](https://github.com/archagon/backgroundifier-public). I've decided to not release my one user interface nib file for now, but everything else is up for grabs. It's written in Swift 2. (The repo is a bit out of date, but I hope to commit my latest changes in the near future.)