---
layout: post
title: 'Asterisk + Twilio: The hardware, Cisco SPA3102 and the FXO vs FXS ports (Part
  II)'
date: '2013-10-18T19:33:00.000-02:00'
tags:
- fxo
- fxs
- cisco spa3102
- asterisk
modified_time: '2013-12-17T20:40:13.260-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-8470870028934655884
blogger_orig_url: http://blog.gmc.uy/2013/10/asterisk-twilio-hardware-cisco-spa3102.html
---
Here I talk about the little boxes I bought to use my regular phones (and my phone line) with my Asterisk box. I bought them in 2013 and they've been working great after 3 years.

<!--more-->
This is the second of four posts:

* [Asterisk + Twilio: Motivation (Part I)]({% post_url 2013-10-18-asterisk-twilio-motivation %})
* Asterisk + Twilio: The hardware, Cisco SPA3102 and the FXO vs FXS ports (Part II)
* [Asterisk + Twilio: Making calls from home to twilio (Part III)]({% post_url 2013-10-19-asterisk-twilio-making-calls %})
* [Asterisk + Twilio: Receiving calls from twilio (Part IV)]({% post_url 2013-10-20-asterisk-twilio-receiving-calls %})

I had my Asterisk server handling calls between softphones... but it didn't really feel like a big achievement. I wanted to connect the server to my home line... but as I couldn't wait, I took a quick read about the differences about FXS and FXO... and bought an ATA that had 2 FXS ports! when I realised that the FXS ports don't connect to the line, but to a regular phone device it was too late.

I should have read it in the book, but I did a quick search on google and thought I had figured it out... but I hadn't. In short:

* An FXO port connects to a phone line from your provider (PSTN or Public switched telephone network)
* An FXS port connects to regular phone, transforming your plain old phone into a VoIP phone

Then, I went ahead and ordered a Cisco SPA3102 on amazon. It's a "Voice Gateway with Router" that has an FXO and an FXS port... I wanted one with two FXO ports (thought I'd buy a second line and route calls from one line to the other and have free calls from my mobile phone) but I'm glad I bought this one... I can use my wireless phone just as I used to and it can play in the wonderful Asterisk world. If I want to connect two PSTN lines, it still makes sense to buy another Cisco.

Setting up the Cisco SPA3102 wasn't extremely complex (wasn't a piece of cake either), the two things that took me the most to figure out was:
* I wanted to have incoming calls automatically reach an extension at Asterisk, but by default it just returns the dial tone to the caller. What I did was, on the PSTN User, set an automatic forward... using caller id * to an extension I want, and that's how every call is transferred to it. This is how it looks
![](/public/images/cisco-transfer.png)
* The disconnect tone... the calls that came from the phone line were never terminated b/c it didn't recognise the Uruguayan disconnect tone... I found it on the PSTN Line tab (not in the regional one) and the value for Uruguay is `420@-30,420@-30;2(.2/.2/1,.2/.6/1)` I tried looking it up in an ITU document, but it was impossible for me (without any electrical background) to transform the amplitudes and frequencies there to something useful here... so I found it in a forum (link dead, it was `https://forum.voxilla.com/threads/disconnect-tone-tweaking-solution.2780/`)

Once I figured that out, it was pretty smooth... the [next post]({% post_url 2013-10-19-asterisk-twilio-making-calls %}) is about calling from Asterisk to twilio :)
