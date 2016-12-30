---
layout: post
title: Asterisk 13 on an Ubuntu Docker container
description: "I set up Asterisk 13 in Docker. It was fun, and it's been working all right for a long time! This lets me move it relatively easily the next time."
date: '2016-06-30T12:40:00.000-03:00'
tags:
- container
- docker
- asterisk
modified_time: '2016-06-30T12:56:08.280-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-6217953000330744718
blogger_orig_url: http://blog.gmc.uy/2016/06/asterisk-13-on-ubuntu-docker-container.html
---
I started playing with Docker and I dockerized all the apps that are running on my server. It was all super straightforward except for... Asterisk! here I talk about how I made it happen (it amazes me how you set up Asterisk boxes and just forget about them... they just _work_)

<!--more-->
Hello world! It's been a while! but I'm trying to get back at blogging :)

I've been reading tweets about how great Docker is but I've never had the chance to try it out... until... I decided it was my next adventure... and boy am I enjoying it!

I started my Docker journey by buying [The Docker Book](https://www.dockerbook.com/), it's awesome... I read it in two days just because I couldn't stop.

Then, I started thinking about how I would dockerize all the services I run on my servers... I started a migration a few months ago and I've never got the nerve to complete it... so getting to try Docker to actually do something useful (and finish that migration) sounds like a great plan.

I started by moving gitlab with my nginx server... that's fairly easy and I could either use the built in images or build my own ones using Ubuntu 14.04 (so that I don't have lots of base images)... and it was Asterisk's turn.

I found the [dougbtv/asterisk](https://hub.docker.com/r/dougbtv/asterisk/) image that honestly does all the heavy lifting... he figured out how to compile it in a docker-compatible way, so all the credits to him... but I wanted to:

1. Keep the image size to the minimum
2. Pick the modules I want to compile (I'm a control freak and it's also related to the previous point)
3. Mount the etc, spool and log directories so that I can do modifications and see them on the host
4. If the etc folder is empty, copy the default files so that I have something to work with... if it has files, just leave it as it is

Soooo... I ended up building [gmcuy/asterisk](https://hub.docker.com/r/g3rv4/asterisk/) (you can see the Dockerfile in there).

After several trials and errors (all using different `RUN`s so that I could reuse the intermediate images and either find out the different `menuselect/menuselect` options or debug which libraries I was missing) I ended up putting everything on a single run so that:

* The source code is never included in a layer
* wget is never included in a layer

I also put the `COPY` of the `init.sh` and `default-conf.tgz` last so that if I tweak them it reuses the asterisk compiled layer... oh, and as dougbtv suggested... I'm using `network_options: host`... I was able to map the RTP UDP port range from 10000-10100 by doing `'10000-10100/udp'` but I couldn't get audio through... I tried fiddling with the `nat` settings but I couldn't figure it out, so I just exposed it at the host level and that was it. Do I like it? nope... but it still feels better (and way easier to move) than having asterisk compiled on the server (which I've found out is not as a repeatable process as I'd like).

Hope you can at least get some inspiration from here! and if you have something that can be improved, please let me know :)
