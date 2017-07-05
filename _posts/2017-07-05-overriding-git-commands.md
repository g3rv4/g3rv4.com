---
layout: post
title: "Overriding git commands"
date: "2017-07-05 16:30:43 -0300"
---
Did you ever want `git` to do things a bit different? In my case, on one repo, I want `git push` to push to 2 remotes when not in `master`. Here's how I did it.

<!--more-->

Remember how [I said I'd be talking about different things on my blog]({% post_url 2017-03-18-why-i-blog %})? well, it's not as easy as I thought it would be... but I keep on working on it :)

While I was working on that, I was writing things I didn't want to be published or available publicly on my GitHub repo for the blog... so what I did was adding another remote to it. One in a Gogs installation that only I use, where I have my in-progress branches.

The problem with that, is that I had to do `git push github` every time I wanted to trigger a blog build, and I'd spend countless seconds (well, they weren't as many, but I felt super dumb every time) just waiting for a build that wouldn't happen. I wanted git to be smart to compensate for my dumbness. The first thing I did was creating an alias that took care of it:

```

git config alias.pu '!f() { git push origin $@ && if [ `git rev-parse --abbrev-ref HEAD` == "master" ]; then git push github $@; fi }; f'

```

This gets the job done! `git pu` pushes to both remotes if it's master, and only to Gogs otherwise. Also, it's a clean way of doing it, as it only affects this particular repository.

The problem with this approach, is that I don't want to `git pu`. I will never remember to do `git pu` and I'll be at the same place where I started.

Based [on this question](https://stackoverflow.com/q/3538774/920295), it was clear that I couldn't create a push alias and move on... but... there was [an answer](https://stackoverflow.com/a/24266749/920295) explaining how to do it using a shell alias. A shell alias wouldn't work for me, as I wanted this to be available from everywhere (so that even IDEs would have this behavior) but it worked as inspiration.

So I went the nasty route. That is... I renamed by `/usr/bin/git` to `/usr/bin/gitreal` and I created a `/usr/bin/git.sh` (and a symlink to `/usr/bin/git`) with this content:

```
#!/bin/bash
COMMAND="$1"
if [ "$COMMAND" == "" ]; then
  gitreal
  exit
fi

shift

QUERY="gitreal config --get-regexp ^alias."$COMMAND"alias"
if ( $QUERY > /dev/null ); then
  gitreal "$COMMAND"alias "$@"
else
  gitreal $COMMAND "$@"
fi
```

Whenever I write `git somecommand`, this script checks if there's an alias named `somecommandalias`. If there's, it calls it. Otherwise, it just uses `somecommand`... and that's it!

Now... there're a couple scenarios of `git push` where my original alias poops its pants... I just want it to do its magic for `git push` and `git push -f` honestly... so I ended up with this beauty as a git alias:

```

git config alias.pushalias '!f() { if [[ "$@" == "" || "$@" == "-f" ]]; then echo "Pushing to Gogs"; git push origin "$@" && if [ `git rev-parse --abbrev-ref HEAD` == "master" ]; then echo "Pushing to GitHub"; git push github "$@"; fi else git push "$@"; fi }; f'

```

And that's it! in my blog, I get things pushed automagically to where I want them... and on any other project, things work as usual.

You *may not* want to do it for very valid reasons (it's going to be fun when my git gets updated for instance) but... it works for me, and to be honest, my selfish goal here was to document it for when things go south.
