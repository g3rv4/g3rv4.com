---
layout: post
title: Dynamically loading sip users from a database (and generating extensions for
  them)
date: '2013-12-17T20:34:00.000-02:00'
tags:
- database
- nat
- mysql
- dynamic clients
- sip
- asterisk
- sip.conf
modified_time: '2013-12-17T20:35:42.773-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-2108507495166335109
blogger_orig_url: http://blog.gmc.uy/2013/12/asterisk-load-sip-peers-from-db.html
---
A simple approach to manage Asterisk users programatically. It's nothing weird (and probably how most people solve this issue) but given that I couldn't find anything already written about it, I just went ahead and documented it.

<!--more-->
My goal with this blog was just sharing the interesting (technological) problems I face and the way I solve them to read other suggestions and hopefully help a fellow developer... but, and that's what's awesome about life, things rarely go as you plan them and this time it was for the best. After I made a few blog posts on my twilio + asterisk integration, I received 2 offers to work on contract projects. It was a pleasure to work with both Seth and Abraham, and they made me want to continue working on this technology... so, you know... I'm available for Asterisk contract projects!

I don't want to lose sight of the original blog goal though, and one of the requirements Seth had was getting the sip users from a mysql database, where he would update the passwords whenever the users changed them. As I think that's worth sharing, here it goes...

After reading about how to do that, the first thing I found was [Asterisk Realtime Architecture](https://www.voip-info.org/wiki/view/Asterisk+RealTime) and that looked really promising. Despite having to use their table structure, the main issue is that (from that link)
> The **database peers/users** are not kept in memory. These are only loaded when we have a call and then deleted, so **there's no support for NAT keep-alives (qualify=) or voicemail indications** for these peers.

Which is definitely not acceptable if you have mobile clients.

We built a simple cron that runs once per minute and, if there are any changes, it updates the `sip.conf` file, `extensions.conf` (b/c of his requirements, changes on the database may lead to changes in the extensions file) and, once both files are tweaked, the cron just does
{% highlight text %}
asterisk -r -x "sip reload"
asterisk -r -x "dialplan reload"
{% endhighlight %}

This works just fine, it doesn't disconnect already registered peers and, as the cron does it only if it detects changes, it should be the same as doing it manually.

However, it feels like cheating... specially when there's Asterisk Realtime Architecture to load the peers and [Asterisk RealTime Extensions](https://www.voip-info.org/wiki/view/Asterisk+RealTime+Extensions) to load the extensions from a db  (why would they build it if you can do it easily with a cron?).

If you find issues with this approach (and feel like sharing) please add a comment.
