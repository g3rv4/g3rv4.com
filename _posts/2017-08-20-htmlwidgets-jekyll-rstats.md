---
layout: post
title: "Enabling htmlwidgets on a Jekyll based R blog"
date: "2017-08-20 16:38:00 -0300"
---
So far, I've enabled htmlwidgets on 3 Jekyll based blogs, authored with RStudio. It's been harder than I anticipated, and I learned a couple things that I think could be useful for other people.

<!--more-->
It's no myth. This can be done in a way that works with GitHub Pages, trust me. You'll either leave this post with your blog working or with a clearer idea of what's what you're missing. Or at least, that's my goal.

# Disclaimer

This may not work 100% for your blog. There's no clean package to solve it (yet?).

## Why?

We should all be blogging. That's no news. But there's a group of people that are doing things that are particularly interesting... they are the data scientists! They have a way of answering questions that I find fascinating.

There's a significant group of data scientists that work with R, blog with R and never really needed to learn javascript. With Jekyll and GitHub Pages, you can set up a nice-looking blog built with R thanks to the hundreds of tutorials around.

But... the whole experience becomes frustrating when they want to use a javascript powered library. On my wife's [4th blog post](https://d4tagirl.com/2017/05/how-to-fetch-twitter-users-with-r) she wanted to use a `DT::datatable` to show a long table in an friendly way. All it does is adding some javascript so that you can do searches and pagination... but she hit a dead end when trying to set it up by herself.

