---
layout: post
title: Asterisk 12 on a Raspberry Pi... my experience
date: '2014-01-14T22:41:00.002-02:00'
tags:
- portech mv-372
- asterisk
- raspberry pi
modified_time: '2014-01-14T22:47:38.054-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-6001366397685676523
blogger_orig_url: http://blog.gmc.uy/2014/01/asterisk-12-on-raspberry-pi-my.html
---
I installed Asterisk 12 on a Raspberry... but I didn't document all my steps because I followed another blog's instructions. Guess what? that blog is now offline :P

<!--more-->

It's been a long trip since [I started playing with Asterisk]({% post_url 2013-10-18-asterisk-twilio-motivation %})... I did a few more things than integrating Asterisk with Twilio.

After doing that, I compared flowroute with Anveo (which works great for outgoing calls, but had issues with an incoming number on Argentina. I ended up using Anveo for most of my outgoing calls and it works just fine.

But, I wanted to be able to forward calls to my mobile phone (or my wife's) for free... ooor, as close to free as it gets. I then bought a Portech MV-372 (link dead) on Ebay... yeah, that's probably the opposite to free... but once I got my hands on it, I bought 2 SIM cards... one of them can call me for free, the other can call my wife for free (as long as I put $5 on them every month).

I quickly realized that the NAS (a Synology DS112j) didn't have enough power to deal with the calls. I read that Asterisk needs a kernel with a clock interrupting at least at 1000 HZ. When I first read that, I didn't have a clue on what that meant... but then, I found [this great post](https://www.advenage.com/topics/linux-timer-interrupt-frequency) that explained it with an app that lets you figure out yours. The NAS had 96 HZ.

I then moved to a VPS... but that made calls originating on my home line to the Portech travel all the way to the US. That generated a delay that was totally unacceptable. I started to think that maybe there's a reason for everyone to run Asterisk servers locally... you can't beat a LAN.

Also, at that point, the friends from Asterisk released Asterisk 12... with a RESTful interface that really got me thinking...

My good friend Juan lent me his Raspberry Pi to try it out. I know there are some images around with Asterisk already installed, but I preferred to go ahead and cherry pick what would be installed. I followed the steps at Mathew Jordan's blog (now offline) and voilá... I won't say that the compilation was fast... but it got there :) and here I am, placing calls through the Raspberry.

I still perceive a small delay on the calls (way better than on a VPS though) even when I set `ulaw:10` and `alaw:10` as codecs... not exactly sure why that happens (I'm just getting started here), but I've already ordered an [ODROID U3](https://www.hardkernel.com/main/products/prdt_info.php?g_code=G138745696275) to discard that it's due to the Raspberry Pi's lack of power.
