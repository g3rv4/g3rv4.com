---
layout: post
title: 'Asterisk + Twilio: Making calls from home to twilio (Part III)'
date: '2013-10-19T17:50:00.000-02:00'
tags:
- twilio
- sip
- asterisk
- making calls
modified_time: '2013-12-17T20:41:14.793-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-320474175669241282
blogger_orig_url: http://blog.gmc.uy/2013/10/asterisk-twilio-making-calls-from-home.html
---
Third Asterisk + twilio post: Making calls from Asterisk to twilio.

<!--more-->
This is the third of four posts:

* [Asterisk + Twilio: Motivation (Part I)]({% post_url 2013-10-18-asterisk-twilio-motivation %})
* [Asterisk + Twilio: The hardware, Cisco SPA3102 and the FXO vs FXS ports (Part II)]({% post_url 2013-10-18-asterisk-twilio-hardware-cisco-spa3102 %})
* Asterisk + Twilio: Making calls from home to twilio (Part III)]
* [Asterisk + Twilio: Receiving calls from twilio (Part IV)]({% post_url 2013-10-20-asterisk-twilio-receiving-calls %})

Ok, so I had my wireless phone connected to my Cisco ATA, and if I dialed 111 I could hear "hello world"... now I wanted to have twilio on extension 222. It was way easier than expected.

First, I had to create a SIP domain on twilio... and as I have dynamic IP, I needed a credential list. On that domain, I just set up as Voice URL a twimlet that congratulates me :) with this url:

`http://twimlets.com/message?Message%5B0%5D=Congratulations!%20Congratulations!%20Congratulations!`

Then, on my `sip.conf` I created a device with this data
{% highlight ini %}
[twiliocall]                                                         
type = peer
username = myusername
remotesecret = mypassword
host = mydomain.sip.twilio.com
qualify = no
{% endhighlight %}

And the last step was using it on the dialplan... so on my `extensions.conf` I just added
{% highlight ini %}
exten => 222,1,Dial(SIP/twiliocall)
{% endhighlight %}

And voilà... I have twilio on 222. From there, you can do whatever you want using their API (you could have it ask which phone number you want to dial out and just do a `<Dial>`... or have a fancy IVR giving you weather or traffic status?)

Extremely painless... which wasn't the case when receiving calls from twilio, but more on that on the next post :)
