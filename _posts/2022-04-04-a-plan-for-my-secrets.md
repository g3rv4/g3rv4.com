---
layout: post
title: "A plan for my secrets"
date: "2022-04-04 21:00:00"
---
I use 1password for all my secrets. What would happen if I forgot my master key? or if both my computer and phone got stolen? Up until a couple weeks, that would have been terrible.

<!--more-->

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

I searched for tools, and I found [this nice and offline tool](https://iancoleman.io/shamir/) that does what I want. It had a couple downsides, the most important one is that any extensions would be able to see what I'm writing there (or what people that need to reconstruct the secret have). I'd also need to store the html somewhere so that if the site goes down I can still use it.

Also, I plan to share this with people living in different places in paper. Having to type back all these strings (that get really long) is not awesome.

So I built a thing! and it was just putting together libraries that do the real work, but isn't that programming?

My requirement is that:

* It can be easily guaranteed that it doesn't make external calls, ideally without having to inspect the code
* It will continue running for a long time
* Assuming a browser is compromised by an extension, that shouldn't matter (I consider all extensions I didn't build insecure)
* Needs to work on x86 processors and on the fancy M1

## Alright, where can I see this tool?

On my [next blog post!]({% post_url 2022-04-05-using-shamir-secret-sharing %})