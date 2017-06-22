---
layout: post
title: Installing paramiko on Windows 8 64-bits with MinGW
date: '2014-03-22T23:04:00.000-03:00'
tags:
- ssh
- windows
- 64 bits
- paramiko
- python
- windows 8
modified_time: '2014-03-22T23:16:23.905-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-7440212568474184543
blogger_orig_url: http://blog.gmc.uy/2014/03/installing-paramiko-on-windows-8-64.html
---
Ugh... another old post, this time explaining how to make an old version of a python module work in an old version of Windows... but hey! this gave me a bunch of page views at that time!

<!--more-->
**THIS IS OLD STUFF NOTICE**: This is pretty pretty pretty old, so go ahead and keep on searching on google ;)

---
A few weeks ago, I recommended a friend Python as a great language to code... multiplatform and all that. He asked me about connecting to an SSH2 server and I told him that there were tons of libraries for everything, and that there def was one library for that.

I wasn't wrong... but when we met again, he told me he had a big headache installing any of them... I then decided to try out the one that looked best (paramiko) and wow... things can go pretty nasty... but I'd like to think that's just b/c of the C part of the world on the Windows part of the world.

I finally figured it out, and as it wasn't straightforward (much less pythonic) at all, I decided to write down my steps here... it may save a lot of hours to the next folk that wants to give it a try.

## The (general) problem
paramiko can't be easily installed on windows because it uses pycrypto... which is a C library that deals with the encryption part.

## The first approach
Their website has a link to a bunch of precompiled packages... so I gave that a try first. The right way of installing a package is [by using easy_install](https://stackoverflow.com/a/5442340/920295). It did the set up, but when I tried to import the module, it failed with the message `ImportError: DLL load failed: %1 is not a valid Win32 application.` when its code imported `winrandom`.

On their site they also say that on some 64-bits systems `winrandom` just fails, and the only option is to manually compile it. Oh, what a luck.

## Compiling it
Ok, if that's what it takes... let's try it out. Even if I have Visual Studio, I'd like to keep it out of the equation. [This answer](https://stackoverflow.com/a/21291923/920295) pointed me in the right direction, I had to do it with MinGW.

I had never used it before, but it's extremely straightforward. On the Installation Manager, select the packages

* mingw32-base
* mingw32-gcc-gcc+
* msys-base

We're also going to need another package that's not there. You should go to all packages and select `mingw32-gmp` (the dev one, triple check that you select that one).

Once those packages are selected, go to the Instalation menu and then to Apply Changes. After the setup, you should add `c:\mingw\bin;c:\mingw\mingw32\bin;C:\MinGW\msys\1.0;c:\mingw\msys\1.0\bin;c:\mingw\msys\1.0\sbin` to your path.

Now, to enter into the beautiful console, you just need to go to run (Windows + R) and write `msys`. If that doesn't open a console for you, there's probably something wrong with your path. Be sure to add it after what you already have there.

If you try `pip install pycrypto` you'll see it fails (and it's actually trying to use Visual Studio). You need to add a file named `distutils.cfg` inside `C:\Python33\Lib\distutils` (or whatever Python folder you're using). It should have
{% highlight text %}
[build]
compiler=mingw32
{% endhighlight %}

That will tell python to use mingw32 to compile whatever it needs to compile... and we're one step closer!

Unfortunately, doing `pip install pycrypto` also throws all types of errors again... at least, they're different :) The message is always `error: unknown type name 'off64_t'`... which I didn't have a clue of what it meant... but fortunately I found [this answer](https://stackoverflow.com/a/20090954/920295) on Stack Overflow. As he said, it's brutal... time to modify the `sys/types.h` file :P

Let me save you a few minutes, the same thing happens with the `off_t` type. Open the file `C:\MinGW\include\sys\types.h` and search for `off_t`. You'll find something like
{% highlight c %}
#ifndef _OFF_T_
#define _OFF_T_
typedef long _off_t;
#ifndef __STRICT_ANSI__
typedef _off_t off_t;
#endif /* __STRICT_ANSI__ */
#endif /* Not _OFF_T_ */

#ifndef _OFF64_T_
#define _OFF64_T_
typedef __int64 _off64_t;
#ifndef __STRICT_ANSI__
typedef __int64 off64_t;
#endif /* __STRICT_ANSI__ */
#endif /* ndef _OFF64_T */
{% endhighlight %}
The problem is that the compiler is setting the strict mode... but on the `types.h` file, if that mode is set, it doesn't add the `off_t` alias for the `_off_t` type (I couldn't care less about the strict mode... I just want it to run!). In order to fix it, replace that code with
{% highlight c %}
#ifndef _OFF_T_
#define _OFF_T_
typedef long _off_t;
typedef _off_t off_t;
#endif /* Not _OFF_T_ */

#ifndef _OFF64_T_
#define _OFF64_T_
typedef __int64 _off64_t;
typedef __int64 off64_t;
#endif /* ndef _OFF64_T */
{% endhighlight %}

And now... we're always declaring the aliases the `pycrypto` code uses... almost there! I'm using virtualenv, and if you have more than 1 project, you should too... but here, I'm going to just install it on the entire system to keep it simpler.

Soooo.... we're good to do `pip install paramiko` and it should work... voilá? nah, not so fast :P I ran my sample program and got `ImportError: No module named 'winrandom' `wonderful winrandom again...

This time the error was fixed by just copying `C:\Python33\Lib\site-packages\Crypto\Random\OSRNG\winrandom.pyd` into my project folder and now yeah, voilá!!!

I'm sure there's something missing on my python path or something... but I'd like to set it up just for Python 3.3... does anyone know what's the missing part? If you do, please let me know in the comments.

That's it! you should have paramiko working :) I'm not sure if it's the easiest one (I've seen a couple of wrappers, so my guess is that it isn't) or the fastest one, but I made it work on Windows!!!

You'll see that I mentioned a couple answers on SO... please go check them up and give them upvotes... it's extremely rewarding and those are guys that don't have lots of reputation, so it's triple cool that they're writing great answers.

Good luck!!!!
