---
layout: post
title: "E-book PDFs from a buncha scans: easier than you might think!"
date: 2013-06-09
categories: programming
redirect_from:
  - /a-few-pointless-thoughts/2013/6/9/e-book-pdfs-from-a-buncha-scans-easier-than-you-might-think
---

<img src="https://static1.squarespace.com/static/51b3f330e4b062dc340fa8fd/t/51be6219e4b020693fe234d6/1371431449877/iTextImage.png?format=750w" />

I've been doing some serious hardcore scanning lately, and now I'd like to enjoy the fruits of my labor on my iPad. What to do? Obviously, reading image by image is a crappy option. A typical e-book format like .epub might be OK, but in its current incarnation it's really more optimized for text than image-heavy content. So PDF is clearly the way to go. (Well, I suppose you could also use a comic book format like .cbr and .cbz, but there's no way your average reader would be able to use it.)

And how exactly does one create a PDF? If you're starting from scratch, you might use something like Adobe Acrobat. But this isn't really a good choice for lumping a bunch of images together, since it costs $$$ and also applies all sorts of nasty behind-the-scenes transformations that you probably don't want. Ideal would be a simple tool that lets you combine images, one or two per page, at their native resolution, with no additional compression. And it should require as little fiddling as possible.

Fortunately, there are PDF frameworks out there that can be controlled entirely through code. I've done some looking, and it seems that [iText](http://itextpdf.com) for Java is really the gold standard. (I'd prefer to use a scripting language, but setting up IntelliJ and adding the framework is hardly a hassle. The whole thing took me about 20 minutes to install and fully configure, though I admittedly already had Java installed.)

<!--more-->

And here's what my thrown-together project looks like. It takes a bunch of scanned images in a directory and spits out a beautiful, perfect PDF, with the option of having two pages side-by-side.

<noscript><p><em>To see this Gist, please use a browser that supports Javascript.</em></p></noscript>
<script src="https://gist.github.com/archagon/5748013.js"></script>

(For a more complex example with zine scanning functionality — 2 pages per scan — take a look at [this Gist](https://gist.github.com/archagon/5737603). You might have to adjust the filename functions to better suit your workflow. This code is provided for educational purposes only!)

A couple of fun facts I learned about PDFs from this project: 

* An Image object can be rendered multiple times without changing the size of the PDF. This indicates to me that PDFs have an asset store, where each asset can be rendered as many times as needed.
* iText loads JPEGs way faster than PNGs. This implies that PDF supports JPEG natively, but not PNG. I don't know if PNGs get uncompressed, converted to another lossless format, or what.
* (Of course, all this may be nonsense! I haven't exactly done my research.)

I've used this with great success to scan and digitize a bunch of yearbooks and zines. It's great to have a solution that gets you from point A to point B in the simplest possible way!

A huge thanks to Chris Haas on SuperUser for [putting me on the right track](http://superuser.com/questions/331233/authoring-pdf-files-by-hand).