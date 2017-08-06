---
layout: post
title: "MX Master Continued: Mouse Latency Measurements"
date: 2017-05-24 21:55:52 -0700
comments: true
categories: reviews
---

In the course of doing latency testing for [my previous article][masterarticle] on the Logitech MX series, I discovered a few aberrations in my helper app, and I also didn't have very many sample points to go on. So I decided to create a more sturdy testing setup and run a full suite of tests on all three of my mice in several different scenarios. Hopefully, these results will help illuminate the state of Logitech wireless mice as well as the difference between G-series and regular wireless performance.

As an side, I also ran a few tests in [microe's MouseTester][mousetester] to compare the motion graphs of the three mice, but they looked pretty much the same to my eye. So I think the difference in feel of these mice is mostly on account of latency and, to a lesser degree, the weight and shape.

## Data

<div class="image-gallery">
<h1>MX 518</h1>
<div class="image-gallery-two-column">
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mx518-left.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mx518-right.png" /></div>
</div>
</div>

<div class="image-gallery">
<h1>G602</h1>
<div class="image-gallery-two-column">
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/g602-left.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/g602-left-2.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/g602-right.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/g602-right-2.png" /></div>
</div>
</div>

<div class="image-gallery">
<h1>MX Master</h1>
<div class="image-gallery-two-column">
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-left.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-left-extended.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-left-charging.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-right.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-right-2.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-right-extended.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-right-charged.png" /></div>
<div style="max-width: 40rem"><img src="{{ site.baseurl }}/images/mx-master/charts/mxmaster-bluetooth.png" /></div>
</div>
</div>

## Conclusions

First, a word on the testing method. Since last time, my helper app has been revised to explicitly update the left label every frame instead of whenever-AppKit-feels-like-it. I've also switched from VLC to QuickTime as the latter allows you to step backwards frame-by-frame as well as forwards. (Extremely useful if you happen to overshoot the mouse movement point.) Combined with a Numbers spreadsheet for processing, the sampling procedure takes maybe a minute or two per data point. I thought about ways to automate the whole thing, but I imagine calibrating the motion detection algorithm to only capture the mouse and not the box would be a pain.

In every test, the cursor begins moving two screen frames ahead of the right label, so there's on the order of two frames of extra latency (~33ms) in these measurements. Subtracting this amount from the recorded values will get you closer to the absolute latency of the mice. But again, if you're only comparing these numbers to each other (which I am) then the extra latency doesn't really matter. You might as well just subtract the latency for the wired mouse since that's as close as you're going to get to zero.

I ended up testing both USB ports on my Macbook because I've had USB peripherals behave differently depending on which side they used. Not sure if the resulting variance is due to the ports themselves (power issues?) or simply reception.

OK, on to the results!

As the wired "control", the MX 518 showed 33ms of average latency with the left USB port and 38ms with the right. Theoretically, none of the other results should have surpassed this value — though the G602 stood a slight chance with its higher 500Hz polling rate.

During its worst run, with the adaptor plugged in to the left USB port, the MX Master had 62ms of average latency, or 30ms more than the wired MX 518. However, every subsequent run resulted in significantly better average values. Two more tests with the left USB port — one using a USB extender and one while simultaneously charging — gave me a better average of 54ms for both. And with the right port, things got better still, with two runs sporting an average of 45ms (including dips down to the thirties) and the other two responding at a respectable 47ms and 49ms on average.

With Bluetooth, the Master responded at an average of 65ms. So my conclusion in the original article was overly optimistic: there can be up to 20ms difference between Bluetooth and the USB adaptor.

During its first trial, the G602 reported with an astounding 34ms of latency — just 1ms more than wired! However, every subsequent run (including one with the very same setup as the first) only gave me 50ms on average.

So what can we deduce from these results?

The main issue with the Unifying receiver seems to be that the latency is rather inconsistent and spiky. With the G602, regardless of whether it's averaging 35ms or 50ms, the latency curve is always baby-butt smooth. In contrast, the Unifying receiver needs to be pampered to get optimal performance.

It seems that a variety of very minute factors can drastically affect the latency of these mice, ranging from adaptor placement to USB port selection. (For certain definitions of "drastically"... I mean, this is 20ms we're talking about.) The G602 might have a lower baseline than the MX Master, but the Master can still come within a respectable 10ms of that baseline. And in any case, it seems the G602 can't be guaranteed to perform in this range. I wish I knew what caused the G602 to spike up to 50ms for all its subsequent trials!

The first sample point in several MX Master tests was much higher than the rest. (A few are omitted since they're not representative of the average running latency.) I assume this is the result of some energy-saving feature. Doesn't really matter for games since you're constantly moving the mouse anyway.

The battery level in the MX Master doesn't seem to have much of an effect on performance.

From now on, I think I will use the right USB port along with an extender when gaming. Might do one more test when my powered USB hub arrives to see if some extra juice would speed things along even more.

Speaking anecdotally, the MX Master feels slightly laggier in FPS than the G602, which in turn feels slower than the MX 518. (Take this with a grain of salt since this kind of eyeball testing is very susceptible to the placebo effect. Also, the G602 can't precisely match the MX Master's 1600 DPI as it only snaps to 1500 DPI or 1750 DPI.) Nevertheless, games like CS:GO are still perfectly playable with all three models. I'd probably pick the G602 or MX 518 for more competitive play, but the MX Master is no slouch.

I wish there was a way to consistently improve wireless performance of the Master (a 5GHz mode would be great) but my recommendation still stands. The [MX Master][master] is an excellent mouse that performs well in practically any situation!

[masterarticle]: /2017/05/22/finnicky-notes-on-the-mx-master-and-anywhere-2/
[mx518]: http://amzn.to/2qbhqeY
[g602]: http://amzn.to/2rb0idv
[master]: http://amzn.to/2qbiPSM
[mousetester]: http://www.overclock.net/t/1535687/mousetester-software