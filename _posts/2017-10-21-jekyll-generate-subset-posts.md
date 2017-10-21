---
layout: post
title: "Make Jekyll generate only certain posts / pages"
date: "2017-10-21 12:38:00 -0300"
---
I love Jekyll. It's not only straightforward to use for web developers and it's _extremely_ extensible. But, once you have a bunch of posts, it can get slow.

This site was taking 16s to build on my local environment, so I wrote a plugin to only generate the posts I'm working on, and now the whole thing takes less than 2s.

<!--more-->
Every time I want to write about something, I find myself a small little thing to code, so that I don't have enough time to actually write... the bright side is that I end up with some little tweak I enjoyed doing + a blog post about it.

Aaaanyway, today I started writing an article... and noticed that generating this blog was taking 16 seconds on my computer. That's too much. I started looking for alternatives, I've heard good things about [hugo](https://gohugo.io/)... which sounds great, but I'd miss Jekyll's extensibility deeply (I'm automatically [adding "nofollow" to my external links](https://github.com/g3rv4/g3rv4.com/blob/master/_plugins/external-links.rb#L90-L98), [verifying that they don't break](https://github.com/g3rv4/g3rv4.com/blob/master/_plugins/external-links.rb#L68-L86) and [adding width and height to the images on my articles](https://github.com/g3rv4/g3rv4.com/blob/master/_plugins/image-tweaker.rb)).

I'm using [drone.io](https://drone.io/) to do continuous deployment (so that I just do a push and my server takes care of building it and invalidating cloudflare's cache), so I really don't care about how long my entire site takes to build on the server... what's really bothering me is my local time. I like to write -> check how it looks -> tweak it -> check how it looks -> tweak it... and you got the idea.

So what I did is... [just another simple plugin](https://github.com/g3rv4/g3rv4.com/blob/master/_plugins/build-only-this.rb)! If this is enabled (it can be enabled on the `_config.yml` file), it checks the `_data/build_only_this.yml` file to check which posts and pages it builds... and that's it! as my [`.drone.yml`](https://github.com/g3rv4/g3rv4.com/blob/master/.drone.yml#L9-L10) removes the lines that have `#local` on them and removes `#prod:` from all the lines, I can get away with using this in my `_config.yml`:

```
build_only_this:
  enabled: true #local
```

This solution probably doesn't work for everybody, but it certainly works for me and writing Jekyll plugins always make me happy (even if I don't particularly enjoy Ruby). If this is the kind of thing you enjoy, definitely give it a try to Jekyll... and don't fall for the "Jekyll is too slow" argument: it doesn't really _need to_.

And that's it! I have a really fast Jekyll locally that I can easily extend via Ruby plugins. Now, let's write that freaking article.
