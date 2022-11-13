---
layout: post
title: 'Asterisk + Twilio: Motivation (Part I)'
date: '2013-10-18T18:09:00.001-02:00'
tags:
- google voice
- twilio
- sip
- asterisk
modified_time: '2013-12-17T20:38:59.325-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-1373330712362697165
blogger_orig_url: http://blog.gmc.uy/2013/10/asterisk-twilio-motivation-part-i.html
---
I was working with twilio, I started playing with Asterisk and obviously wanted them to interact. I was so proud of what I did that I wanted to share it, so this is why I started this blog... This is the first post of 4 about it. There're way better ways of doing it today, but these posts were an extremely important part in how my professional life changed for the better. So I love them unapologetically.

<!--more-->

This is the first of four posts:
* Asterisk + Twilio: Motivation (Part I)
* [Asterisk + Twilio: The hardware, Cisco SPA3102 and the FXO vs FXS ports (Part II)]({% post_url 2013-10-18-asterisk-twilio-hardware-cisco-spa3102 %})
* [Asterisk + Twilio: Making calls from home to twilio (Part III)]({% post_url 2013-10-19-asterisk-twilio-making-calls %})
* [Asterisk + Twilio: Receiving calls from twilio (Part IV)]({% post_url 2013-10-20-asterisk-twilio-receiving-calls %})

I work for a US based company, I have very good friends there and travel as frequently as I possibly can. So, I usually need to make and receive calls. When I travel there, I buy a SIM card and have a local number... but, I can't really give that number to people b/c it's good only for as long as I'm there. This is something I tried to solve by using Google Voice. Just rang to my gmail or... rang to my skype number which in turn forwarded the call to my mobile phone. It never worked... calls took like 10 seconds to start ringing on my mobile and the callers that waited for so long didn't wait the extra 4 seconds that it took me answering it.

I've been using different call communications providers at  work,  mostly Marchex and Ifbyphone. But when I read about twilio, I instantly  fell in love with it... but as we couldn't really use it at work due to other priorities, I immediately started playing with it to have calls that were made to my US number forwarded to my mobile phone. Results were impressive.

Calls were forwarded to my Uruguayan number almost instantly and the sound quality was good... but I had a few problems
* I couldn't make calls
* The price of calls to a Uruguayan mobile phone was really high (38 cents per minute)
* twilio doesn't sell numbers in Uruguay... and I really wanted to have twilio on my home number to do cool stuff (we usually receive wrong-number calls from people who want pizza delivered... how about greeting my callers with a "if you want to order pizza press 1" and once they press 1 "we want pizza too... unfortunately, you have the wrong number")

I started playing with twilio client to make phone calls from an iOS app I built... That's really good as long as you have wifi available, but why wouldn't I just use google voice if I had wifi? nope, I needed something else.

I've heard about Asterisk to build PBXs... but every time someone mentioned it, they said it was too complex... and that kind of kept me away from it. But recently twilio released [twilio SIP](https://www.twilio.com/voice/sip-interface) and I felt like it was about time to try setting up Asterisk to receive twilio calls at home. I got my hands on "[Asterisk™: The Definitive Guide](https://www.oreilly.com/library/view/asterisk-the-definitive/9781449332433/)" and I couldn't stop reading it. Also, I own a Synology DS112j that installed Asterisk with one click... I went from 0 to 60 (with my own asterisk server handling softphone calls) in a few days.

The [next post]({% post_url 2013-10-18-asterisk-twilio-hardware-cisco-spa3102 %}) is about some cool hardware I bought to bring this to the real world and stop using those lame softphone apps.
