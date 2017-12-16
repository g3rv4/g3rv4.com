---
layout: post
title: "Tweetbot feature request: Real Time tweet curation"
date: "2017-12-16 12:00:00 -0300"
tags:
- noindex
---
I would love to curate my tweets in real time :)

<!--more-->
# Why
I follow lots of accounts. Some of them are prolific tweeters. Others are news outlets (that like to tweet the same news over and over with different copy to see what converts better). Others I only care about what they say about certain subject but not others. And no matter who it is, I really really really don't care about soccer.

This makes it really hard for me to read _only_ about the things I care about on Tweetbot. Right now, I can mute certain words. That works... sometimes. And definitely doesn't help with the duplicate tweets problem.

# Alternative solution
So far, what I did for the news problem was creating a Twitter bot that retweets the news that I care about and has some heurisitcs to check if a tweet is a duplicate of another one. That works perfectly fine, but I can't do that with my friends' accounts. Having a bot that retweets a lot gets kind of noisy (notification-wise).

# Feature request
Let me set up one (or multiple) endpoints for you to check if a tweet should be displayed. The implementation details are definitely up to you, but I imagine this as a websockets server (or an http server) that receives the tweet id right before showing it and decides if the tweet has to be showed or not.

The app would be connected directly to this service (or be the one doing the requests)... and if it times out (a timeout that could be defined by the user), the tweet could be displayed.

I'm thinking this could potentially be a marketplace, where I can discover new filters and people that maintain crazy ML models that filter out the noise.

# Opportunity
What if this was a paid feature? I'd absolutely pay to enable that... even a subscription (I'm honestly a bit concerned about you not making a steady income from the app I love the most in my phone).

Thanks for reading, and even if you totally ignore the feature request, know that I love you <3
