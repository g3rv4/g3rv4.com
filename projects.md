---
layout: page
title: Projects
order: 1
---
Here are some projects that make me proud :)

## OnChrome
Site: [onchro.me](https://onchro.me) - Code: [github](https://github.com/g3rv4/OnChrome) - On my blog: [announcement]({% post_url 2019-06-03-how-to-migrate-to-firefox %})

It's a browser extension for Firefox so that users can choose which urls will be opened on Chrome. When the user visits that url on Firefox (either by writing its url on the address bar or by clicking a link) the tab is closed and Chrome opened.

It uses [native messaging](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging), so I had to develop a native application to open Chrome. I chose Go because it had 0 dependencies. Initially it supports MacOS and Windows 64bits.

## Refined - a tool for Slack
Site: [refined.chat](https://refined.chat) - Code: [github](https://github.com/g3rv4/Refined) - On my blog: [announcement]({% post_url 2018-08-26-betterslack %})

This is a browser extension (for Chrome, Firefox and Opera) that lets you personalize your Slack experience. Check [its readme](https://github.com/g3rv4/Refined/blob/master/README.md) for an updated list of features or check out [this 4 minutes video](https://www.youtube.com/watch?v=gyZR-5_JVqQ) where I demo it.

[Here you can read my initial post announcing it]({% post_url 2018-08-26-betterslack %})... it was an... experience :) luckily, it's broadly available now.

## Traducir
Site: [traducir.win](https://traducir.win) (or [its Japanese version](https://ja.traducir.win)) - Code: [github](https://github.com/g3rv4/Traducir)

It's a site that helps the Stack Overflow international communities manage the translation of Stack Overflow. It interacts with the Transifex API, authenticates with Stack Overflow's OAuth and sends web push notifications. You can see [a webcast we did about it](https://www.youtube.com/watch?v=WbpoWXctN3Y) with JuanM.

## RandomForest
Nuget: [RandomForest](https://www.nuget.org/packages/RandomForest/) - Code: [github](https://github.com/g3rv4/RandomForest) - On my blog: [write up]({% post_url 2018-07-18-csharp-random-forest %})

A tiny library to productionize R random forests in C#. You basically build your model entirely on R, verify its properties and write reports with it. This library helps run those models in C#.

## simple-redirect
Code: [github](https://github.com/g3rv4/simple-redirect) - On my blog: [write up]({% post_url 2017-01-20-nice-urls %})

A python project that lets me handle redirects by doing pushes to a repo. It's extensible so that you can do whatever you want once you detect an update (like... clearing a cache). It may be time to switch this to netlify, since they have [basically the same feature](https://www.netlify.com/docs/redirects/).

## hide-slow-splits
Code: [github](https://github.com/g3rv4/hide-slow-splits) - On my blog: [write up]({% post_url 2016-08-03-hide-slow-splits-garmin-connect-extension %})

A chrome extension that lets you hide slow splits on running activities on Garmin Connect... like if you're running intervals and want to see what your numbers would be if you didn't rest.

This extension doesn't modify your data on Garmin, it only modifies the way you see it.
