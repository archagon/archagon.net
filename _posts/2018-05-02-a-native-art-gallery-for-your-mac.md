---
layout: post
title: "A Native Art Gallery for Your Mac (Take 2)"
summary: "Backgroundifier, together with the Buddy companion app, lets you use your Mac's wallpaper as a rotating art gallery."
date: 2018-05-2
comments: true
categories: releases
//image_header: "header.jpg"
image_path: /blog/bgbuddy/
---
{% include imageheader %}

The challenge: fit a rotating art gallery somewhere into my life.

I love visual art and find it hugely inspiring. Unfortunately, reading art books is too much of a context switch to be a regular distraction, while museums are only appropriate for the rare excursion. Instagram helps, but it only lets you see content from artists you follow. There's still the 99% of art history beyond that sliver!

Sourcing art wasn't the problem. For years, I had been keeping a fairly large folder of inspiring images from places such as Imgur albums, [RuTracker museum collections][ru], and [/r/ImaginaryNetwork][sub]. But leafing through them wasn't enough: I needed to put them into a random rotation somehwere that was just out of eyeshot, but wasn't an overt distraction.

[ru]: https://rutracker.org/forum/viewforum.php?f=1643
[sub]: https://www.reddit.com/r/ImaginaryNetwork/

In 2015, I finally solved the problem by building an app called [Backgroundifier][bg], which converted arbitrary-size images into wallpapers by superimposing them onto attractive, blurred backgrounds. By pairing an [Automator Folder Action with the native wallpaper cycling functionality of macOS][previous], I could now drop arbitrary images into a directory on my desktop and have them automatically show up in my wallpaper rotation. Peeking at an image was as simple as invoking the Show Desktop shortcut, and if I wanted to see something new, all I had to do was switch to a new Space.

For the past few years, this scheme has been working fine. But recently, my collection had grown to over 500 images, and I found myself bumping into some slight annoyances. For example, I had no way to retrieve the filename of the current wallpaper, to remove an image from rotation, or to mark it as a favorite. Every maintenance task had to be performed manually.

Finally, I decided to build a menu bar app that would solve all my problems through a unified interface: [BackgroundifierBuddy][release].

<!--more-->

<div class="caption full-width">
<video controls muted preload="none" width="100%" poster="{% include imagepath name="screenshot.jpg" %}">
<source src="{% include imagepath name="demo.mp4" %}" type="video/mp4">
Your browser does not support the video tag.
</video>
</div>

BackgroundifierBuddy expects your images to be organized into two directories: one containing your source images, and the other containing their converted, Backgroundified counterparts. This latter directory should be the directory selected for your wallpaper rotation in System Preferences.

To start with, right-clicking on the menu bar icon shows your desktop, and right-clicking again moves onward to the next image. Moving the cursor away from the icon hides the desktop again.

With automatic conversion enabled, images dropped into the Source directory are immediately converted into wallpapers in the Output directory, just so long as the app is running. This means that obscure Folder Actions are no longer necessary for automatic conversion to work.

{% include image name="preferences.png" width="55.8rem" %}

If the current wallpaper is based in the Output directory, and if it has a counterpart in the Source directory, a number of maintenance tasks become available. If you've grown tired of an image in your rotation, you can click Delete to trash it together with its source image. If you want to save it for later, or if find that it needs some tweaking, you can click Archive to delete the wallpaper image and move the source image into the Archive directory. (Holding `Option` allows you to archive the image while still keeping it in rotation.) Clicking Favorite adds a custom Finder tag to the source image, making it easier to locate later.

Finally, Refresh Wallpaper Cache restarts the Dock (which seems to sometimes be necessary to update the wallpaper rotaiton with new images), while Toggle Desktop Icons shows and hides the icons on your desktop for better image visibility.

I was going for simplicity with my solution, and this is just about as simple as it gets: your bog-standard OS wallpaper cycling functionality, together with a helper app that builds on basic file system commands. No complexity, no hassles, and everything just works!

[Backgroundifier][bg] still costs a buck on the App Store, but BackgroundifierBuddy is [free and open source][github]. You can find the latest release [here][release]. Enjoy!

[previous]: {% post_url 2016-09-19-turning-your-macos-desktop-into-a-rotating-art-gallery-with-backgroundifier %}
[bg]: http://backgroundifier.archagon.net
[github]: https://github.com/archagon/backgroundifier-buddy
[release]: https://github.com/archagon/backgroundifier-buddy/releases

## Technical Details

{:.nojustify}
Although deceptively simple on the surface, the code behind BackgroundifierBuddy has eluded me for some time. The reason is that there's no public way to query the current wallpaper image when a directory is selected. You can try calling `desktopImageURL` on `NSWorkspace.shared`, but this will only return the directory itself, not the displayed image.

{:.nojustify}
In the past, you could pull this info from the `com.apple.desktop` defaults, but this is no longer an option. Starting with Mavericks, the wallpaper settings are stored in a `desktoppicture.db` SQLite file located in the `~/Library/Application Support/Dock` directory. The layout of this file is a tiny bit confusing, and you can read more about it [here][db1]. In brief, each image in the `data` table is associated with a Space UUID and display UUID pair. Unfortunately, there's no indication of which UUID the current Space might be associated with, nor are the UUIDs stored in order. (So if a new Space is created and then moved over a few spots, it becomes impossible to tell which one it is from the database alone.)

[db1]: http://www.1klb.com/posts/2013/11/02/desktop-background-on-os-x-109-mavericks/

{:.nojustify}
What's needed is a way to get the UUIDs of the current Space and display, and the classic way to do this is to query the `com.apple.spaces` defaults. Unfortunately, the data returned appears to be subtly incorrect. Among other faults, the "Current Space" UUID is usually out of date and the "Display Identifier" UUID is outright wrong, at least on my machine. To get the *real* info dictionary for Spaces, you have to call the private `CGSCopyManagedDisplaySpaces` function. This gives you up-to-date UUIDs for both the current Space and display.

{:.nojustify}
With these UUIDs in tow, there's now enough info to run a query against the `desktoppicture.db` file and retrieve the current wallpaper. Fortunately, we don't even have to go this far. After sleuthing around on Github for some relevant keywords—`_CGSDefaultConnection` together with "wallpaper", I think—I found a scant few references to a private function that did exactly what I needed: `DesktopPictureCopyDisplayForSpace`. Together with `CGSGetDisplayForUUID`, you can use this function to retrieve a dictionary with all the wallpaper info for a given space.

{:.nojustify}
Caveat emptor: all this stuff might break in a future macOS release. Fortunately, I'm not making any changes through the private APIs, only requesting data. The only edit I make to the wallpaper settings is when refreshing the current image, and this is simply done by calling the public `NSWorkspace` method `setDesktopImageURL` with arguments mirrored from `desktopImageURL` and `desktopImageOptions`. Toggle Desktop Icons does make a change to the `com.apple.finder` defaults, but this functionality is entirely optional.

Note that sandboxing restrictions only allow command line calls to Backgroundifier to process images in the user's Pictures directory and subdirectories. I haven't yet found a way to expand an app's sandbox when called from a non-sandboxed app, so this restriction carries over to the selection of Source and Output directories. (Let me know if you know a way to expand an app's sandbox from another app!) If this poses a problem, you'll be able to find a non-sandboxed, command-line version of the Backgroundifier executable in a zip file in the Resources subdirectory of the Backgroundifier.app bundle. Point to it in the BackgroundifierBuddy preferences and you should be good to go for arbitrary Source and Output directories.

{% include image name="bgify.png" width="81.9rem" %}