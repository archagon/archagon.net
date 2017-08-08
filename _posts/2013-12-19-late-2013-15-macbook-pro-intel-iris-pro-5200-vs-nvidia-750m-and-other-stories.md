---
layout: post
title: "Late 2013 15\" Macbook Pro: Intel Iris Pro 5200 vs. Nvidia 750m (And Other Stories)"
date: 2013-12-19
categories: technology
---

I recently got a [high-end 15" Macbook Pro](http://www.amazon.com/gp/product/B0096VD85I/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B0096VD85I&linkCode=as2&tag=arcwasher-20). The 13" model I was using before had served me with faith and dignity over the years, but as my appetite for high-performance apps increased, the poor guy just couldn't keep up like it used to. In the past, I would have only considered upgrading to another 13" laptop, but a lot has changed over the years. Computers have slimmed down. I've slimmed up. A 15" device just didn't seem like the back-breaking monster it used to be.

The other big factor in my decision was graphics performance. Among all the Macbooks currently available, the high-end 15" Macbook Pro is the only one with a discrete graphics chip still inside. You get access to an integrated Intel Iris Pro 5200 for everyday use, but the OS can also switch you over to a powerful Nvidia 750m when the polygons have to fly. 

At first, I naturally assumed that the 750m would kick the 5200's butt; this was a separate ~40w component, after all. But as I started to dig through forum posts and benchmarks for my research, I discovered that while the Iris Pro usually lagged behind the 750m by 15%-50%, there were a few recorded instances where it matched or even surpassed the Nvidia chip! Some people blamed this on drivers, others on architecture. Were the numbers even accurate? I wanted to find out for myself.

There were a couple of specific questions I was looking to answer during my testing:

* How good is the maximum graphics performance of this machine?
* How does the Iris Pro 5200 compare to the 750m?
* How does Windows 7 VM (Parallels) graphics performance compare to native Windows 7 (Bootcamp)?

<!--more-->

## 3DMark

For my first set of benchmarks, I configured a Parallels VM to run off my Bootcamp partition with the following settings: 4 logical processors (which I think gives you 2 physical cores), 12GB RAM, 1GB video memory, DirectX 10, and 1440×900 resolution. (I also ran a test with 2 logical processors, which caused performance issues, and also with 8 logical processors, which caused my system to seriously freeze up.) I then installed the [3DMark demo](http://store.steampowered.com/app/223850/) on Steam and ran the default suite of tests. Finally, I turned off the VM, changed the energy setting from "Better performance" to "Longer battery life" in order to make the VM use integrated graphics (verified with [gfxCardStatus](http://gfx.io)), and ran the same tests again.

(Oh, before I give you my results, I should mention that none of these tests are scientifically rigorous. I tried to be as accurate as possible, but I'm no [Anand Shimpi](http://www.anandtech.com). Also, even though the results of my VM tests were consistent with everything else I tried, I'm not sure how much the numbers were skewed given that they were running through Parallels' DirectX to OpenGL layer.)

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>3DMark Vantage in Windows VM</caption>

<col class="ch" />
<col span="3" class="data" />

<tbody>

<tr class="rh">
<td class="corner"></td>
<th>Integrated</th>
<th>Discrete</th>
<th>Discrete Performance Over Integrated</th>
</tr>

<tr>
<th class="th1">Ice Storm</th>
<td>52223</td>
<td>60862</td>
<td class="bitbetter">116.5%</td>
</tr>

<tr>
<th class="th2">Graphics</th>
<td>55459</td>
<td>69401</td>
<td class="lotbetter">125.1%</td>
</tr>

<tr>
<th class="th2">Graphics Test 1</th>
<td>252.4 fps</td>
<td>326.2 fps</td>
<td class="lotbetter">129.2%</td>
</tr>

<tr>
<th class="th2">Graphics Test 2</th>
<td>230.8 fps</td>
<td>280.7 fps</td>
<td class="bitbetter">121.6%</td>
</tr>

<tr>
<th class="th1">Cloud Gate</th>
<td>6035</td>
<td>6415</td>
<td class="bitbetter">106.3%</td>
</tr>

<tr>
<th class="th2">Graphics</th>
<td>7067</td>
<td>7709</td>
<td class="bitbetter">109.1%</td>
</tr>


<tr>
<th class="th2">Graphics Test 1</th>
<td>29.0 fps</td>
<td>28.6 fps</td>
<td class="same">98.6%</td>
</tr>

<tr>
<th class="th2">Graphics Test 2</th>
<td>32.6 fps</td>
<td>40.4 fps</td>
<td class="bitbetter">123.9%</td>
</tr>

<tr>
<th class="th2">Physics Test</th>
<td>12.7 fps</td>
<td>12.8 fps</td>
<td class="same">100.8%</td>
</tr>

</tbody>

</table>
</div>
</div>
</p>

The Physics test only measures CPU speed and can thus be ignored. Insofar as benchmarks are concerned, it looks like the 750m's gains over the Iris Pro are moderate: 25% in the basic test and 9% in the more intensive test. Do note, however, that the second number is an average, and that Graphics Test 2 in Ice Storm also showed ~25% improvement.

I then ran the same test in native Bootcamp. Unfortunately, it's impossible to switch to integrated graphics in Windows, so this is only useful for comparing discrete performance between native and VM.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>3DMark Vantage in Windows Native</caption>

<col class="ch" />
<col span="2" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Discrete</th>
<th>Windows Native Performance Over Windows VM</th>
</tr>

<tr>
<th class="th1">Ice Storm</th>
<td>80004</td>
<td class="lotbetter">131.5%</td>
</tr>

<tr>
<th class="th2">Graphics</th>
<td>101785</td>
<td class="lotbetter">146.7%</td>
</tr>

<tr>
<th class="th2">Physics</th>
<td>45745</td>
<td class="bitbetter">107.5%</td>
</tr>

<tr>
<th class="th2">Graphics Test 1</th>
<td>447.9 fps</td>
<td class="lotbetter">137.3%</td>
</tr>

<tr>
<th class="th2">Graphics Test 2</th>
<td>437.3 fps</td>
<td class="best">155.8%</td>
</tr>

<tr>
<th class="th2">Physics Test</th>
<td>145.2 fps</td>
<td class="bitbetter">107.5%</td>
</tr>

<tr>
<th class="th1">Cloud Gate</th>
<td>10258</td>
<td class="best">159.9%</td>
</tr>

<tr>
<th class="th2">Graphics</th>
<td>12601</td>
<td class="best">163.5%</td>
</tr>

<tr>
<th class="th2">Physics</th>
<td>6215</td>
<td class="best">153.8%</td>
</tr>

<tr>
<th class="th2">Graphics Test 1</th>
<td>55.0 fps</td>
<td class="best">192.3%</td>
</tr>

<tr>
<th class="th2">Graphics Test 2</th>
<td>54.6 fps</td>
<td class="lotbetter">135.1%</td>
</tr>

<tr>
<th class="th2">Physics Test</th>
<td>19.7 fps</td>
<td class="best">153.9%</td>
</tr>

</table>
</div>
</div>
</p>

As one might expect, Bootcamp clobbers Parallels. The more demanding Cloud Gate benchmark shows much bigger gains than Ice Storm, implying that the VM is better suited to slightly older games.

3DMark in Bootcamp also added one more test at the end, possibly due to the fact that Parallels only supports DirectX 10. I'm putting it here for completion's sake.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>3DMark Vantage Fire Strike in Windows Native</caption>

<col class="ch" />
<col span="1" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Discrete</th>
</tr>

<tr>
<th class="th1">Fire Strike</th>
<td>1741</td>
</tr>

<tr>
<th class="th2">Graphics</th>
<td>1790</td>
</tr>

<tr>
<th class="th2">Physics</th>
<td>9024</td>
</tr>

<tr>
<th class="th2">Combined</th>
<td>721</td>
</tr>

<tr>
<th class="th2">Graphics Test 1</th>
<td>8.3 fps</td>
</tr>

<tr>
<th class="th2">Graphics Test 2</th>
<td>7.32 fps</td>
</tr>

<tr>
<th class="th2">Physics Test</th>
<td>28.6 fps</td>
</tr>

<tr>
<th class="th2">Combined Test</th>
<td>3.35 fps</td>
</tr>

</table>
</div>
</div>
</p>

## Unigine Heaven

Next, I downloaded the [Unigine Heaven](http://unigine.com/products/heaven/) benchmark. This benchmark is very convenient because it can be run natively in both Windows and OSX, allowing us to make cross-platform comparisons.

First, I ran the same Parallels test that I did for 3DMark using Unigine's two built-in presets. Unfortunately, it turned out that the Extreme test didn't support tesselation in VM but *did* when run natively, forcing me to do a few custom runs on the other platforms with tesselation turned off. It also threw up errors when I tried to run the test in OpenGL or DirectX 9, so I had to stick to DirectX 11 in the VM.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Unigine Heaven in Windows VM</caption>

<col class="ch" />
<col span="3" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Integrated</th>
<th>Discrete</th>
<th>Discrete Performance Over Integrated</th>
</tr>

<tr>
<th class="th1">Basic (DirectX 9)</th>
<td>660 (26.2 fps)</td>
<td>856 (34.0 fps)</td>
<td class="lotbetter">129.7%</td>
</tr>

<tr>
<th class="th1">Extreme (DrectX 11 Without Tesselation)</th>
<td>241 (9.6 fps)</td>
<td>416 (16.5 fps)</td>
<td class="best">172.6%</td>
</tr>

</table>
</div>
</div>
</p>

A surprisingly significant result for the Extreme benchmark! Discrete performance is nearly twice as fast.

Next, I did the same test in OSX, using the ever-so-convenient [gfxCardStatus](http://gfx.io) to switch between integrated and discrete graphics.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Unigine Heaven in OSX</caption>

<col class="ch" />
<col span="5" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Integrated</th>
<th>Discrete</th>
<th>Discrete Performance Over Integrated</th>
<th>OSX Integrated Performance Over Windows VM Integrated</th>
<th>OSX Discrete Performance Over Windows VM Discrete</th>
</tr>

<tr>
<th class="th1">Basic</th>
<td>543 (21.6 fps)</td>
<td>870 (34.5 fps)</td>
<td class="best">160.2%</td>
<td class="bitworse">82.3%</td>
<td class="same">101.6%</td>
</tr>

<tr>
<th class="th1">Extreme (OpenGL)</th>
<td>157 (6.2 fps)</td>
<td>271 (10.8 fps)</td>
<td class="best">172.6%</td>
<td class="empty"></td>
<td class="empty"></td>
</tr>

<tr>
<th class="th1">Extreme (OpenGL Without Tesselation)</th>
<td>230 (9.1 fps)</td>
<td>384 (15.2 fps)</td>
<td class="best">167.0%</td>
<td class="bitworse">95.4%</td>
<td class="bitworse">92.3%</td>
</tr>

</table>
</div>
</div>
</p>

Yikes! Looks like running a benchmark tool in a VM, through Parallels's DirectX to OpenGL layer, and finally through the OSX OpenGL driver is somehow faster than running the same benchmark natively. On the other hand, the difference between integrated and discrete performance is a lot more consistent here. Like in the previous test, we see almost twofold gains.

Finally, I ran the same test in Bootcamp.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Unigine Heaven in Windows Native</caption>

<col class="ch" />
<col span="3" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Discrete</th>
<th>Windows Native Performance Over Windows VM</th>
<th>Windows Native Performance Over OSX</th>
</tr>

<tr>
<th class="th1">Basic (OpenGL)</th>
<td>971 (38.5 fps)</td>
<td class="empty"></td>
<td class="bitbetter">111.6%</td>
</tr>

<tr>
<th class="th1">Basic (DirectX 9)</th>
<td>994 (39.5 fps)</td>
<td class="bitbetter">116.1%</td>
<td class="empty"></td>
</tr>

<tr>
<th class="th1">Extreme (OpenGL)</th>
<td>298 (11.8 fps)</td>
<td class="empty"></td>
<td class="bitbetter">110.0%</td>
</tr>

<tr>
<th class="th1">Extreme (DirectX 11 Without Tesselation)</th>
<td>465 (18.5 fps)</td>
<td class="bitbetter">111.8%</td>
<td class="empty"></td>
</tr>

</table>
</div>
</div>
</p>

Looks like the difference between all three platforms for this particular benchmark isn't too significant.

## Metro: Last Light

For my next test, I decided to go a little crazy and give Metro: Last Light a go. Frankly, I wasn't even sure if Parallels was up to the task! As it turns out, modern VMs are a lot more powerful than they look.

Here are the presets I used with the handy MetroLLbenchmark.exe utility.

* Preset 1: 1440×900, DirectX 10, low quality, AF 4×, low motion blur, SSAA off, PhysX off
* Preset 2: 1440×900, DirectX 10, high quality, AF 16×, normal motion blur, SSAA off, PhysX off
* Preset 3: 1920×1200, DirectX 10, high quality, AF 16×, normal motion blur, SSAA on, PhysX off

And here are the results with the typical Parallels shenanigans.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Metro: Last Light in Windows VM</caption>

<col class="ch" />
<col span="3" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Integrated</th>
<th>Discrete</th>
<th>Discrete Performance Over Integrated</th>
</tr>

<tr>
<th>Preset 2</th>
<td>10.82 fps (1657 frames)</td>
<td>18.7 fps (2940 frames)</td>
<td class="best">172.8%</td>
</tr>

<tr>
<th>Preset 3</th>
<td>3.89 fps (589 frames)</td>
<td>6.6 fps (1023 frames)</td>
<td class="best">169.7%</td>
</tr>

</table>
</div>
</div>
</p>

As with Unigine, we see almost twofold gains when using discrete graphics. Makes sense: Metro is one of the most graphically intensive games on PC right now.

Next, I ran all my presets in Bootcamp.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Metro: Last Light in Windows Native</caption>

<col class="ch" />
<col span="3" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Discrete</th>
<th>Windows Native Performance Over Windows VM</th>
</tr>

<tr>
<th>Preset 1</th>
<td>43.74 fps (7480 frames)</td>
<td class="empty"></td>
</tr>

<tr>
<th>Preset 2</th>
<td>27.76 frames (4744 frames)</td>
<td class="lotbetter">148.4%</td>
</tr>

<tr>
<th>Preset 3</th>
<td>9.54 fps (1624 frames)</td>
<td class="lotbetter">144.5%</td>
</tr>

</table>
</div>
</div>
</p>

I was surprised to see that the gain from running natively over running in VM was only around 50%. For a game like Metro, I expected native Windows to completely blow the VM away. You probably wouldn't want to run the game in Parallels due to the fact that it's a bit jittery and unstable, but still!

Just to see how far I could push this machine, I added a couple of modified runs: Preset 2 with SSAA on, and Preset 2 with PhysX on.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Metro: Last Light Modified Preset 2 in Windows Native</caption>

<col class="ch" />
<col span="3" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Discrete</th>
<th>Modified Preset Performance Over Preset 2</th>
</tr>

<tr>
<th>Preset 2 (SSAA on)</th>
<td>16.22 fps (2767 frames)</td>
<td class="lotworse">58.4%</td>
</tr>

<tr>
<th>Preset 2 (PhysX on)</th>
<td>21.69 fps (3706 frames)</td>
<td class="bitworse">78.1%</td>
</tr>

</table>
</div>
</div>
</p>

If you're going for performance, SSAA is clearly a killer. PhysX, on the other hand, doesn't make as much of an impact as I expected. Still might be worth turning off: I didn't notice anything different in the benchmark.

Just for kicks, I did one more batch of runs in DirectX 11 mode.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Metro: Last Light DirectX 11 in Windows Native</caption>

<col class="ch" />
<col span="2" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Discrete</th>
<th>DirectX 11 Performance Over DirectX 10</th>
</tr>

<tr>
<th>Preset 1</th>
<td>44.91 fps (7679 frames)</td>
<td class="same">102.7%</td>
</tr>

<tr>
<th>Preset 2</th>
<td>29.74 frames (5083 frames)</td>
<td class="bitbetter">107.1%</td>
</tr>

<tr>
<th>Preset 2 (SSAA on)</th>
<td>17.58 fps (3002 frames)</td>
<td class="bitbetter">108.4%</td>
</tr>

<tr>
<th>Preset 3</th>
<td>10.58 fps (1803 frames)</td>
<td class="bitbetter">110.9%</td>
</tr>

</table>
</div>
</div>
</p>

Whoa! It actually runs *better*? Definitely wasn't expecting that. Certainly not the case on my desktop.

I would have loved to test the performance of Metro on OSX, but unfortunately the OSX port had no benchmark tool and barely offered any graphics options to speak of.

## Batman: Arkham City

Finally, I found the one recent game in my Steam library that had an in-game benchmark on OSX: Batman: Arkham City. I ran it on the Low and High presets in 1680×1050.

<p>
<div class="tablecontainer">
<div class="tablepadding">
<table>

<caption>Batman: Arkham City in OSX</caption>

<col class="ch" />
<col span="3" class="data" />

<tr class="rh">
<td class="corner"></td>
<th>Integrated</th>
<th>Discrete</th>
<th>Discrete Performance Over Integrated</th>
</tr>

<tr>
<th>Low</th>
<td>37 fps</td>
<td>54 fps</td>
<td class="lotbetter">145.9%</td>
</tr>

<tr>
<th>High</th>
<td>32 fps</td>
<td>44 fps</td>
<td class="lotbetter">137.5%</td>
</tr>

</table>
</div>
</div>
</p>

The Unreal 3 engine isn't as fancy as the Metro engine and the benchmarks reflect this. Discrete performance is "only" around 40% faster than integrated.

A few more telling benchmarks would be Far Cry 3, Crysis 2/3, Battlefield 3/4, and Max Payne 3. These represent some of the most powerful engines available on PC right now. I might add a few more measurements later on.

## Conclusion

There you have it! A bit of benchmark geekery to shed some light on the new Macbook Pro's graphics situation. What have we learned?

* The Nvidia 750m is significantly better than the Intel Iris Pro 5200 in many cases, surpassing it by 25%-70% in framerate. With that said, the Iris Pro is powerful enough to run most of the same games at lower settings, which is all the more impressive considering its very low power consumption. I would frankly be surprised if the next generation of Macbook Pros even *had* a discrete graphics chip, and given the speed at which Intel is improving their graphics performance, that might be OK by me.
* Bootcamp performs a whole lot better than Parallels, generally by 50%-60%. Performance is also a lot smoother. Still pretty darn impressive, considering that the VM boots up in about 5 seconds and hangs out in your dock while Bootcamp requires closing all your applications and rebooting. For the vast majority of Windows applications, Parallels looks like the winner. (Side note: I noticed really frustrating controller lag in Spelunky until I disabled vertical synchronization in the VM options. Unfortunately, this caused some pretty heavy tearing.)
* I wasn't specifically testing for it since I knew the answer already, but OSX really suffers in graphics performance compared to Windows. The state of Mac ports in general is honestly a bit sad. Many of them run in a compatibility layer like Wine instead of running natively. Saves usually aren't synced between Mac and Windows. Graphics menus often leave you with far fewer choices, going so far as a single-axis slider for Metro. Crashes and other bizzare problems frequently show up. Unless you're playing games by Valve or Blizzard, you'll be better off running in Bootcamp or Parallels. (And even then, I've noticed weird mouse behavior, network errors, and outright crashes in the Mac port of Counter-Strike: Global Offensive!)
* In terms of hardware, Macs haven't traditionally been known for their gaming prowess, but all that's changed. If I can run Metro, I can call this a gaming machine. End of story.

There are a few other subtle advantages and disadvantages that the discrete graphics chip brings to the table. I might as well mention them here.

* **Pro:** OpenCL can allegedly use both the integrated and discrete chips simultaneously. Apple seems to be pushing for OpenCL these days, so we may see significant performance gains in this area as high performance apps catch up. Hopefully, the new Mac Pro will be a cataclyst for this.
* **Con:** Discrete graphics really eat through your battery life. While most applications don't automatically switch to discrete graphics, some do and won't switch back until you close them. As far as I know, the only easy way to tell which chip is currently active is to use [gfxCardStatus](http://gfx.io). You can also use this tool to force OSX into integrated graphics mode, unless you're hooked up to an external monitor. However, there's no guarantee that this workaround will keep working with future OS updates!
* **Con:** In Bootcamp, you can't switch to integrated graphics. This means that if you run your top-of-the-line Macbook in Windows, you'll have poor battery life. Not so if you buy a Macbook without discrete graphics.

Finally, a quick note on the day-to-day performance of this machine. Holy matchsticks, is it fast! I didn't realize it was even *possible* to boot up a VM in 5 seconds, let alone run a game like Metro on it. On my previous machine, a mid-range Core2Duo with 8GB RAM, booting up the VM was an ordeal, and often left one OS or the other in an unusable state. Here, it's as smooth as opening any other app. In terms of game performance, I'm super impressed by how well most of my favorite games run, even compared to my desktop. Lightroom is blazing fast when browsing and developing, though full-size previews for my 8MP photos take a second each to generate. And, of course, the Retina display is stunningly beautiful, though it does seem a bit darker than the screen on my previous laptop. Might just be a trick of the eye.

(One minor Bootcamp issue: Windows 7 doesn't deal with DPI scaling very well, so running at the native 2880×1800 with 200% DPI looks kinda bad. Unfortunately, the halved 1440×900 isn't a standard resolution according to the Nvidia driver and looks a bit blurry. Since anything other than 2880×1800 was going to be blurry anyways, I've resorted to running in 1680×1050. Interestingly, since the Windows VM uses Parallels' own graphics driver, it does not have this problem at 1440×900.)

I realize this is one of the most expensive machines on the market, but if you want something that can develop OSX/iOS apps *and* run Windows *and* play all your games *and* be compact enough to travel with for long periods of time *and* have enough screen estate to do serious work... [deep breath]... *and* have a beautiful and sturdy design that will last you many years, this laptop truly has no equals. Price is a tough pill to swallow, though.

##Other References

* Notebookcheck's benchmarks for the [Iris Pro 5200](http://www.notebookcheck.net/Intel-Iris-Pro-Graphics-5200.90965.0.html) and the [750m](http://www.notebookcheck.net/NVIDIA-GeForce-GT-750M.90245.0.html). Their measured gains are a lot more modest than mine, but the benchmarks also older and done on different machines.
* [A set of benchmarks for the previous generation of integrated/discrete chips.](https://www.youtube.com/watch?v=ATKDuQOQw9k)
* [Anandtech digs deep into the Iris Pro 5200.](http://www.anandtech.com/show/6993/intel-iris-pro-5200-graphics-review-core-i74950hq-tested)
* MacRumors has a [few](http://forums.macrumors.com/showthread.php?t=1658931) [useful](http://forums.macrumors.com/showthread.php?t=1615379) [threads](http://forums.macrumors.com/showthread.php?t=1660072) dealing with the Iris Pro/750m question.