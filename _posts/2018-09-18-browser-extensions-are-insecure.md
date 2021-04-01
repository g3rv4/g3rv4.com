---
layout: post
title: "Want a secure browser? Disable your extensions"
date: "2018-09-18 10:00:00 -0300"
description: "How extensions are extremely insecure and free to leak your data. Do you check their source code? Even when they are silently updated?"
---
While working on Refined (my browser extension to personalize Slack) I realized just how easy it is for an extension to go rogue. In this article I explain how a malicious extension dev could really steal your data.

<!--more-->

On Sept 14th I renamed BetterSlack to Taut (and later to [Refined](https://refined.chat)) and shipped it to the Chrome Web Store. The extension had been live for 2 or 3 days and then it was unpublished for a couple weeks... but users continued using it. On this new version, I was including a couple bugfixes, a new feature, the rename and a warning notice. That looks like this:

![Taut warning](/public/images/tautWarning.png)

After publishing it, this is what the uninstall chart looked like

![uninstalls](/public/images/uninstalls.png)

The message was quite clear... and I get that it's scary that a developer could steal all your Slack data... but weren't users aware of this risk?

@shog9 had an interesting insight (one I never thought about):

> Changing the name at the same time made that explanation a lot scarier than it would've been otherwise.
>
> Like... I didn't know what it was until I opened the GitHub page.

[Source: twitter](https://twitter.com/shog9/status/1040977127238119429)

So yeah, I could have spoken to the fact that BetterSlack is now Taut (especially since I know if it's a new install or an update)... but that ship had sailed. And, even if I handled that better, the whole point of this post is to show that **you can't trust what an extension tells you**!

## How bad can it be? What's the worst that could happen?

Well, it all comes to the permissions an extension asks for. Which is kind of nice, since the user must choose to grant them.

The problem is that once you give an extension permission to do something, it's going to be able to do it until you uninstall it. So you go install an extension and you see a message like this one:

![permissions](/public/images/permissions.png)

I'm purposely trying to avoid commenting on extensions other than my own. In this case, Taut is asking permissions to:

* Read and change your data on all slack.com sites

Why does it need to read and change your data on slack.com? Well, it lets you personalize Slack... so it needs to inject Javascript to actually do those personalizations.

That makes sense.

In Firefox, it also shows the permission "Access browser tabs"... why? I'm asking permissions to use the `tabs` namespace because once you save your preferences, I reload all your Slack workspaces to apply the changes.

If I saw that, it would look weird to me. And this happens a lot... we are used to seeing the permissions and thinking "yeah... it kind of makes sense".

### What can an extension do with "read and change your data"?

It can do anything. It can read everything. It can leak anything that the Javascript on the page has access to. If my extension injected a script that sent data to my domain (not listed on the permissions the user saw) YOU WOULD NEVER KNOW unless you kept monitoring the network tab in the DevTools.

### Oh, but it's alright... it's open source!

The fact that the extension is open source is great. You can contribute to it, inspect the code and search for malicious things by yourself. But... **nothing guarantees that what you see on GitHub is what the developer uploaded to the store**. If I were building a malicious extension, I wouldn't add the malicious code to GitHub.

So... if you wanted to be sure that the code you see is what's running on your machine, you could either:

* Manually build the extension from GitHub and [load it unpacked](https://developer.chrome.com/docs/extensions/mv3/getstarted/#manifest)
* Use an extension like [Chrome extension source viewer](https://chrome.google.com/webstore/detail/chrome-extension-source-v/jifpbeccnghkjeaalbbjmodiffmgedin) to view the source code of the application that's on the store (it could be minified though). Of course, that extension could lie to you (this extension could hide the malicious code of other extensions, giving you a false sense of security since… you can't trust extensions! :P)

### I've checked the extension and it's alright, so it's safe!

Well... if you've installed it via the store, the developer can push updates to the store and your browser will run the new code happily. Browsers handle extension approval in very different ways (I'm not aware of Chrome checking the code extension at all, Firefox [pre-approves addons based on automatic checks](https://blog.mozilla.org/addons/2017/09/21/review-wait-times-get-shorter/) and Opera manually reviews them… which means [their moderation process takes time](https://forums.opera.com/topic/16609/very-long-extension-moderation-process)).

In the case of Chrome or Firefox, as soon as I publish a new version, my browsers update it in no more than 40 minutes. Would this be the case if my extension had malicious code? I have reasons (and examples) to believe that the answer is yes.

Because of this, a great attack vector is:

* Create a useful extension. Ideally one that justifies the "Read and change all your data on the websites you visit" permission.
* Work on it and get lots of users
* Update a new version that leaks data on the sites the attacker is interested in

Of course, one can report abuse and this behavior would totally qualify to have the extension removed. However... how long would users take to catch on? And what would happen in the interim?

In the case of [the MEGA nz extension hack](https://www.zdnet.com/article/mega-nz-chrome-extension-caught-stealing-passwords-cryptocurrency-private-keys/), 5 hours passed between the initial breach and the moment Google took the extension down.

## So... how can we use extensions in a secure way?

I think the whole model is broken. If devs can push code to thousands of users without any kind of review or notice... we really shouldn't use extensions that can "read and change our data" on sites we care about.

All the extensions that can read and change your data can read and change *and leak* your data in those domains.

Installing an extension is basically trusting a random person on the internet to behave. I guess it's kind of nice that we do this exercise of trust a daily basis :shrug:

Also, after I finished this article, I started searching for exploited extensions and people warning about the risks extensions introduce... it looks like (unsurprisingly) I'm not the first one to write about it:

* [How I'd steal your passwords](https://tgvashworth.com/2012/09/24/how-id-steal-your-passwords.html)
* [Why browser extensions are dangerous](https://iconnectdots.com/2017/08/browser-extensions-dangerous.html)

Unfortunately, How-to Geek ran a "[How to Make Sure a Chrome Extension is Safe Before Installing It](https://www.howtogeek.com/347429/how-to-make-sure-a-chrome-extension-is-safe-before-installing-it/)" that gives users a false sense of security... their suggestions (even the most advanced: check the source code) aren’t enough. They also ran a more sane article: "[Browser Extensions Are a Privacy Nightmare: Stop Using So Many of Them](https://www.howtogeek.com/188346/why-browser-extensions-can-be-dangerous-and-how-to-protect-yourself/)". I think using as few extensions as you can and only installing those from trusted sources is good advice.

And... there are more examples of extensions doing bad stuff:

* ["Stylish" browser extension steals all your internet history](https://robertheaton.com/2018/07/02/stylish-browser-extension-steals-your-internet-history/)
* [Google Chrome extensions with 500,000 downloads found to be malicious](https://arstechnica.com/information-technology/2018/01/500000-chrome-users-fall-prey-to-malicious-extensions-in-google-web-store/) which shows you can't just trust on the number of users to determine if an extension is safe.
* [Bank-fraud malware not detected by any AV hosted in Chrome Web Store. Twice](https://arstechnica.com/information-technology/2017/08/bank-fraud-malware-not-detected-by-any-av-hosted-in-chrome-web-store-twice/)
* [Chrome Extensions Spreading Through Facebook Caught Stealing Data](https://hackernoon.com/chrome-extensions-spreading-through-facebook-caught-stealing-data-4aa9fc3b3a06) (at least now Google disabled manually installing CRX from outside their store)

## If after reading this you still want to install Refined...

Refined lets you personalize your Slack experience by doing [a bunch of things](https://github.com/g3rv4/Refined/blob/master/README.md) that I find super useful. You can get it at [refined.chat](https://refined.chat).

I built it, I won't do anything bad with it... but in the end, you need to trust me (and after all, that's exactly what I'd say if my end game was actually stealing your info).

You can always inspect the code, [build it from source](https://github.com/g3rv4/Refined#build-from-source) and load THAT on your browser.

## Thank you reviewers!

This article was reviewed by [@SaraJChipps](https://twitter.com/SaraJChipps), [@itsarnavb](https://twitter.com/itsarnavb), [@_OscarDOM](https://twitter.com/_OscarDOM), [@reyronald](https://twitter.com/reyronald), [@ianislike](https://twitter.com/ianislike), [@rikkydyke](https://twitter.com/rikkydyke) and [@3dgiordano](https://twitter.com/3dgiordano). Thank you very much folks!
