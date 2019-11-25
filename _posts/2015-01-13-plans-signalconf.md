---
layout: post
title: 'Getting ready for #signalconf'
date: '2015-01-13T18:33:00.000-02:00'
tags:
- conference
- sip registration
- twilio
- signal
modified_time: '2015-01-14T18:19:47.358-02:00'
thumbnail: http://3.bp.blogspot.com/-fpYvfYVUzzs/VLV-CcXDjGI/AAAAAAAABjY/Y6Rbjvf1mpM/s72-c/registration.png
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-6269969885998644277
blogger_orig_url: http://blog.gmc.uy/2015/01/getting-ready-for-signal.html
---
When I wrote this I was super excited to be attending Twilio's conference, and I planned to build a system to show my skills in there. I didn't finish it in time, and I honestly didn't have an awesome time at that conference either :P but it felt wrong to just delete this... if nothing else, you can see some of my positive thinking.

<!--more-->
It's been a while since I last wrote in here... mainly because I've been working like crazy, but I'm expecting to start blogging on a regular basis at least until the [Signal conference](https://www.twilio.com/blog/2015/01/introducing-signal-twilio-conference-nt.html) (the new version of the twilio conference).

The (first and) last conference I attended was the 2013 [360\|iDev](https://360idev.com/)... and even if I ended up leaving the iOS world, I got something that changed my (professional) life from it... The conviction that (almost) everything is possible. I was already working with Twilio's APIs, I started playing with Asterisk, I started this blog, people started contacting me about it, I left the company I was working for and I'm proud to say that I'm working exclusively on stuff that I find interesting.

I went to that conference with very little experience on that particular technology, having only worked on an iOS app before, and without enough knowledge to really stand out from the crowd.

I'm in a very different situation for the Signal conference... I've worked with Twilio on several projects, using different technologies (Python and .NET both with websockets) and probably all what they offer. I have a good understanding of Asterisk and I'm eager to meet interesting people that can help me take my game to the next level (while I help them do the same)... but in two days, it's going to be crazy to really connect with so many people... that's why I feel I have to do something about it.

The thing that got me noticed in the virtual world is how I integrated Asterisk and Twilio before there was a single blog post around... so I'm going to try to build on it. Something that's missing in Twilio is the ability to have SIP phones register with it, so that developers can deal with SIP phones instead of regular landline or mobile phones. I'm guessing that's a feature that's coming (given that other companies already offer it and that Twilio has recently added [SIP Trunking](https://www.twilio.com/sip-trunking) capabilities). Besides adding an option to work with existing SIP terminals, the cost of calling SIP phones is significantly lower than calling landlines or mobile phones around the world, so it only makes sense for them to integrate it into what they sell... but in the mean time, I'm going to do something about it!

In order to have SIP phones register, you need to have a PBX (Asterisk or Freeswitch)... and dealing with them is usually a headache for application developers, so I'm going to build an Open Source "Asterisk as a service" service. It will have a .NET RESTful backend that will handle the application logic and several Ubuntu servers with Asterisk that will take care of the communication with Twilio and the SIP phones. The code to handle the servers will be pure Python and the frontend will be an AngularJS application that will connect to the backend in the same way that the Ubuntu servers will.

I'm going to have it ready for the Signal conference and I expect it to be an effective way for me to show how I work and what I know. I will also put a big deal of effort in detailing what's missing and how things could be improved (I've never worked with a SIP proxy, and for it to be really scalable and redundant, the solution would need one. I don't think I'll have enough time to learn and tackle that down though).

I expect to keep on sharing my problems and solutions in here... what started as a way to give back has taken my by surprise... Here's to more surprises and to a great 2015!

![](/public/images/signal-registration.png)

See _you_ there?
