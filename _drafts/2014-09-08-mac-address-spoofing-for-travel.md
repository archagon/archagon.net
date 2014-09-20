---
layout: post
title: "MAC Address Spoofing for Fun and Non-Profit"
date: 2014-09-08 17:28:45 +0200
comments: true
categories: 
---
During my stay in HI-Quebec, I ran into an odd issue with the Wi-Fi. After about a day, the hotspot started giving me an "access denied" message when I tried to log in. No explanation or anything. Maybe I was watching too many videos? I'm pretty sure I didn't have any bandwidth-hogging applications running, and I couldn't ask the front desk since it was some sort of licensed/rented hotspot, as is common in hostels. I tried using my phone tethering for a while, but I found that I couldn't procrastinate effectively without better internet. So I decided to do the sensible thing and spoof my MAC address.

First of all, what's a MAC address? Basically, it's a hardware identifier for your networked device. Anything that has access to Wi-Fi also has a MAC address. This identifier is often used by internet services to identify your device if they want to (for example) set a time limit, or ensure that you're only using the device you first signed on with. Fortunately, MAC addresses aren't fixed: you can temporarily change them on desktop computers pretty easily, allowing you to bypass these restrictions.

On my OSX machine, doing this turned out to be a snap. Here's the collected set of commands I found:

`networksetup -listallhardwareports`

This command will show you a list of all your network devices. Take note of your Wi-Fi "device" and "ethernet address" (MAC address).

`ifconfig en1 | grep ether`

(Replace "en1" with whatever device identifier the previous command returned. On my old Mac, it was en1; on my new Mac, it's en0.) Run this command to confirm that your Wi-Fi MAC address is the same as above.

`openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'`

This command will generate a random MAC address. If the subsequent commands seem to work but don't actually change your MAC address, try running it again. There are certain MAC addresses that are invalid, but it's easy enough to just regenerate until you get one that I'm not going to bother fixing it.

`sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/sbin/airport`

This command makes the "airport" command more acessible.

`sudo airport -z`

This command disconnects you from the current Wi-Fi network.

`sudo ifconfig en1 ether 00:11:22:33:44:55`

(Replace "en1" with the device identifier and the MAC address with your randomly-generated MAC address.) This command should spoof your MAC address. If "ether" doesn't work for you, try "Wi-Fi" instead. (Apparently some installs of OSX use one or the other. You should be able to see which one it is with a plain "sudo ifconfig en1".)

`ifconfig en1 | grep ether`

(Replace "en1" etc. etc.) One more time to make sure that your new MAC address has stuck. If it hasn't, go back to the openssl step.

Your MAC address resets when you restart your computer, but I'm pretty sure you'll always be able to see the original address with the networksetup command above.

This might seem like an esoteric procedure, especially if you're a non-technical user. However, I've already run into at least three situations where this spoofing was required. One allowed me to stay indefinitely on a free Wi-Fi hotspot for longer than the allotted 30 minutes, and another allowed me to spoof my phone's MAC address and log into a restricted network.

And of course, I was finally able to log back into the HI-Quebec and watch aaaalllll the YouTube I wanted!