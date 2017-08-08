---
layout: post
title: "Robocopy: it's not as scary as it looks!"
date: 2013-06-16
categories: technology
---

<img src="https://static1.squarespace.com/static/51b3f330e4b062dc340fa8fd/t/51be7beae4b090c42fe54e4d/1371438059771/Robocopy.gif?format=750w" />

(OK, so I know a true sysadmin would be talking about the wonders of rsync in this post, but please bear with me. This was a Windows problem and I wanted to use the right Windows tool for the job.)

I recently got a [Synology](http://www.synology.com/) NAS unit, and I needed to copy a couple of terabytes worth of data from my external NTFS drives over to the new RAID array. What to do? First of all, it might seem obvious to most of you, but I just want to make it clear: Windows file copy was simply not an option. Among other nasty things, my drives contained backed up user directories from a bunch of old Windows installs, meaning that they were riddled with broken permissions, confused symbolic links and NTFS junction points, and paths that were somehow too long for Windows to handle. Windows file copy would have choked about halfway through.

No, this was a job for some serious command line jujitsu. And thankfully, Windows has a built-in tool that was perfect for the job: [robocopy](https://technet.microsoft.com/en-us/library/cc733145(v=ws.10).aspx). Just like rsync, robocopy has dozens of incomprehensible flags that you need to spend hours studying to fully understand. Fortunately, I've whittled them down to an abridged summary in case you find yourself in a similar situation.

<!--more-->

To clarify, here are the options I needed: 

* NTFS backup privileges. This was required to allow Windows to copy every single file, regardless of whatever mangled permissions they had set.
* Ignore symbolic links. Since I was copying the full contents of my drives, the symbolic links would have been redundant. Furthermore, since these drives were used on Windows only, I didn't have any symbolic links that I created myself. The only ones that were there were hidden Windows symbolic links that enabled backwards compatibility (or something).
* Ignore [NTFS junction points](http://en.wikipedia.org/wiki/NTFS_junction_point). Same reasoning as above.
* (Danger Will Robinson! Without these two options, your robocopy may well run into an infinite loop with Windows system directories, as mine did when I was still figuring out what to do.) 
* Ignore system files. The only system files I had were Windows files that I had no reason to copy.
* Remove hidden attributes from files. I was copying these drives strictly for the data, and I wanted to start with a clean slate.
* Remove existing permissions and replace with default permissions. Same reasoning as above. 
* Keep a robust log.

And here's what my robocopy call ended up looking like. Simply boot up PowerShell in admin mode and give it a go. (The normal command prompt should work too, but you might have to fiddle with the formatting a bit.)

<noscript><p><em>To see this Gist, please use a browser that supports Javascript.</em></p></noscript>
<script src="https://gist.github.com/archagon/5791332.js"></script>

robocopy appears to work by first doing a depth-first run through the entire tree, creating directories as it goes. It then copies the actual files in the same traversal order. Do note that the console log isn't always real-time; it occasionally takes it a while to catch up to the written log.

One caveat, from my understanding, is that robocopy doesn't automatically checksum copied files. If you want to be extra, 100% sure that everything copied correctly, I suggest using a tool like [checksum](http://corz.org/windows/software/checksum/). (I know it's a bit, uh, hacker-y looking, but it gets the job done quickly and efficiently, minus a few issues with Russian text.)

And as a bonus, here's a command you can run if Windows refuses to delete a directory due to the path length of some files contained inside! (This can happen sometimes with deeply nested folders.) Simply create an empty directory and mirror it into the directory you wish to clear. robocopy does not adhere to the same constraints as Windows file copy. (I am not responsible for any unintended data loss that may occur.)

<noscript><p><em>To see this Gist, please use a browser that supports Javascript.</em></p></noscript>
<script src="https://gist.github.com/archagon/5791339.js"></script>