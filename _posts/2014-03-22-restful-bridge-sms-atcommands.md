---
layout: post
title: A RESTful bridge to send and receive SMS using AT commands
description: "This project exposes a RESTful API to send/receive SMS messages via AT-Commands. I use this with a Portech MV-372, and it's working great! Telnet connections FTW."
date: '2014-03-22T17:27:00.000-03:00'
tags:
- portech mv-372
- antel
- AT commands
- bridge
- twilio
- sms
- python
- RESTful
modified_time: '2014-03-22T17:29:45.754-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-707117977205176196
blogger_orig_url: http://blog.gmc.uy/2014/03/a-restful-bridge-to-send-and-receive.html
priority: 0.6
---
I'm pretty proud of this little project... It's just a small python app that polls via telnet to a Portech MV-372 and checks if any new text messages arrived. If they did, it posts them to a RESTful API. It also exposes a RESTful API for other applications to send messages. The beauty? it works! despite the awful [AT Commands](https://en.wikipedia.org/wiki/Hayes_command_set).

<!--more-->
I bought the Portech MV-372 to place free calls to both my and my wife's mobile phones. Despite some minor hiccups (like the web server not being 100% of the time available or stuff like that) it's been working fine.

One of the first things I wanted to do was having my twilio number forward text messages (SMS) to my mobile phone... but using the Portech (so that they're free). The problem with that is that the Portech uses [AT Commands](https://en.wikipedia.org/wiki/Hayes_command_set) that are really something to deal with.

You need to open a telnet connection to the device and then issue the commands required to either verify if there are new text messages or send a new one... there's no way to tell that an SMS arrived to the Portech other than by polling.

Oh, and I forgot... you can only have one concurrent telnet connection open... and that's not all... while there's a connection established, you can't place new calls. That's a lovely scenario to work on, right?

## Goals
1. Have a RESTful service that let me send and receive texts
2. Have a RESTful service that lets me ask my carrier how much credit I have on my SIMs

I have recently started playing with python... so this is a perfect fit for my ODROID... connect once a minute to check if there were new texts to process and send the ones that were on the queue.

For the second goal my carrier (antel) exposes this through the SIM Applications... that means I had to dig into the [STK](https://en.wikipedia.org/wiki/SIM_Application_Toolkit)  AT Commands as well. The bright side is that once I select the appropriate option, what I get is just a regular text saying how much credit I have.

After just four days (what made me fall in love with python) I had something that worked. A bridge between the AT Commands and the beautiful REST world... I set up my logic on my windows server and have the bridge running locally on my odroid.  

You can [find the project on github](https://github.com/g3rv4/restful-sms). There are lots of things to do, but it gets the job done. Basically, when it's running behind nginx, it exposes a service for you to send texts and when a new text arrives it does a RESTful request to a url specified on `config.py`. In order to see which requests it does and what it expects, you should dig into the code... so it's not exactly ready for production but it has been pretty stable at home.

The setup is pretty raw right now, just an sql script for the database and the only documentation is on the code... but if there's people interested on it, I could see myself making it more user friendly ;)

If you happen to use it and have something to contribute, feel free to send pull requests.
