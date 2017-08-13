---
layout: post
title: "iPad Pro + Pencil Slow Motion Bug"
date: 2015-12-05 16:50:30 -0800
comments: true
categories: programming
redirect_from:
  - /2015/12/05/ipad-pro-plus-pencil-slow-motion-bug/
---
I noticed an interesting problem with the Apple Pencil while developing my app. It seems that if you're using the Pencil while simultaneously using a gesture recognizer (as, for instance, in a scroll view), touch processing goes into slow motion. (Approximately half-speed, according to some quick measurements.) Seems there's some sort of interference between Pencil and gesture event processing. Notably, the framerate remains stable while this is happening.

<!--more-->

<p><div class="youtube_16_9"><iframe src="https://www.youtube.com/embed/ioPRiHBj8l4?showinfo=0&rel=0" frameborder="0" allowfullscreen></iframe></div></p>

I noticed that the Paper app also has this problem. Other drawing apps seem to avoid it (accidentally or intentionally) by disabling canvas navigation while drawing. In Procreate, you can adjust the brush sliders while drawing without any slow motion, but I think this has to do with the fact that Procreate uses a custom OpenGL-based implementation for their widgets, not UIGestureRecognizer.

I can reproduce this bug in Apple's TouchCanvas demo by sticking a scroll view to the left of the screen and continuously scrolling it while drawing. At first, it behaves correctly. But when the CPU usage hits a high enough level, you get the behavior described above. If you do the drawing with your finger, the problem disappears. The framerate does drop, but the touches don't continue when you lift your finger; they simply get delivered with less frequency, and the scroll view stops scrolling immediately once you lift your finger.

My hunch is that the sampling frequency of the Pencil messes up the usual touch handling behavior when under load. That would explain the 2x factor: the Pencil has a 240Hz refresh rate while touches normally get sampled at 120Hz.

Regardless of whether this is an iOS bug or something I messed up on my end, I'd love to know if there's a way to fix this! Simultaneously scrolling with your hand while drawing with the Pencil should be a given.