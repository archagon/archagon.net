---
layout: post
title: "Boat++"
date: 2014-6-17
comments: true
categories: travel
redirect_from:
  - /a-few-pointless-thoughts/2014/6/17/boat/
---

<img src="https://static1.squarespace.com/static/51b3f330e4b062dc340fa8fd/t/53a0d143e4b0514810c144d0/1403048267125/Cruise+Desk.jpg?format=1000w" />

So how's programming on a cruise ship, anyway?

First of all, you can't count on the internet out at sea. That's not to say it's unusable: I saw speeds as high as 15Mbit/sec down, though they usually hovered around 1Mbit/sec or less. (Ping was atrocious, of course.) However, at almost a dollar per minute during regular hours, it was hard to justify. One deal that my particular cruise offered was half-price internet from 11pm to 5am, giving me a rate of $0.37/minute. (This was actually better than most of the package deals and allowed me pay à la carte.) Having mentally allotted $50 for internet use, this meant that I could only use about 10 minutes per day, or 20 if I went once every 2 days. For the most part, I spent these periods rapidly opening a bunch of tabs to Gmail, Feedbin, and Hacker News, loading any new articles I needed since the last internet checkpoint, disconnecting to write any replies, and reconnecting one final time to send them out. It was basic, but it kept me content. (All logging in and logging out was done through an atrocious web interface, while the charges could be verified through an equally despicable account navigator on the cabin television.)

<!--more-->

Offline programming might sound daunting (the old-timers are laughing at me now), but it's really not so bad. No, not because you're supposed to be good enough to program without an online reference. It's because you can cheat and download the [entire StackExchange data dump](https://archive.org/details/stackexchange) for only 20GB of your hard drive space (circa January 2014)! Even more spoilingly, a wonderful developer named Samuel Lai has created a local web app called [stackdump](http://stackapps.com/questions/3610/stackdump-an-offline-browser-for-stackexchange-sites) that lets you browse and search this entire archive using a beautifully-designed interface that almost rivals StackExchange itself. (Seriously, I could see myself paying $100 for this product.) Stackdump copies the XML data to a local database, so it requires a good chunk of extra space: I have it showing about 20GB for StackOverflow alone. Furthermore, the initial copy takes about 7-8 hours on a top-of-the-line machine, and could potentially take much longer on a slower one. If you only figure this out in the middle of your trip, you might be in for a bad time. My advice is to clear up 50-100GB of your hard drive space and run the script locally (read: not on an external drive), since you'll be able to suspend and resume your machine without interrupting the indexing. Fortunately, after the initial hump, it's all smooth sailing! (So to speak.)

In addition to this little ace up my sleeve, I downloaded local copies of the documentation for all the platforms, libraries, and frameworks I intended to use during my trip. (These included iOS and OSX, Python, and Cocos2d.) Xcode's local documentation browser was my most used resource by far, with stackdump serving as a secondary reference for some of my more esoteric questions.

One cache that I would have benefitted from having, but unfortunately forgot to bring, was the [Wikipedia data dump](http://en.wikipedia.org/wiki/Wikipedia:Database_download). It didn't really cross my mind when I was preparing for my trip, but Wikipedia has some great high-level overviews of CS concepts and programming languages/features. The total compressed size is about 40GB: not bad for a first-order approximation of the sum total of human knowledge!

Before leaving, I made sure to test all my tools in offline mode, just to make sure I didn't miss anything. Turns out it was a good hunch: I almost left without renewing my Apple developer certificate, which would have prevented me from testing on my device!

Having prepared ahead of time, I found working on the boat to be a wonderful experience. The ship offered many comfortable and scenic places to set up. I preferred sitting outside in the aft café during the day and in my cabin at night. My room had a wide, comfortable desk with plenty of power outlets, and the indirect sunlight from the porthole made the space feel cozy and relaxing. Despite my initial fears, I found myself barely missing the internet at all.

Programming is unfortunately an activity that tends to isolate us in quiet, poorly-lit spaces, so it was wonderful to work out in the open ocean air for a change! Now that I'm back on land, I may have to find some work-friendly parks to recreate that experience.