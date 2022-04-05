---
layout: post
title: "A plan for my secrets"
date: "2022-04-04 21:00:00 -0300"
---
I use 1password for all my secrets. What would happen if I forgot my master key? or if both my computer and phone got stolen? Up until a couple weeks, that would have been terrible.

<!--more-->

# Secrets?

I use 1Password for all my secrets. ALL of them. And I think you should do the same (it doesn't have to be 1Password, but _something_ that lets you use different passwords everywhere).

I was skeptical of their account model (I've been a customer since 2014, where standalone vaults where the only way), but I read their [white paper](https://1passwordstatic.com/files/security/1password-white-paper.pdf) and now I wish I made the switch earlier.

But this is not about 1Password... this is about having a plan for losing my computer and phone (maybe there was a fire in my apartment?) or for leaving after this information once I die to make things easier for everyone.

And I don't need to get so extreme in my examples, what if I just forgot my master password?

## Some requirements

In order to get access to my secret

* I don't want to have to remember anything (this is one of the situations I want to solve)
* I don't want to have to have anything (I want access to my secrets even if I don't have my computer & phone)
* I don't want anyone else to be able to access it unless I'm incapacitated or dead

## The approach

While reading about multi sig crypto wallets (I'm a skeptic when it comes to cryptocurrency stuff) I learned about [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing). From Wikipedia:

> Shamir's Secret Sharing (SSS) is used to secure a secret in a distributed way, most often to secure other encryption keys. The secret is split into multiple parts, called shares. These shares are used to reconstruct the original secret.
> 
> To unlock the secret via Shamir's secret sharing, a minimum number of shares are needed. This is called the threshold, and is used to denote the minimum number of shares needed to unlock the secret. An adversary who discovers any number of shares less than the threshold will not have any additional information about the secured secret-- this is called perfect secrecy. In this sense, SSS is a generalisation of the one-time pad (which is effectively SSS with a two-share threshold and two shares in total).

This is a very interesting approach... I can split my secret in multiple shares and distribute those shares across trusted people.

### Some interesting scenarios

I can generate 10 shares to distribute across 5 people:

* I'll get 3 and store them in a relatively safe location in my apartment
* I'll give 2 to people P1, P2 and P3
* I'll give 1 share to person P4

Then if I forget it, I can ask P1, P2 or P3 for the shares. 2 of them could have lost it and I'd still be able to reconstruct it.

If my apartment caught fire and I don't have my computer and phone, I can ask P2, P2, P3 and P4 for their shares. In this scenario only 1 could have lost their shares... otherwise I wouldn't be able to get to 5.

And if an attacker wanted to restore the secrets, they'd need to convince people. The beauty of this is that you can assign the shares as you deem best for your situation.

## How can I generate these secrets?

I built a thing, obviously! but if you know me, you'll know my math isn't strong enough to even understand how Shamir's secret sharing works... so I'm using [SecretSharingDotNet](https://www.nuget.org/packages/SecretSharingDotNet/).

I built a console app that lets you generate the shares and reconstruct them. You can see the code [here](https://github.com/g3rv4/SecretSplitter).

Now, this is all critical information... so you'd need to trust me and trust whoever wrote SecretSharingDotNet (and all my dependencies). That's a very high ask, so I wanted to provide folks with the ability to run this without having to trust me... and I think Docker has a neat trick. When you execute a container, you can pass `--network-none`. That ensures it can't send anything to the outer world.

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

will open Finder on `~/secretssplitted` and there you'll see your PDFs. You can see examples here, I splitted a secret in 10 parts and distributed chose `3,2,2,1` for the grouping.

* [File 1 (3 shares)](/public/secrets/group1.pdf)
* [File 2 (2 shares)](/public/secrets/group2.pdf)
* [File 3 (2 shares)](/public/secrets/group3.pdf)
* [File 4 (2 shares)](/public/secrets/group4.pdf)
* [File 5 (1 share)](/public/secrets/group5.pdf)

## Recomposing a secret

You can run exactly the same command (or leave out the `-v` part if you fancy that)... and that will ask you how many parts you have (you'll need at least 5 on my example) and it will ask you to type it.

Now... since we live in 2022, you can point your camera to the QRs, copy the content and paste it on your computer. If you use iOS + macOS, that works automatically (magic!).

## Parting thoughts

I will be revising this post, adding instructions for Windows (they're mostly the same, but mounting the volume is a bit different). I just wanted to publish this (it's been almost 2 years since I published something here) so that if I drop dead tonight my wife knows how the heck to use these wierd QR codes.