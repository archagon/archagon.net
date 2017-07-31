---
layout: post
title: "Fixing the Side Mouse Buttons in OS X"
date: 2017-06-06 11:53:52 -0700
comments: true
categories: 
---

Guys, I fixed the mouse in OS X!

Specifically, I made the side buttons on standard mice work correcty. And more specifically, Logitech actually did the fix. But I figured out how they did it and made an app to apply it to non-Logitech mice.

But very suspiciously, my MX Master was the first mouse I had used on a Mac that had completely fluid navigation.

It means that your side buttons are no longer limited to navigating apps that support the Cmd-[ and Cmd-] shortcuts. Now, any window that supports the 10.6-style swipe gestures — or, more specifically, any NSResponder that responds to the `swipeWithEvent:` selector — will also respond to the back and forward buttons. This behavior is completely native and requires no system overrides:




SensibleSideButtons finally fixes those pesky navigation buttons on your physical mice in OS X. Use M4 and M5 to navigate practically any window with a history, just as you would in Windows. No hacks, no admin privileges, nothing more than buried native functionality and a sprinkle of magic dust. The app lives in your menu bar; quit it and everything returns back to normal.

I was reminded of just how incredibly useful the side buttons on my mouse were when I was trying out the Logitech MX Master. In OS X, the side buttons on most mice are interpreted as middle-clicks: the M4 and M5 signals still get sent out, but there's no native support for going back and forward in history. A select few apps such as Firefox do interpret these buttons correctly, but the native middle click still barges in to open links out from under you that you didn't expect. Some mouse-manager apps pretend to fix this problem globally, but what they're really doing is sending out Cmd-[ and Cmd-] keyboard shortcuts whenever the buttons are clicked. Among other issues, this approach only works in a handful of apps, blinks the menu bar, and repeats on hold. Meanwhile, most of the navigation bars in your OS X apps will just stubbornly refuse to budge.

The MX Master was different in that the side buttons seemed to work as well as they did in Windows. If the view under your cursor had a nav bar, clicking the Master's side buttons was sure to do the right thing, regardless of whether you were using Safari, Finder, System Preferences, or even Spotify. I Googled thoroughly for some sort of global event that could be emitted by this mouse to make this work, but nothing came up: almost every StackOverflow answer regarding the side buttons suggested the tired, old keyboard shortcut solution. 

So I decided to do some digging around in Xcode. I wrote a quick app to detect mouse mouse button movement, figuring that maybe the Master's side buttons were doing something non-standard. Oddly, the side buttons couldn't get detected at all. I expanded my search to include *all* events being sent by the mouse, and then I saw that the Master's side buttons were actually posting fake left and right swipe gestures.

This was a brilliant solution to the problem. Going back to 10.6, OS X included a somewhat  hidden three-finger swipe gesture that let you navigate backwards and forwards in most apps. Most navigation-based view controllers supported it out of the box: all you had to do was add a method called `swipeWithEvent:` to your responder chain and you were good to go. For the most part, this was exactly the same functionality as back and forward. Unfortunately... there was no Apple-sanctioned way to fake a swipe event and send it off globally.

Fortunately, a kind soul had already reversed-engineered this problem. [] by [] provided a way to synthesize gesture events with just a few function calls. Plugging in some bare minimum metadata, I could now replicate the same swipe events I saw coming from the Master in code.

The final piece of the puzzle was making this work globally, and this was easy to do with event taps. Instead of existing in some unknown ether, SideButtonSunshine is a menu bar app that converts M4 and M5 into swipes only while it's running and enabled. There's no polling and no overhead: mouse events are processed cleanly according to best practices.