---
layout: page
title: Tags
hide_from_sidebar: true
---

I'd say this page is "optimized for crawlers"... especially since I don't have that many posts. If you're a human, check out the [homepage]({{ site.baseurl }}). I've added excerpts that should help you figuring out if anything is worth reading ;)

{% assign sorted_tags = site.data.tags | sort: 'articles' | reverse %}
{% for tag in sorted_tags %}
## [{{tag.tag}}]({{tag.tag | datapage_url: '/tags' | remove: '.html'}})
{% endfor %}
