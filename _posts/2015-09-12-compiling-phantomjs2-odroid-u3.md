---
layout: post
title: Compiling PhantomJS 2.0 on an odroid U3
date: '2015-09-12T21:46:00.001-03:00'
tags:
- phantomjs
- compile
- odroid
modified_time: '2015-09-12T21:46:55.383-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-8590300574868217387
blogger_orig_url: http://blog.gmc.uy/2015/09/compiling-phantomjs-20-on-odroid-u3.html
---
The title says it all... c++ compilation fun times!
<!--more-->

As I was working on a project to selectively use Unblock Us on my network devices, I wanted to host the whole thing in my odroid... but compiling it right out of the box didn't work for me. Also, for some reason [this precompiled binary](https://community.scaleway.com/t/phantomjs-2-0-0-binary-for-armv7/764) didn't work for me. Doing this

{% highlight bash %}
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.0.0-source.zip
unzip phantomjs-2.0.0-source.zip;
cd phantomjs-2.0.0
nohup ./build.sh --confirm > build.sh.out 2> build.sh.err &
{% endhighlight %}

Took a whole a lot of time and eventually failed with a bunch of cryptic errors... but when I checked the build.sh.err file, the first one I found is

{% highlight text %}
floatmath.cpp:44:5: warning: unused parameter ‘argv’ [-Wunused-parameter]
g++: error: unrecognized command line option ‘-msse2’
make: *** [sse2.o] Error 1
{% endhighlight %}

It makes sense, as SSE2 is an extension that's not available on ARM... then I ran

{% highlight bash %}
find src -type f -print0 | xargs -0 sed -i 's/-msse2//g'
{% endhighlight %}

I tried compiling again, but it failed... and the problem was pretty stupid (and it took me a while to figure it out)... the previous .o files were still around, so the make process wasn't building them again... sooo I completely deleted the folder, unzipped the file, removed the `msse2` flag and this time it worked flawlessly!

Here are all the steps in an easy-to-copy format

{% highlight bash %}
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.0.0-source.zip
unzip phantomjs-2.0.0-source.zip<br />cd phantomjs-2.0.0
find src -type f -print0 | xargs -0 sed -i 's/-msse2//g'
nohup ./build.sh --confirm > build.sh.out 2> build.sh.err &
{% endhighlight %}

Just be prepared for it to last a while. If you want to just use my version, you can [find it here](https://github.com/g3rv4/phantomjs-v2.0.0-odroidu3) (it includes the sources and the build output).

You can retrieve it by doing

{% highlight bash %}
curl -OL https://github.com/g3rv4/phantomjs-v2.0.0-odroidu3/raw/master/phantomjs-2.0.0.compiled.tgz.000
curl -OL https://github.com/g3rv4/phantomjs-v2.0.0-odroidu3/raw/master/phantomjs-2.0.0.compiled.tgz.001
curl -OL https://github.com/g3rv4/phantomjs-v2.0.0-odroidu3/raw/master/phantomjs-2.0.0.compiled.tgz.002
cat phantomjs-2.0.0.compiled.tgz.00? > phantomjs-2.0.0.compiled.tgz
tar -xzf phantomjs-2.0.0.compiled.tgz
{% endhighlight %}

The executable file is `phantomjs-2.0.0/bin/phantomjs`
