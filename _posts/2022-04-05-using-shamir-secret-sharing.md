---
layout: post
title: "Using Shamir Secret Sharing"
date: "2022-04-05 21:00:00"
---
Here's a little tool I built to split and recompose secrets using Shamir Secret Sharing

<!--more-->

On my [previous blog post]({% post_url 2022-04-04-a-plan-for-my-secrets %}) I wrote about why I want to use Shamir Secret Sharing and why I don't want a webapp doing it. Here I'll talk about this little thing I built.

If you know me, you'll know my math isn't strong enough to even understand how Shamir's secret sharing works... so I'm using [SecretSharingDotNet](https://www.nuget.org/packages/SecretSharingDotNet/).

I built a console app that lets you generate the shares and reconstruct them. You can see the code [here](https://github.com/g3rv4/SecretSplitter).

Now, this is all critical information... so you'd need to trust me and trust whoever wrote SecretSharingDotNet (and all my dependencies). That's a very high ask, so I wanted to provide folks with the ability to run this without having to trust me... and I think Docker has a neat trick. When you execute a container, you can pass `--network none`. That ensures it can't send anything to the outer world.

### Requirements

* Docker

### How do I run it?

So if you wanted to generate shares / reconstruct a secret **in a way that I can't send those to myself** you can run:

```

docker run --rm -v ~/secretssplitted:/var/output --network none -ti g3rv4/secretsplitter

```

And after that you'll see a prompt that lets you split a secret or put several pieces back together. If you chose to create one, running

```

open ~/secretssplitted

```

will open Finder on `~/secretssplitted` and there you'll see your PDFs. You can see examples here, I splitted a secret in 10 parts and chose `3,2,2,1` for the grouping.

* [File 1 (3 shares)](/public/secrets/group1.pdf)
* [File 2 (2 shares)](/public/secrets/group2.pdf)
* [File 3 (2 shares)](/public/secrets/group3.pdf)
* [File 4 (2 shares)](/public/secrets/group4.pdf)
* [File 5 (1 share)](/public/secrets/group5.pdf)

## Recomposing a secret

You can run exactly the same command and that will ask you how many parts you have (you'll need at least 5 on my example) and it will ask you to type it.

Now... since we live in 2022, you can point your camera to the QRs, copy the content and paste it on your computer. If you use iOS + macOS, that works automatically (magic!).

## Parting thoughts

I will be revising this post, adding instructions for Windows (they're mostly the same, but mounting the volume is a bit different). I just wanted to publish this (it's been almost 2 years since I published something here) so that if I drop dead tonight my wife knows how the heck to use these wierd QR codes.