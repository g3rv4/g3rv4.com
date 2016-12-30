---
layout: post
title: After twilio... Flowroute
description: "After integrating Asterisk with Twilio, I started checking out other providers. Flowroute is great (and here's a summary) but I'd recommend Anveo Direct now ;)"
date: '2013-11-02T17:21:00.000-02:00'
tags:
- Argentina
- rates
- Uruguay
- asterisk
- intervals
- flowroute
modified_time: '2013-12-17T20:49:24.093-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-1874038133689832415
blogger_orig_url: http://blog.gmc.uy/2013/11/after-twilio-flowroute.html
---
I "discovered" (in the same sense that Columbus discovered America) Flowroute as a VoIP trunk provider. This post isn't particularly insightful... but when I wrote it (in 2013) I was really excited about these things just existing.

<!--more-->
Once I finished the integration with twilio, I started looking for VoIP providers... just to see what was out there and b/c I found out that I'm really enjoying this VoIP adventure.

The first site I found was flowroute. When I saw their prices (and compared them to twilio) I couldn't believe how cheap they were. They also have, for every route, the 1st interval and the sub interval. As I didn't know what they were (and at some point I thought that the rate could be for those intervals instead of per minute), I sent a support ticket. Their response was quick and I couldn't put it better than them, so here it is
> The rates quoted are per-minute. To calculate the exact billed duration of a call, the length of the call is rounded up according to the billing intervals.
>
> To illustrate, here are a few examples of how this works for calls to a destination with 10/6 billing intervals:
>
> You make a call for 5 seconds: you will be billed for 10 seconds.
> You make a call for 11 seconds: you will be billed for 16 seconds. (10 + 6)
> You make a call for 20 seconds: you will be billed for 22 seconds. (10 + 6 + 6)
> You make a call for 62 seconds: you will be billed for 64 seconds. (10+6+6+6+6+6+6+6+6+6)
>
> At a rate of $0.01/minute for the above calls, the billing would work out as follows:
>
> 5 second call: $0.01 * 10 / 60 = $0.0017
> 11 second call: $0.01 * 16 / 60 = $0.0267
> 20 second call: $0.01 * 22 / 60 = $0.0037
> 62 second call: $0.01 * 64 / 60 = $0.0107
>
> Another example given that call billed at $0.04 per minute.
>
> If a call was 64 seconds, it will be rounded up to 66 seconds. The rate is then applied as follows:
> 66 seconds / 6 seconds = 1.1
> 1.1 * $0.04 = $0.044
>
> A 45 second call would be rounded up to 48 seconds. The rate is then applied as follows:
> 48 seconds / 6 seconds = 0.8
> 8 * $0.04 = $0.024

From all the examples the support guy wrote, you can tell he realized I'm no expert on the matter... but I really liked how he did his best to make sure I'd understand. I created my account and they gave me 25 cents for me to play with.

The setup was straightforward, they have a System Configurator that generates exactly what you need to put on your `sip.conf`. I placed a few calls to the US, but I couldn't place calls to Uruguay b/c of the rate (trial accounts have a limit on the routes they can call to based on its cost per minute) so I did a $35 deposit (the minimum to "upgrade" it).

Call quality to Argentina (landline), Uruguay (landline + mobile) and US was awesome. Calls to Argentinian mobile phones were a little laggy, but way better than Skype (and a lot cheaper). Another thing I didn't know was possible is that they passed the Caller ID for US and the main Uruguayan mobile carrier (Ancel) but failed to do so on calls to Argentina or to the other Uruguayans carriers (Claro or Movistar).

A great plus to flowroute is that calls to US toll free numbers are free... On the down side, they don't offer much to customize (like real time notifications or different routes with different CLI results) but I think it's awesome as a backup provider... and I say backup provider b/c after discovering Anveo, I fell in love with it... but that's on my next post
