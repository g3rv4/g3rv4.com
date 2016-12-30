---
layout: default
title: yup!
tags: {{ page.tag }}
---
<h1 class="post-title">{{ page.tag }} articles</h1>

{% for post in site.posts %}
  {% if post.tags contains page.tag %}

## [{{post.title}}]({{post.url}})
<span class="post-date">{{ post.date | date_to_string }}
{% if post.tags %}
  <span class="post-tags">
    {% for tag in post.tags %}
      <a href="{{tag | datapage_url: '/tags' | remove: '.html'}}">[{{tag}}]</a>
      {% if forloop.index0 == 4 %}
        {% break %}
      {% endif %}
    {% endfor %}
  </span>
{% endif %}
</span>
{{post.excerpt}}
  {% endif %}
{% endfor %}