I then gave it a try, and after some time copy-pasting bits that I didn't understand, I made it work. Then, by using the already proven copy-this-here-and-then-that-there method, we also set it up on [Maëlle's blog](http://masalmon.eu/).

Last week, [Kasia asked for help on twitter](https://twitter.com/KKulma/status/896497101772734465)... and what could I do if not helping out? she uses a different method for building her blog, so this time, I had to _actually understand_ what I was doing.

**BUT** I'd like to help people do this by themselves... and that's exactly what this post is about.

# The problem

Each of these `htmlwidgets` libraries have a set of javascript/css files they need in order to work on your blog. You need to:

1. Generate these javascript/css files
2. Link to the appropriate javascript files from the articles that need them
3. Upload these libraries to your repository

If you were to do this manually... it would be painful... every time you use an `htmlwidgets` library, you'd be sad. Fortunately, there's a better (and, once it's set up) automated way.

## Two different paths

Some people use `brocks::blog_serve()` to convert from `.Rmd` files to `.md` files. That's nice, because it also loads your website locally so that you can play with it. Other people just knit their `.Rmd` and just upload the resulting `.md`.

## The build logic (a.k.a. "Generate the javascript/css files")

Regardless of which path you've chosen, the magic happens when the `Rmd` is knitted and converted into an `md` file. If you're not using `brocks`, you can use this function to knit your `.Rmd`s and generate all the files that are required. If you are using `brocks` still check this function out, as the code is basically the same:

```
build_article <- function(filename) {
  # set the base url so that it knows where to find stuff
  knitr::opts_knit$set(base.url = "/")

  # tell it that we'll be generating an md file
  knitr::render_markdown()

  # generate a directory name, where we'll be storing the figures for it
  d = gsub('^_|[.][a-zA-Z]+$', '', filename)

  # tell it where to store the figures and cache files
  knitr::opts_chunk$set(
    fig.path   = sprintf('figure/%s/', d),
    cache.path = sprintf('cache/%s/', d),

    # THIS IS CRITICAL! without this, it tries to take a screenshot instead of
    # using the js/css files. It took me **a lot of time** to figure this out
    screenshot.force = FALSE
  )

  # this is the path to the original file. WARNING: I assume your .Rmd files are
  # at /_source. If that's not the case, adjust this variable
  source = paste0('_source/', filename, '.Rmd')

  # this is where we want the md file
  dest = paste0('_posts/', filename, '.md')

  # actually knit it!
  knitr::knit(source, dest, quiet = TRUE, encoding = 'UTF-8', envir = .GlobalEnv)

  # store the dependencies where they belong
  brocks::htmlwidgets_deps(source)
}
```

You can call this with `build_article('2017-08-20-some-random-post')` and it would process your `_source/2017-08-20-some-random-post.Rmd` file.

`build_article`, thanks to the [`brocks`](https://github.com/brendan-r/brocks) package, takes care of generating and properly locating the javascript and css files. What is "properly locating?" in this example, it would create a file at `_includes/htmlwidgets/some-random-post.html` that you need to include in your article's html. But how? keep on reading.

## Linking to the appropriate js/css files

From the previous step, you have an `_includes/htmlwidgets/some-random-post.html` file that has contents similar to this:

```
{% raw %}
<script src="{{ "/htmlwidgets_deps/htmlwidgets-0.9/htmlwidgets.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/htmlwidgets_deps/jquery-1.12.4/jquery.min.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/htmlwidgets_deps/datatables-binding-0.2/datatables.js" | prepend: site.baseurl }}"></script>
<link href="{{ "/htmlwidgets_deps/dt-core-1.10.12/css/jquery.dataTables.min.css" | prepend: site.baseurl }}" rel="stylesheet" />
<link href="{{ "/htmlwidgets_deps/dt-core-1.10.12/css/jquery.dataTables.extra.css" | prepend: site.baseurl }}" rel="stylesheet" />
<script src="{{ "/htmlwidgets_deps/dt-core-1.10.12/js/jquery.dataTables.min.js" | prepend: site.baseurl }}"></script>
{% endraw %}
```

This is something you need to ensure is included on your article's html... Here's a clean way of doing so.

### Step 1: Add it to your front matter

What the heck is the front matter, you ask? it's a section that should go at the top of your `.Rmd` articles and that should look like this:

```
---
layout: post
title: "Something something data science something"
date: "2017-08-20 16:38:00 -0300"
---
```

This is data that gets passed to Jekyll. What we're going to do, is include `htmlwidgets: true`, so that you end up with

```
---
layout: post
title: "Something something data science something"
date: "2017-08-20 16:38:00 -0300"
htmlwidgets: true
---
```

This, by itself, doesn't do anything... but...

### Step 2: Actually including the freaking thing

On your `_includes/head.html`, before `</head>`, add

```
{% raw %}
<!-- add htmlwidgets files -->
{% if page.htmlwidgets %}
  {% assign dep_file = page.url | split: '/' | last | prepend : 'htmlwidgets/' | append : '.html' | replace: '.Rmd', '' %}
  {% include {{dep_file}} %}
{% endif %}
<!-- end htmlwidgets files -->
{% endraw %}
```

The first and last lines are comment (they provide no real value other than making it easy for you to understand the generated html, you're free to delete them if you want to).

`{% raw %}{% if page.htmlwidgets %}{% endraw %}` is Jekyll code for "if the `htmlwidgets` element in the front matter of the article is `true`"... and here's where we're using that. Why not doing this for every article? because we won't need included javascript/css files on those.

The next line, assigns the route to the included file (trust me) to the variable `dep_file`. And then, it just includes it. That's it!

## If you are using brocks to generate your `.md` files

If you have a local Jekyll install and run `brocks::blog_serve()` to generate your files (and also see how it's going to look before pushing), then you don't want to be calling `build_article` every time you do a change... that's what `brocks` (well, really `servr` behind the scenes) does for you. If it exists, it's going to call a `build.R` with instructions about how to knit your files.

You should do exactly the same thing on your front matter and `_includes/head.html` file... but instead of defining a function, you should just create a `build.R` file with the following content:

```
local({
  # set the base url so that it knows where to find stuff
  knitr::opts_knit$set(base.url = "/")

  # tell it that we'll be generating an md file
  knitr::render_markdown()

  # input/output filenames are passed as two additional arguments to Rscript
  a = commandArgs(TRUE)

  # generate a directory name, where we'll be storing the figures for it
  d = gsub('^_|[.][a-zA-Z]+$', '', a[1])

  # tell it where to store the figures and cache files
  knitr::opts_chunk$set(
    fig.path   = sprintf('figure/%s/', d),
    cache.path = sprintf('cache/%s/', d),

    # THIS IS CRITICAL! without this, it tries to take a screenshot instead of
    # using the js/css files. It took me **a lot of time** to figure this out
    screenshot.force = FALSE
  )

  # actually knit it!
  knitr::knit(a[1], a[2], quiet = TRUE, encoding = 'UTF-8', envir = .GlobalEnv)

  # store the dependencies where they belong
  brocks::htmlwidgets_deps(a)
})
```

You can see it's basically the same thing, but instead of defining a function it evaluates an expression... and it receives the source and the destination as command arguments.

There probably are some weird stuff going on in this with the `baseurl`, but I'm not particularly proud of how I fixed that in [d4tagirl's](https://d4tagirl.com/) or [maëlle's](http://masalmon.eu/) blogs... so if you fix it for your blog (or want me to help figure out what's missing), feel free to mention me on twitter :)
