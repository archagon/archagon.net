---
layout: post
title: "The Mad Power of Jekyll"
date: 2014-08-18 14:22:13 +0100
comments: true
categories: 
---
# The ACTUAL Mad Power of Jekyll

## Asset Management

What really pushed me to give static blog gnereators a try was the ease of asset management. There are many assets in blogs that we don't think about: background images, charts, icons. In many cases, we process these files in some externa program outside our blog and then render them to .png for use with the blog itself. This means that if anything ever changes in our data, we have to find our tools again, repeat the process, and update the page with the correct data.

But what if we didn't have to do that?

With Jekyll, by leveraging Ruby scripting, we can automate this processing. Let's say that each of our posts has a designated header image from which we want to extract an icon — used in the archive page, for example.

The benefit here is flexibility. What if we want to experiment with different icon shapes? What if we want to scale them? Add a filter? With just a few lines of Ruby script, we can recreate every image in just a few seconds and completely redo our site.