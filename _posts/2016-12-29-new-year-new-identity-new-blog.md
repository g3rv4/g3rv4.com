---
layout: post
title: "New Year, New Identity, New Blog"
description: "It's 2017, I rebranded myself and built a new blog using Jekyll. Here... I just talk about it and my experience writing Ruby for the first time to tweak the blog."
tags:
 - blog
 - jekyll
date: "2016-12-29 11:27:59 -0300"
---
I've been elgerva, Gervasio, gmc-dev, gmc_dev... and now, I'm g3rv4. A playful nickname that I feel it identifies me better than all the other nicknames (and that was availabe everywhere!). Also, this blog is built with Jekyll, its code [is available on github](https://github.com/g3rv4/g3rv4.com) and it's deployed automatically on my server with a simple bash script. I had a blast setting it up, I even wrote my first Ruby lines while doing so!

<!--more-->
## 2017 and my new (virtual) identity
2017 is almost here and I have extremely high hopes for it. I've managed to somehow keep my amazing job at Stack Overflow after 3 months and 10 days. Even if most of my merge requests get reviewed with strong criticism, I'm happy to say I haven't made the same mistake twice. It could very well be that I haven't had time to make the same mistake twice, but I choose to believe that it's because I'm learning. A. FREAKING. LOT.

Enough about Stack Overflow, I will eventually write a nice post about it (with links to the already existent dozens of posts written by my amazing coworkers). This is 2017 and this cool job gave me enough confidence to change my virtual identity into something a bit more playful (and more importantly, *available everywhere*). I'm now `g3rv4` on twitter, github, Stack Overflow and my blog is at `g3rv4.com`.

## The blog
When I started blogging, I went with blogger just because I didn't want to mess with Wordpress and its lovely plugins ecosystem... I didn't want to install security patches and I didn't want to pay for it. I didn't have high hopes for it either, but what it did for my professional life blew me away.

As the nerd I am, I like to have control about everything. I want to be able to specify exactly how links are built, I want to ensure that I have no dead links, I want to serve it using a certificate with my name on it (well, that was the plan when I wrote this article, but then I read about StartCom's situation and I moved to the beautiful [letsencrypt](https://letsencrypt.org/)). I want to basically feel my blog mine. And while I was working with an amazing designer to build my amazing site, I realized that all I needed was blog. But a blog where I had fine-grained control over everything and where I didn't have to deal with security patches. Ever.

I read about Jekyll when Stack Overflow's blog migrated to it, but I didn't really see how it could be useful. Until this time, when I started checking it out. All it does is generate a static site (it reminded me of CityDesk, [the application Joel was using on his blog since 2001](https://www.joelonsoftware.com/2001/10/12/what-does-citydesk-do/) and that he [recently retired](https://www.joelonsoftware.com/2016/12/09/rip-citydesk/)... it did exactly the same), but exposing hooks at interesting generation points where you can alter *how* a page is rendered.

Here are the things that bugged me the most about blogger:
* It had a WYSIWYG editor that generated awful HTML behind the scenes. When I wanted to tweak something (or use a syntax highlighter) I had to dig into that awful HTML and play with `<pre>`s and `&nbsp;`s
* For *every* link I wanted to open in a new tab (and with `rel="nofollow"`) I had to edit that lovely HTML
* I didn't have a way to audit my external links (or if I did, I never knew)
* I couldn't tweak its appearance besides what *they* wanted to let me tweak.

### My experience with Jekyll

I found a clean theme really quick (there's a lot of open sourced ones). I set up ruby locally in minutes and I had Hyde running on my machine (as the official one doesn't support Jekyll 3, I went with [this fork](https://github.com/JuanjoSalvador/hyde) instead).

I migrated my old posts from blogger using [Jekyll's importer](https://import.jekyllrb.com/docs/blogger/) and that magically brought all of them into the site. They were HTML though, and I wanted to convert them as markdown... so that part was manual :S

Then, I wanted to add `target="blank"` and `rel="nofollow"` to all the external links... and I found [a plugin](http://ogarkov.com/jekyll/plugins/extlinks/) that took care of that. Everything is Ruby, and I've never used it before... but it was super straightforward to [add some code to verify if a URL is valid or not](https://github.com/g3rv4/g3rv4.com/blob/master/_plugins/external-links.rb#L64). After that, if I set the `check_links` config value to `true`, I get an error on the console when a URL returns anything other than a 200 response.

I also wanted to have a page per tag, so that my visitors could click on a tag and see all the articles that I wrote with that particular tag. To do that, I used the [jekyll-datapage_gen plugin](https://github.com/avillafiorita/jekyll-datapage_gen)... but that plugin relies on you entering the source data as a YAML or JSON file... and I wanted it to be generated dinamically... so [I wrote a plugin](https://github.com/g3rv4/g3rv4.com/blob/e9ddd05f5af65db73f0307b0194ef2fd82889935/_plugins/generate-tags-data.rb) that populates the `data` element of the site with the tags when the posts are read.

The other cool thing I did was building a tags page (that I removed when I implemented my [sitemap](https://github.com/g3rv4/g3rv4.com/blob/master/sitemap.xml)). It's a page for crawlers that contains all the tags used on the site and lets you click on them to see the articles related.

Oh, and other cool thing... I have excerpts for my posts, that are shown on the index page but hidden on the post page... Doing that was just updating the posts layout to just remove it :)

{% highlight liquid %}
{% assign content = '{{ content | remove_first:page.excerpt }}' %}
{{content}}
{% endhighlight %}

And now, my index looks super clean :) Adding Disqus was a piece of cake, same thing with Google Analytics... it's just HTML. And you can do whatever you want with it. If you want absolute control, you'll love Jekyll.

I'm now working on the final steps... I have to set up my server to check if there are updates to the repo, and if there are, build the site. I have to add 301 redirections from the old URLs to the new ones. But I'm really enjoying this so far, and I **won't have to deal with Wordpress security updates and crazy PHP templates!!!** that's amazing.
