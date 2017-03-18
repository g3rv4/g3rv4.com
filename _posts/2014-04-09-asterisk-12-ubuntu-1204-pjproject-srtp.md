---
layout: post
title: Installing Asterisk 12 on Ubuntu 12.04 with pjproject and SRTP
description: "Before entering here, check out what's the latest Asterisk, what's the latest Ubuntu and give _that_ a try. This is probably obsolete now, you've been warned."
date: '2014-04-09T23:46:00.003-03:00'
tags:
- srtp
- pjproject
- ubuntu 12.04
- asterisk
- WebRTC
modified_time: '2014-06-13T11:32:30.071-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-2588114711300792633
blogger_orig_url: http://blog.gmc.uy/2014/04/asterisk-12-ubuntu-1204-pjproject-srtp.html
---
A post about what you had to do at that time to install an old version of Asterisk in an old version of Ubuntu. Why is it valuable you ask? I don't have a good answer.

<!--more-->
**THIS IS OLD STUFF NOTICE**: Go install the current version of Asterisk in the current version of Ubuntu using the current method.

---
Today I had to install an Asterisk that could deal with WebRTC. I read [on the Asterisk wiki](https://wiki.asterisk.org/wiki/display/AST/Asterisk+WebRTC+Support) that in order for it to work, it needs to be installed with pjproject and SRTP. Until today, I always used `menuselect` to choose what to install, but these two buddies are kind of different... they aren't selectable unless you install them before Asterisk.

As I couldn't find a guide with the steps to follow (took bits of information from different sources and figured some things by myself) here's what worked for me. I took a lot from "Asterisk 12 on a Raspberry Pi \| MatthewJordan.net" (now offline) so thanks to Matthew ;) I also enjoyed how he shows what he's doing, so I'm copying that from there too.

## Install the Asterisk dependencies and more stuff we're going to need (I'm also installing libbfd-dev b/c want to use BETTER_BACKTRACES)
{% highlight text %}
gmc@blog:~$ sudo apt-get install build-essential libsqlite3-dev libxml2-dev libncurses5-dev libncursesw5-dev libiksemel-dev libssl-dev libeditline-dev libedit-dev curl libcurl4-gnutls-dev libjansson4 libjansson-dev libuuid1 uuid-dev libxslt1-dev liburiparser-dev liburiparser1 git autoconf libbfd-dev -y

Reading package lists... Done
...
Processing triggers for libc-bin ...
ldconfig deferred processing now taking place

gmc@blog:~$
{% endhighlight %}

## Install libsrtp
We first download and decompress the files (thanks to Alexander Traud for pointing me out that libsrtp moved to github)
{% highlight text %}
gmc@blog:~$ cd ~
gmc@blog:~$ git clone https://github.com/cisco/libsrtp.git
Cloning into 'libsrtp'...
remote: Reusing existing pack: 2037, done.
remote: Total 2037 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (2037/2037), 3.17 MiB | 1.30 MiB/s, done.
Resolving deltas: 100% (1249/1249), done.
Checking connectivity... done.
gmc@blog:~$
{% endhighlight %}

Then configure and make it!... I figured out the flags for `./configure` by trial and error (at one point, Asterisk complained about the `-fPIC` flag, so I just added it)  
{% highlight text %}
gmc@blog:~$ cd libsrtp/
gmc@blog:~/libsrtp$ autoconf
gmc@blog:~/libsrtp$ ./configure CFLAGS=-fPIC --prefix=/usr

checking for ranlib... ranlib
checking for gcc... gcc
checking whether the C compiler works... yes
...
config.status: creating doc/Makefile
config.status: creating crypto/include/config.h

gmc@blog:~/libsrtp$ make

gcc -DHAVE_CONFIG_H -Icrypto/include -I./include -I./crypto/include  -fPIC -c srtp/srtp.c -o srtp/srtp.o
gcc -DHAVE_CONFIG_H -Icrypto/include -I./include -I./crypto/include  -fPIC -c crypto/cipher/cipher.c -o crypto/cipher/cipher.o
gcc -DHAVE_CONFIG_H -Icrypto/include -I./include -I./crypto/include  -fPIC -c crypto/cipher/null_cipher.c -o crypto/cipher/null_cipher.o
...
gcc -DHAVE_CONFIG_H -Icrypto/include -I./include -I./crypto/include  -fPIC -L. -o test/rtpw test/rtpw.c test/rtp.c libsrtp.a  -lsrtp
Build done. Please run 'make runtest' to run self tests.

gmc@blog:~$  
{% endhighlight %}

I saw that there was a make runtest... it's pretty cool :) here's what you should see  
{% highlight text %}
gmc@blog:~/libsrtp$ make runtest

