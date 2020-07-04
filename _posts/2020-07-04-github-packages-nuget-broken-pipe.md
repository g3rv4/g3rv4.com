---
layout: post
title: "Pushing to GitHub Packages Nuget repository: Fixing broken pipe"
date: "2020-07-04 09:00:00 -0300"
---
And... almost a year since I switched to Azure Pipelines, I'm now building with GitHub Actions, and pushing to their Nuget package repository. I got this annoying error and I'm blogging about how to fix it.

<!--more-->

I started migrating all my projects to use [GitHub Actions](https://github.com/features/actions) (and deploy them with [Octopus Deploy](https://octopus.com/)). Now, for reasons I'll hopefully explain later (if I ever get to document my approach) I'm pusing the results of my builds to [GitHub Packages](https://github.com/features/packages).

I'm building my projects in Ubuntu containers, so in order to push to Nuget, I was using `dotnet nuget push`. Doing so worked most of the times, but I usually got

```

error: Error while copying content to a stream.
error:   Unable to read data from the transport connection: Broken pipe.
error:   Broken pipe

```

That wasn't awesome, so I ended up doing this...

```

until dotnet nuget push $BASE_PATH/$PACKAGE.$VERSION.nupkg --source "github" --skip-duplicate; do sleep 3; done

```

which worked fine most of the time except when uploading a big package.

I read [this GitHub issue](https://github.com/NuGet/Home/issues/8580) and it was exactly the same thing I was seeing. But the conversation was distracting. I wanted to know how to fix it. I bit the bullet, expanded the 40+ messages, and eventually found [mikkeljohnsen's answer](https://github.com/NuGet/Home/issues/8580#issuecomment-549719665) that provides a great workaround. In my case, I don't want to make it verbose so this is what I ended up using.

```

curl -X PUT -u "$GITHUB_ACTOR:${{ secrets.GITHUB_TOKEN }}" -F package=@$BASE_PATH/$PACKAGE.$VERSION.nupkg https://nuget.pkg.github.com/$PACKAGE/

```

Now pushes work 100% of the time.

PS: It sounds like Stack Overflow should solve the "useful answer buried in a long GitHub issue" as it did with forums 10 years ago.
