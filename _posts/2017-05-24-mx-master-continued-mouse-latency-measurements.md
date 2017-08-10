---
layout: post
title: "MX Master Continued: Mouse Latency Measurements"
date: 2017-05-24 21:55:52 -0700
comments: true
categories: reviews
---

In the course of doing latency testing for [my previous article][masterarticle] on the Logitech MX Master, I discovered a couple of flaws in my helper app, and I also realized that I should have probably recorded a few more sample points. So now, as a followup, I have devised a better testing methodology and run a full suite of tests. Unfortunately, with this new data in hand, I must now retract my original recommendation. The Master is still a good mouse for the average user, but its wireless performance is just too unreliable for precise gaming or Bluetooth use. 

If you're looking for a great all-arounder, I would instead give my highest recommendation to the [G403 Wireless][g403], which I've been happily using for several months with zero issues. While this mouse does require a dongle and only has a tenth of the Master's battery life, its best-in-class performance, non-existent latency, svelte form factor, and incredible clicky side buttons more than make up for these downsides. Better yet, you can routinely find it on sale for $50 or lower on Amazon and at Best Buy. I'll try to post a fuller account sometime in the near future.

In the meantime, here are the new test results for the MX Master, G602, and MX 518.

<!--more-->

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

Note: I also ran a few tests in [microe's MouseTester][mousetester] to compare the motion graphs of the three mice, but they looked pretty much the same to my eye. So I think the difference in feel of these mice is mostly due to latency and, to a lesser degree, weight and shape.

## Results

Since last time, my helper app has been revised to explicitly update the left label every frame instead of implicitly relying on AppKit's timing. I've also switched my scrubbing program from VLC to QuickTime, as the latter additionally allows you to step backwards frame-by-frame. (Extremely useful if you happen to overshoot the mouse movement point!) Combined with a Numbers spreadsheet for processing, the sampling process took maybe a minute or two per data point.

In every test, the cursor begins moving two screen frames ahead of the right label, so there's on the order of two frames of extra latency (~33ms) in these measurements. Subtracting this amount from the recorded values will get you closer to the absolute latency of the mouse. But again, if you're only comparing these numbers to each other (which I am) then the extra latency doesn't really matter. You may as well just subtract the latency of the wired mouse since that's as close as you're going to get to zero.

I ended up testing both USB ports on my Macbook because I've had USB peripherals behave differently depending on which side they used. Not sure if the resulting variance is due to the ports themselves (power issues?) or simply reception.

OK, on to the results!

As the wired "control", the MX 518 showed 33ms of average latency with the left USB port and 38ms with the right. Theoretically, none of the other results should have surpassed this value — though the G602 stood a slight chance with its higher 500Hz polling rate.

During its worst run, with the adaptor plugged in to the left USB port, the MX Master had 62ms of average latency, or 30ms more than the wired MX 518. However, every subsequent run resulted in significantly quicker average values. Two more tests with the left USB port — one using a USB extender and one while simultaneously charging — gave me a better average of 54ms for both. And with the right port, things got better still, with two runs sporting an average of 45ms (including dips down to the thirties) and the other two responding at a respectable 47ms and 49ms on average.

With Bluetooth, the Master responded at an average of 65ms. So my conclusion in the original article was overly optimistic: there can be up to 20ms difference between Bluetooth and the USB adaptor.

During its first trial, the G602 reported with an astounding 34ms of latency — just 1ms more than wired! However, each subsequent run (including one with the very same setup as the first) only gave me 50ms on average.

What can we conclude from these results?

The main issue with the Unifying receiver seems to be that the latency is rather inconsistent and spiky. With the G602, regardless of whether it's averaging 35ms or 50ms, the latency curve is always baby-butt smooth. In contrast, the Unifying receiver needs to be pampered to attain optimal performance.

It seems that a variety of minute factors can drastically affect the latency of these mice, ranging from adaptor placement to USB port selection. The G602 might have a lower baseline than the MX Master, but the Master can still come within a respectable 10ms of that baseline. And in any case, it seems the G602 can't be guaranteed to perform in this range. I wish I knew what caused the G602 to spike up to 50ms for all its subsequent trials!

The first sample point in several of the MX Master runs was much higher than the rest. (A few are omitted since they're not representative of the average running latency.) I assume this is the result of some energy-saving feature. Doesn't really matter for games since you're constantly moving the mouse anyway.

The battery level in the MX Master doesn't seem to have much of an effect on performance.

## Conclusion

I spent another week with the MX Master in daily use, and unfortunately, I had to concede the results: the Master was noticeably 1-2 frames behind my other mice. Frankly, I was really surprised by how much this affected gameplay. With the MX Master in CS:GO and Overwatch, I always felt like I was a little drunk. My cursor would constantly overshoot and I would miss many of my flick shots. Hot-swapping the G602 brought an instant wave of relief: my sense of immersion immediately returned and I felt like I could aim almost twice as well. (Maybe this is what happens when you hammer your synapses with FPS gameplay over the course of two decades!) I tried to account for the placebo effect as best as I could without doing a completely blind test, but I could easily see my performance suffer even when running around and shooting bots in the Overwatch training area.

I followed up with a few more informal measurements, and all of them continued to show the MX Master trailing the G602 in performance — mostly on account of the lag spikes, but sometimes pretty drastically even on average. I also discovered that Bluetooth performance was quite unreliable on the Mac side, frequently dropping off or disconnecting altogether and requiring a hard mouse reset. Given that the Master was intended as an all-arounder for both gaming and Bluetooth use, this was a huge disappointment. It clearly wasn't up to snuff in either respect, and I decided to send it back.

As a last-ditch stop in my mousing hunt, I visited my local Best Buy to take a gander at Logitech's gaming mice. The lineup had all the problems I was expecting: tacky designs, an overabundance of buttons, horrible tilt-click scroll wheels... except for the lone [G403][g403]. As soon as I put this mouse in my hand, I knew it was the one. This was the only wireless gaming mouse that had just the five standard buttons in a classic body. Its scroll wheel was the normal kind, not the mushy tilt-wheel kind. Its internal hardware was the same as that of the possibly-best-in-class [G900][g900]. And most surprising of all, its side buttons were actually *clicky!* (I know it's such a small detail, but I hadn't used a new mouse with clicky side buttons in years.) Before me was a phenomenal gaming mouse in the guise of a business accessory, evocative of the classic Microsoft Intellimouse — and USB dongle or not, this was exactly the mix I was searching for. I took it home and haven't had a single complaint in the three months since. (Bonus: it fits snugly in my [MX Master Hermitshell case][case].)

The Master is 80% of the way to being an ideal all-arounder, but sadly, it's killed for power users by inconsistent performance.

[masterarticle]: {% post_url 2017-05-22-almost-winning-the-wireless-mouse-game-logitech-mx-master %}
[mx518]: http://amzn.to/2qbhqeY
[g602]: http://amzn.to/2rb0idv
[g403]: http://amzn.to/2uDAeF2
[g900]: http://amzn.to/2hHjvj4
[master]: http://amzn.to/2qbiPSM
[mousetester]: http://www.overclock.net/t/1535687/mousetester-software
[case]: http://amzn.to/2qJl3LO