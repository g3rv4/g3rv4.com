---
layout: post
title: "Making Slack better with BetterSlack"
date: "2018-08-26 19:00:00 -0300"
description: "Here's a tiny extension that improves my Slack experience. Check it out!"
---
I built a Chrome extension that makes Slack even better :) It was called BetterSlack and it got unpublished following Slack's Legal Team's request. On this blog post I announced it.

<!--more-->

---

**UPDATE:** The extension was unpublished from the chrome web store following [Slack's Legal Team request]({% post_url 2018-08-29-bye-bye-betterslack %}).

**UPDATE Sept 14th 2018:** After talks with folks from Slack and a rename... Refined (fka Taut) (fka BetterSlack) is now live back!!! You can find on Chrome, Firefox and Opera. See more details at [refined.gervas.io](https://refined.gervas.io).

---

There are 2 or 3 things about Slack that I think can be made better. That's why I built BetterSlack. It's a Chrome extension that injects javascript into your Slack environments to add (or remove) features. You can find [its source code here](https://github.com/g3rv4/Refined) or watch my [3 minutes demo](https://www.youtube.com/watch?v=cXDXX9eYQPs).

# What does it do? (and why)

It adds a small button on your browser that lets you set up each feature independently.

## Hide certain users

This is something I find very valuable to hide applications that our team decided to integrate with Slack. Most people find them useful, but to me they sometimes make the chat very noisy.

How do you get their user ids? [Check out my 3 minutes video](https://www.youtube.com/watch?v=cXDXX9eYQPs) (it's going to get better, but right now it takes a couple clicks).

## Generate hangout links

We like hangouts... and a bunch of us don't use the Slack app, so we can't do Slack calls. You can provide a URL with a placeholder `$name$` (in my example I used `https://hangouts.google.com/hangouts/_/gmc.uy/$name$`).

With that url configured, when you write `hangout something` it sends to the channel `hangout something: https://hangouts.google.com/hangouts/_/gmc.uy/something`. When you send `hangout @someone` (if your display name was `g3rv4`) posts `hangout @someone: https://hangouts.google.com/hangouts/_/gmc.uy/g3rv4-someone`.

This is... how our chat (bonfire) works on our internal rooms. And I like that behavior better than the Slack ones.

## Markdown links

If you write `[here's a link](https://gmc.uy)`, it shows it as a link :)

The nice part? it shows it as a link for everybody, not only those who have the extension installed.

## Move reactions to the right

The reactions are a great way to interact without writing... but... they take vertical space, making me need to scroll to see what people have been talking about.

When reactions are moved to the right... that's it! they no longer take vertical space.

This was *designed by an engineer*, so you may see weird stuff. I made it so that if the window is too narrow, it just hides the reactions.

## Threads on channel by default

When talking on a thread, this feature makes the `Also post to #channel` checkbox checked by default. Some of us like it for... reasons.

## Disable Google Drive previews

I couldn't find a way of doing this in the preferences (I already have all the checkboxes on **Inline Media & Links** unchecked). So this feature disables the Google Drive previews.

## Disable Url previews

Even if I have `Show text previews of linked websites` disabled, it's still showing them to me. So I added this to enable its absolute removal.

## Hide status emojis

People may choose to have emojis next to their name as "status". This feature lets you disable them.

## Only show your reactions or reactions to your messages

This feature does what it says :) it only shows the reactions that you've made or the reactions to your messages.

## Can I see a demo?

Sure! I put together a 3 minutes video showing all these features.

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/cXDXX9eYQPs?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

# But I like the app!

I hear you. Unfortunately, injecting these scripts on the Slack app involves extracting it, patching it and packing it together. It works, but it's more involved and I couldn't find of an easy way to patch it so that it's easy for people to do it.

I may build an Electron app that patches the Electron app... so far, that's what makes the most sense to me. But we'll see.

One thing you can do is save the page as an application. That works out of the box for Windows, Linux and Chrome OS.

## How to save the page as an application on MacOS

You need to enable a couple flags.

1. Go to `chrome://flags`
2. Enable `Allow hosted apps to be opened in windows`
3. Enable `Creation of app shims for hosted apps on Mac`
4. Enable `The new bookmark app system`

Once you've done that, you can:

1. Go to the Slack page of the workplace you want to add (you can change it later)
2. Click on the 3 dots (more) on Chrome
3. More Tools
4. Create Shortcut
5. Give it a name and leave "Open as window" checked

Done! your preferences of BetterSlack are applied on this window as well... and, you can set it to open when your OS starts.