gcc -DHAVE_CONFIG_H -Icrypto/include -I./include -I./crypto/include  -fPIC -c crypto/math/math.c -o crypto/math/math.o
crypto/math/math.c: In function 'bitvector_print_hex':
crypto/math/math.c:854:5: warning: format not a string literal and no format arguments [-Wformat-security]
...
libsrtp test applications passed.
...
libcryptomodule test applications passed.
make[1]: Leaving directory `/home/test/srtp/crypto'

gmc@blog:~$  
{% endhighlight %}

and then... just install it  
{% highlight text %}
gmc@blog:~/srtp$ sudo make install

/usr/bin/install -c -d /usr/include/srtp
/usr/bin/install -c -d /usr/lib
cp include/*.h /usr/include/srtp   
cp crypto/include/*.h /usr/include/srtp
if [ -f libsrtp.a ]; then cp libsrtp.a /usr/lib/; fi

gmc@blog:~$  
{% endhighlight %}

## Install pjproject
Clone the project from its git repo  
{% highlight text %}
gmc@blog:~/srtp$ cd ~
gmc@blog:~$ git clone https://github.com/asterisk/pjproject pjproject

Cloning into 'pjproject'...
remote: Reusing existing pack: 3636, done.
remote: Total 3636 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (3636/3636), 7.76 MiB | 2.05 MiB/s, done.
Resolving deltas: 100% (1167/1167), done.

gmc@blog:~$  
{% endhighlight %}

Configure and make it... again, after a few attempts, I got here  
{% highlight text %}
gmc@blog:~$ cd pjproject/
gmc@blog:~/pjproject$ ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --with-external-srtp

checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking target system type... x86_64-unknown-linux-gnu
...
Further customizations can be put in:
  - 'user.mak'
  - 'pjlib/include/pj/config_site.h'
The next step now is to run 'make dep' and 'make'.

gmc@blog:~/pjproject$ make

for dir in pjlib/build pjlib-util/build pjnath/build third_party/build pjmedia/build pjsip/build pjsip-apps/build ; do \
  if make  -C $dir all; then \
      true; \
...
make[2]: Leaving directory `/home/test/pjproject/pjsip-apps/build'
make[1]: Leaving directory `/home/test/pjproject/pjsip-apps/build'

gmc@blog:~/pjproject$ sudo make install

mkdir -p /usr/lib/
...
sed -e "s!@PJ_LDLIBS@!-lpjsua -lpjsip-ua -lpjsip-simple -lpjsip -lpjmedia-codec -lpjmedia -lpjmedia-videodev -lpjmedia-audiodev -lpjmedia -lpjnath -lpjlib-util  -lgsmcodec -lspeex -lilbccodec -lg7221codec  -lsrtp -lpj -luuid -lm -lrt -lpthread  -lcrypto -lssl!" | \
sed -e "s!@PJ_INSTALL_CFLAGS@!-I/usr/include -DPJ_AUTOCONF=1 -O2 -DPJ_IS_BIG_ENDIAN=0 -DPJ_IS_LITTLE_ENDIAN=1 -fPIC!" &gt; //usr/lib/pkgconfig/libpjproject.pc

gmc@blog:~$  
&nbsp;</pre>That should be it! this is an extra step to verify that's correctly set up  
<pre class="brush: bash">&nbsp;
gmc@blog:~/pjproject$ pkg-config --list-all | grep pjproject
libpjproject     libpjproject - Multimedia communication library

gmc@blog:~$  
{% endhighlight %}

Done! pjproject is installed! just one more thing...

## Install Asterisk
Download an decompress...  
{% highlight text %}
gmc@blog:~/pjproject$ cd ~
gmc@blog:~$ wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-12-current.tar.gz

--2014-04-09 21:46:57--  http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-12-current.tar.gz
Resolving downloads.asterisk.org (downloads.asterisk.org)... 76.164.171.238, 2001:470:e0d4::ee
Connecting to downloads.asterisk.org (downloads.asterisk.org)|76.164.171.238|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 56483961 (54M) [application/x-gzip]
Saving to: `asterisk-12-current.tar.gz'
100%[========================================================================================================================&gt;] 56,483,961  10.6M/s   in 5.9s     
2014-04-09 21:47:03 (9.10 MB/s) - `asterisk-12-current.tar.gz' saved [56483961/56483961]

gmc@blog:~$ tar -xzf asterisk-12-current.tar.gz
gmc@blog:~$  
{% endhighlight %}

Configure and make menuselect...  
{% highlight text %}
gmc@blog:~$ cd asterisk*
gmc@blog:~/asterisk-12.1.1$ ./configure --with-pjproject --with-ssl --with-srtp

checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking for gcc... gcc
...
configure: build-cpu:vendor:os: x86_64 : unknown : linux-gnu :
configure: host-cpu:vendor:os: x86_64 : unknown : linux-gnu :

gmc@blog:~/asterisk-12.1.1$ make menuselect
CC="cc" CXX="" LD="" AR="" RANLIB="" CFLAGS="" LDFLAGS="" make -C menuselect CONFIGURE_SILENT="--silent" cmenuselect
make[1]: Entering directory `/home/test/asterisk-12.1.1/menuselect'
gcc  -g -D_GNU_SOURCE -Wall   -c -o menuselect.o menuselect.c

