---
layout: post
title: "Bye bye Refined"
date: "2019-07-29 01:00:00 -0300"
description: "Slack revamped their app... and it's time to retire Refined"
---
Slack revamped their app... and lots of those changes make it harder for extensions to interact with it.

Since the main goal of Refined is to make my life easier, I'm stopping its public distribution to avoid playing a cat and mouse game that I can only loose.

<!--more-->

This is a bit of a Déjà vu... almost a year ago I was writing [Bye bye BetterSlack]({% post_url 2018-08-29-bye-bye-betterslack %}).

Recently Slack shipped their new [and better version](https://slack.engineering/rebuilding-slack-on-the-desktop-308d6fe94ae4) both to their apps and to the web.

I haven't verified if the web is faster, but I have no reasons to believe it isn't. What I do know is that in addition to making it faster, they did other changes that make it harder for extensions to interact with it:

* They added a CSP rule that doesn't allow inline scripts (which makes Firefox complain when injecting javascript).
* The http requests are served by their service worker (extensions can't mess with the service worker... or at least, I haven't found a way to do so). Changes to the service worker can only be done with a MITM proxy that modifies it.
* They stopped exposing a bunch of their functions in the `window` object. Now, everything lives inside the webpack-generated modules, which have indices that change every time they compile their app.

Could they have exposed these features? they could. Did they do it to make it harder to develop extensions that mess with the user experience? I don't know, but it doesn't seem unlikely.

I was able to overcome these problems... but it took a significant amount of time and effort. Now that I have a baby, time is hard to come by. And as the main goal of Refined is to make *my* life easier (and don't want to play a cat and mouse game that I can't win) I'm continuing its development in private.

I'm going to leave the latest version up in GitHub so that if you want to continue its development you can fork it and do as you please.

If you're somebody I know and you'd like to have access to the private version, hit me up.

I'm sorry for the folks that used it and enjoyed it. Thanks for everything.