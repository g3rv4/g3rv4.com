---
layout: post
title: "Bye bye BetterSlack"
date: "2018-08-29 01:00:00 -0300"
description: "I wrote BetterSlack and Slack asked me to take it down. Find the story here."
---
Less than 2 days after announcing BetterSlack, I got an email from somebody on Slack's Legal team informing me that the extension was in violation of their Acceptable Use Policy.

Injecting javascript into their website is a no-no according to them. So I unshipped it (spoiler alert: we worked it out and it's back under a new name).

<!--more-->

**UPDATE Sept 14th 2018:** After talks with folks from Slack and a rename... Refined (fka Taut) (fka BetterSlack) is now live back!!! You can find on Chrome, Firefox and Opera. See more details at [refined.gervas.io](https://refined.gervas.io).

I feel like I need an un-unshipping gif now.

---

On August 26th 2018, I [announced BetterSlack]({% post_url 2018-08-26-betterslack %}). On August 30th, [I unpublished it from the chrome web store](https://twitter.com/g3rv4/status/1035256960038449152).

![silver lining 1: I get to use this image](/public/images/unship.gif)

# Their email

On Aug 28th, I got an email from someone in Slack's Legal team. Here's what it says:

> Hello,
>
> My name is XXX and I work at Slack on the Legal team. One of the things I do here is help developers and companies understand how to stay in compliance with our policies when building things for Slack.
>
> I'm writing today regarding your BetterSlack application (described here: https://g3rv4.com/2018/08/betterslack). Based on your description of the Chrome extension, your application is in violation of a number of provisions set forth in Slack's Acceptable Use Policy (https://slack.com/acceptable-use-policy).
>
> In particular, we state that you may not...
>
> "...attempt to reverse engineer, decompile, hack, disable, interfere with, disassemble, modify, copy, translate, or disrupt the features, functionality, integrity, or performance of the Services (including any mechanism used to restrict or control the functionality of the Services), any third party use of the Services, or any third party data contained therein (except to the extent such restrictions are prohibited by applicable law);
>
> Injecting javascript into Slack via Chrome extension can have an impact on the privacy and security of our customers and our product. Furthermore, this can create reliability issues when we ship product updates.
>
> In order to remedy this, we ask that you please modify your product so that you are not forcing your own code into our services. We have opened a number of channels for the developer community to build tools that improve their experience with Slack. We encourage you to utilize those channels to their fullest extent.
>
> Furthermore, and secondary to the issue stated above, we must also ask that you choose a new name for your project. It is okay to be descriptive about what your product does, but we prefer that you do not include the word "Slack" in your product's name.
>
> Please understand that we are not interested in squelching creativity or stopping people from encouraging the use of our platform. We simply need to make sure that everyone is building things in a manner that prioritizes the security of our customer's data and is respectful of their experience with Slack.
>
> Please respond to this message to acknowledge that you have received it. If you can resolve the matters specified above in the next seven days, that would be excellent. If you anticipate that it will take longer, please let us know. I've cc'd our Legal alias so that in the event that I am unable to respond, one of our product counsels will be able to provide any necessary assistance.
>
> Best regards,

I kind of imagined that the name could be an issue, and I totally understand that. I checked how other non-official products were using it and it didn't seem to be significantly different. However, it's totally understandable and I'd be happy to change it.

The real problem here, is with this sentence: "we ask that you please modify your product so that you are not forcing your own code into our services". That effectively kills the extension, since they don't provide a way ([and have no plans of providing a way](https://twitter.com/SlackHQ/status/1033369811965886464)) for a third party to curate the user's experience in this way.

# What makes me sad

I built it for me (+ family, friends and colleagues) because it really makes Slack better for me. I thought that sharing it through the chrome web store would make it easier for them to install it and, if I could share it with the world, then we all win! what if another dev or two contributed? that would be great, right?

BetterSlack makes me like Slack more (or... full disclosure: dislike Slack less). What makes me sad is that it got lots of traction (more than any personal project I worked on before) because it solves real people's problems and Slack missed an opportunity here.

They missed the opportunity of engaging with the community *that actually wants to make their product better*. I'm still excited about adding more features to BetterSlack (taking a couple ideas from other systems... like bonfire). The dream goal was that maybe... maybe... Slack could incorporate some of that into their product? in an ideal world, BetterSlack wouldn't exist! but not because of their Legal Team, but because of their Product Team.

To show what I mean about the missed opportunity, check how [Jon Ericson provided feedback on a user's app that was putting Stack Overflow in the menu bar](https://stackapps.com/a/8016/48463). Check how [GitHub engaged with the community of RefinedGithub](https://github.com/refined-github/refined-github/issues/1469) (which is an extension that injects javascript on GitHub's site... and they're ok with). GitHub's case is **exactly the same as this one**... isn't it telling that they're not concerned about how they affect their user's privacy and security? Or Atlassian... who... [are providing an extension author the heads up on changes so that they can be prepared for them](https://jira.atlassian.com/browse/BCLOUD-15474)?

What is it going to happen? I'm going to continue working on it, but I won't be able to distribute it... what worries me is that if anybody *actually wants to steal users' credentials* there's now an easy way. Just edit my extension, do whatever you want and you'll get people installing it.

Also... what's the deal with the thousand extensions that already inject js everywhere? where's the limit? would they sue Tampermonkey? this extension was born as a bunch of userscripts.

As I don't want problems, I'll take it down. Sad, and even more convinced that Slack is not a product I'd use if I had a choice. It's funny how at my previous company I was Slack's advocate (in my defense, we were using Skype before).

# Silver linings

1. I got to use the unship gif that I got in love with when [Stack Overflow Teams unshipped](https://meta.stackoverflow.com/q/330427/920295) (not to be confused with [Stack Overflow for Teams](https://stackoverflow.co/teams/), which is alive and amazing)
2. The encouragement that I received is amazing. People I admire a lot. People I don't know. Thank you all, it really made a difference on a moment that I needed it.
3. I got to be in the front page of HN! A LOT! [Check the front page stories from that day :)](https://news.ycombinator.com/front?day=2018-08-29). I got 43k unique visitors in 24 hours that downloaded 74GB and it all worked alright. Thanks Cloudflare, you rock.
4. The project already has forks. There's no stopping it.
5. I'm going to continue improving the extension until I don't need to use Slack anymore. I have more ideas... like threaded conversations, where you hover on the reply and it highlights the other messages in the same convo. I would have loved to ship it.
6. I'm pretty sure that by now, somebody at Slack (in addition to their Legal Team) is aware of the situation. I'm hopeful we can work something out once I take the extension down.

# Do you want to help?

Keep on hacking stuff, keep on modding whatever you see that doesn't make sense. Originally I said we should be asking Slack to improve things, but honestly... I think we all have better things to do with our time.

This post was just to get it out of my system, and to let me focus on what's important. A way to channel my emotions.

# I love you all

Really, it was an incredible experience to receive your support.

Thanks for reading.