...
{% endhighlight %}

This is where you can see, under Resource Modules, that we have the `res_pjsip_*` modules enabled and `res_srtp` enabled too... you can do changes and tune  your Asterisk how you like and quit by hitting x (that's save and  quit)... then, we only have to...
{% highlight text %}
gmc@blog:~/asterisk-12.1.1$ make

Generating embedded module rules ...
   [CC] astcanary.c -&gt; astcanary.o
   [LD] astcanary.o -&gt; astcanary
...
 +--------- Asterisk Build Complete ---------+
 + Asterisk has successfully been built, and +
 + can be installed by running:              +
 +                                           +
 +                make install               +
 +-------------------------------------------+

gmc@blog:~/asterisk-12.1.1$ sudo make install

Installing modules from channels...
Installing modules from pbx...
...
 +---- Asterisk Installation Complete -------+
 +                                           +
 +    YOU MUST READ THE SECURITY DOCUMENT    +
 +                                           +
 + Asterisk has successfully been installed. +
 + If you would like to install the sample   +
 + configuration files (overwriting any      +
 + existing config files), run:              +
 +                                           +
 +                make samples               +
 +                                           +
 +-----------------  or ---------------------+
 +                                           +
 + You can go ahead and install the asterisk +
 + program documentation now or later run:   +
 +                                           +
 +               make progdocs               +
 +                                           +
 + **Note** This requires that you have      +
 + doxygen installed on your local system    +
 +-------------------------------------------+

gmc@blog:~$  
{% endhighlight %}

If you're like me and want it to just set up the init.d scripts (so that a simple service asterisk start works) you can do  
{% highlight text %}
gmc@blog:~/asterisk-12.1.1$ sudo make config

 Adding system startup for /etc/init.d/asterisk ...
   /etc/rc0.d/K91asterisk -&gt; ../init.d/asterisk
   /etc/rc1.d/K91asterisk -&gt; ../init.d/asterisk
   /etc/rc6.d/K91asterisk -&gt; ../init.d/asterisk
   /etc/rc2.d/S50asterisk -&gt; ../init.d/asterisk
   /etc/rc3.d/S50asterisk -&gt; ../init.d/asterisk
   /etc/rc4.d/S50asterisk -&gt; ../init.d/asterisk
   /etc/rc5.d/S50asterisk -&gt; ../init.d/asterisk

gmc@blog:~$  
{% endhighlight %}

And if you're just getting started and want to see some samples...  
{% highlight text %}
gmc@blog:~/asterisk-12.1.1$ sudo make samples

Installing adsi config files...
/usr/bin/install -c -d "/etc/asterisk"
Installing configs/asterisk.adsi
...
Installing file phoneprov/polycom.xml
Installing file phoneprov/snom-mac.xml

gmc@blog:~$  
{% endhighlight %}

And that's it! Congrats! You have what should be a WebRTC compatible Asterisk :)

Here are all the commands without their outputs so that you can run everything without copy/pasting one by one (and b/c I'm sure I'm going to do it again and don't want to remove the responses :P)
{% highlight text %}
# dependencies
sudo apt-get install build-essential libsqlite3-dev libxml2-dev libncurses5-dev libncursesw5-dev libiksemel-dev libssl-dev libeditline-dev libedit-dev curl libcurl4-gnutls-dev libjansson4 libjansson-dev libuuid1 uuid-dev libxslt1-dev liburiparser-dev liburiparser1 git autoconf libbfd-dev -y

# srtp
cd ~
git clone https://github.com/cisco/libsrtp.git
cd libsrtp/
autoconf
./configure CFLAGS=-fPIC --prefix=/usr
make

# check that the tests pass
make runtest

sudo make install

# pjproject
cd ~
git clone https://github.com/asterisk/pjproject pjproject
cd pjproject/
./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --with-external-srtp
make
sudo make install

# the following command should return
# libpjproject     libpjproject - Multimedia communication library
pkg-config --list-all | grep pjproject

# asterisk
cd ~
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-12-current.tar.gz
tar -xzf asterisk-12-current.tar.gz
cd asterisk*
./configure --with-pjproject --with-ssl --with-srtp

# after this command, you can select what you want on your Asterisk
make menuselect

make
sudo make install

# if you want the init.d scripts created
sudo make config
{% endhighlight %}
