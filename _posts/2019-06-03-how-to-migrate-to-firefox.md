---
layout: post
title: "How to migrate to Firefox if you depend on sites that don't support it"
date: "2019-06-03 10:00:00 -0300"
description: "Want to migrate to Firefox but can't because you depend on site X? here's a solution"
---

I've been wanting to migrate from Chrome to Firefox for a while now... but I use hangouts and meet and they... don't work great with Firefox. So I built OnChrome: a Firefox extension where I can specify the sites I want to open in Chrome. The extension just launches Chrome when I visit one of those sites.

<!--more-->

**TL;DR**: I wrote [OnChrome](https://addons.mozilla.org/en-US/firefox/addon/onchrome/), a Firefox extension that opens the urls you want on Chrome. To use it, make sure you [install the native app](https://github.com/g3rv4/OnChrome/releases). Why a native app? well, keep on reading :P

In case you missed it, Google is planning to change what extensions can do [with the manifest v3](https://docs.google.com/document/d/1nPu6Wy4LWR66EFLeYInl3NzzhHzc-qnk4w4PX-0XMw8/edit#). A bunch of things are great (I really really think that [as things stand, extensions are really dangerous]({% post_url 2018-09-18-browser-extensions-are-insecure %})) but the fact that [they're severely limiting how Ad Blockers can do their thing](https://bugs.chromium.org/p/chromium/issues/detail?id=896897&desc=2#c23) is a bit worrysome to me.

The [uBlock Origin](https://github.com/gorhill/uBlock) author [mentions](https://github.com/uBlockOrigin/uBlock-issues/issues/338#issuecomment-496009417) this move is consistent with their [10K filling](https://www.sec.gov/Archives/edgar/data/1652044/000165204419000004/goog10-kq42018.htm) where they acknowledge that ad blockers could adversely affect their operating results. It makes perfect sense *for them*.

I want to be able to use extensions to finely tune how I live the web. I used Firefox before Chrome existed... and the only reason why I switched was because Chrome was faster. Firefox has come a long way and I feel it as fast as Chrome now.

## But... some sites don't work in Firefox!

This is the main problem I hit when I tried to do the switch. Even if [Firefox supposedly works with Hangouts and Meet](https://blog.mozilla.org/webrtc/firefox-is-now-supported-by-google-hangouts-and-meet/), this is what I see when I open a hangout on Firefox:

![](/public/images/sorryHangouts.png)

And with meet, everything *seemed* like it was working... but nobody on the call could hear me despite the green indicator showing I was indeed talking and not muted. I opened the meet url in Chrome and boom! everything worked.

## How can I fix it?

I'd like to use Firefox for evertyhing except for those sites where I have a reason not to. I was looking for extensions that did this... but only found extensions that let you say "open this page in Chrome". That means the following flow would happen to me 10 times per day:

1. Follow a link to a hangout or a meet
2. Click on the "Send to Chrome" button
3. Pr0fit

It may seem like not a big deal, but this is exactly the kind of things that make me nuts, and a good reason for me to stick with Chrome.

But maybe I can build an extension where I specified the urls beforehand and it would work this way:

1. Follow a link to a hangout or a meet
2. Firefox closes the tab and Chrome is opened exactly where I was on Firefox
3. Pr0fit

In this scenario, I don't need to do anything different. I just visit sites on Firefox, and it decides (based on the rules I set up) if it should use Chrome for it or not.

## How do these extensions do their magic?

Firefox doesn't let extensions connect directly to the OS and tell "hey, open Chrome for me!" (thankfully they don't, that would be a security nightmare). But what Firefox does allow is using [Native Messaging](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging) (well, it's not really just Firefox... it's a WebExtensions API, but I only care about Firefox here).

By using native messaging, an extension can connect to an application on the user's machine and exchange messages. The applications that receives those messages needs to explicitly list which extensions can send it messages.

So... all these extensions **require you to install something**. That is not the bestest experience for an extension user, but it makes sense.

## So I went ahead and built OnChrome!

The initial version (without allowing me to change URLs anywhere other than its source code) took me 30 minutes to build.

I was using python for the native application... but if I wanted to distribute it, people would need to install python for the extension to work.

So I implemented the native app in Go. This got me nice binaries that run in Windows and MacOS, have 0 dependencies and are easy to deploy. You can see [their source code here](https://github.com/g3rv4/OnChrome/tree/master/app). Also, they don't require privileged access at all, that's nice.

Things are different in Windows and MacOS (the Windows version plays a lot with the registry for instance). But the code is easy to follow, so if you're concerned with installing stuff on your machine (as you should be) you should be able to easily compile them yourself.

Total time? a night that I went to bed at 3am + a Sunday evening for the Go stuff + a beautiful logo.

## How can I install the extension?

Installing the extension should be fairly straightforward (although a bit more involved than installing an extension that doesn't use native messaging).

1. Install the [Firefox extension from their store](https://addons.mozilla.org/en-US/firefox/addon/onchrome/)
2. Download [the native application](https://onchro.me/native-applications) for your environment and follon the instructions on that page

And that should be it! Here you can see it working:

![](/public/images/hangoutOnChrome.gif)

## How can I completely uninstall the extension?

The only *weird* thing the app does is registering it to receive messages from the extension (that is either creating a file on MacOS or adding a registry key on Windows).

To completely remove the extension, the application, and any traces of it you should:

1. Run the `Uninstall` application
2. Remove the add on from Firefox
3. Delete the folder where you have the app

## And that's it!

I'm going to probably add things like "Open on Chrome" by right-clicking on a link... but other than that, it does exactly what I wanted it to :)

You can find its source code at [onchro.me](https://onchro.me), and I'll *someday* build a small website for it like I did for [Refined](https://refined.chat).

Have comments? tweet me at @g3rv4!