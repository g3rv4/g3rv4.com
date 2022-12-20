---
layout: post
title: "GetMoarFediverse on multi-user Mastodon instances"
date: "2022-12-20 00:00:00"
---
I moved to Mastodon and built some tools for it. In this post, I made one smarter :) If you're a #mastoAdmin of a small instance, this post is for you!

<!--more-->

I built [GetMoarFediverse](https://github.com/g3rv4/GetMoarFediverse) so that I could bring posts tagged with stuff I care about.

That was good for me, I could just hardcode the list of hashtags I follow and I'd be happy!

Now, the problem is when more people joined my server (just friends and family, but still). I want them to be able to follow hashtags and get meaningful content, even in this tiny instance.

[weedyverse.de](https://mastodonte.tech/@admin@weedyverse.de/109461386898833204) had a great idea: I can query the database directly!

It was [quite straightforward to implement](https://github.com/g3rv4/GetMoarFediverse/commit/4ccfaad15fb487834cfb8dd6cad321efeaf83e55)... so now, if you use a `config.json` like this one:

```
{
    "FakeRelayUrl": "https://fakerelay.gervas.io",
    "FakeRelayApiKey": "1TxL6m1Esx6tnv4EPxscvAmdQN7qSn0nKeyoM7LD8b9m+GNfrKaHiWgiT3QcNMUA+dWLyWD8qyl1MuKJ+4uHA==",
    "MastodonPostgresConnectionString": "Host=myserver;Username=mylogin;Password=mypass;Database=mydatabase",
    "Instances": [ "hachyderm.io", "mastodon.social" ]
}
```

Then GetMoarFediverse will index content your users are interested in. I recommend you create a read-only user for this, and if you want to restrict its privileges, it needs access to the `tag_follows` and `tags` tables.

You can create a `mastodon_read`read only user with access to those tables with these commands:

```
CREATE USER mastodon_read WITH PASSWORD 'password';
GRANT CONNECT ON DATABASE mastodon_production TO mastodon_read;
GRANT USAGE ON SCHEMA public TO mastodon_read;
GRANT SELECT ON tag_follows TO mastodon_read;
GRANT SELECT ON tags TO mastodon_read;
```
