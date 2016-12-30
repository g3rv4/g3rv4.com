---
layout: post
title: 'Asterisk + Twilio: Receiving calls from twilio (Part IV)'
date: '2013-10-20T01:13:00.000-02:00'
tags:
- receiving calls
- twilio
- sip
modified_time: '2013-12-17T20:46:18.471-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-5866733829630579718
blogger_orig_url: http://blog.gmc.uy/2013/10/asterisk-twilio-receiving-calls-from.html
---
Fourth (and last) Asterisk + twilio post: Receiving calls from twilio to Asterisk.

<!--more-->
This is the fourth and last post of my Asterisk + Twilio series:

* [Asterisk + Twilio: Motivation (Part I)]({% post_url 2013-10-18-asterisk-twilio-motivation %})
* [Asterisk + Twilio: The hardware, Cisco SPA3102 and the FXO vs FXS ports (Part II)]({% post_url 2013-10-18-asterisk-twilio-hardware-cisco-spa3102 %})
* [Asterisk + Twilio: Making calls from home to twilio (Part III)]({% post_url 2013-10-19-asterisk-twilio-making-calls %})
* Asterisk + Twilio: Receiving calls from twilio (Part IV)

Aaaand now to the most interesting (and challenging) part of the journey... receiving calls from twilio to my Asterisk.

I have a twilio US number, and wand to forward incoming calls to my mobile phone. As I said on the first post of the Asterisk + Twilio series, that works just fine on twilio, but it's a little too expensive (38 cents per minute).

So, I wanted twilio to forward the call to Asterisk so that it calls me from my landline (which takes the cost down to about 15 cents + 0.25 cents per minute of the SIP call) taking the cost to less than a half.

I carefully read twilio's SIP reference, and set up a device on `sip.conf` this way
{% highlight ini %}
[myusername]
context = fromtwilio
type = user
secret = mypass
permit=107.21.222.153
permit=107.21.211.20
permit=107.21.231.147
permit=54.236.81.101
permit=54.236.96.128
permit=54.236.97.29
permit=54.236.97.135
permit=54.232.85.81
permit=54.232.85.82
permit=54.232.85.84
permit=54.232.85.85
permit=54.228.219.168
permit=54.228.233.229
permit=176.34.236.224
permit=176.34.236.247
permit=46.137.219.1
permit=46.137.219.3
permit=46.137.219.35
permit=46.137.219.135
permit=54.249.244.21
permit=54.249.244.24
permit=54.249.244.27
permit=54.249.244.28
{% endhighlight %}

Then, I had my number set up to point to a url that returned this xml
{% highlight xml %}
<Response>
  <Dial>
    <Sip username="myusername" password="mypass">sip:myext@mydomain.com</Sip>
  </Dial>
</Response>
{% endhighlight %}

As the username and password would travel here, I bought an SSL from Comodo (at $7 per year) and used twilio's signature in the message to validate the request... this way, I'd only reply to genuine requests and my replies would be encrypted by SSL. According to what I understood, twilio would send an INVITE using `myusername@something` as `From`, sending `mypass` as password and that would do the trick... but my Asterisk just returned
{% highlight text %}
[Oct 17 19:22:58] NOTICE[9150]: chan_sip.c:22614 handle_request_invite: Sending fake auth rejection for device "+1XXXXXXXXXX" <sip:+1XXXXXXXXXX@sip.twilio.com>;tag=78774647_6772d868_43fb2951-f4f9-4c80-8377-9bb50e9458ae
{% endhighlight %}

and when I inspected the SIP packages (by downloading the PCap Log from twilio... you gotta love their debug tools) I saw this
{% highlight text %}
From: "+1XXXXXXXXXX" <sip:+1XXXXXXXXXX@sip.twilio.com>;tag=78774647_6772d868_43fb2951-f4f9-4c80-8377-9bb50e9458ae
{% endhighlight %}

which definitely made it look like the username I chose wasn't being sent (at least, not in the `From`, which is where Asterisk expects it for devices with type=user).

Then, I checked the ip twilio contacted me from and changed the device to
{% highlight ini %}
[myusername]
context = fromtwilio
type = peer
secret = mypass
host = 107.21.222.153
{% endhighlight %}

To my surprise... it worked! so, it looked like I had to use type = peer and create a device per ip... but they're 23! and every device needs a different name, so I should know which IP twilio is going to use to choose the username matching the device... nope, that wouldn't fly. Then, I realized I could do this
{% highlight ini %}
[twiliocaller](!)
context = fromtwilio
type = peer
qualify=no
allowguest=yes

[twilioip-1](twiliocaller)
host=107.21.222.153

[twilioip-2](twiliocaller)
host=107.21.211.20

[twilioip-3](twiliocaller)
host=107.21.231.147

[twilioip-4](twiliocaller)
host=54.236.81.101

[twilioip-5](twiliocaller)
host=54.236.96.128

[twilioip-6](twiliocaller)
host=54.236.97.29

[twilioip-7](twiliocaller)
host=54.236.97.135

[twilioip-8](twiliocaller)
host=54.232.85.81

[twilioip-9](twiliocaller)
host=54.232.85.82

[twilioip-10](twiliocaller)
host=54.232.85.84

[twilioip-11](twiliocaller)
host=54.232.85.85

[twilioip-12](twiliocaller)
host=54.228.219.168

[twilioip-13](twiliocaller)
host=54.228.233.229

[twilioip-14](twiliocaller)
host=176.34.236.224

[twilioip-15](twiliocaller)
host=176.34.236.247

[twilioip-16](twiliocaller)
host=46.137.219.1

[twilioip-17](twiliocaller)
host=46.137.219.3

[twilioip-18](twiliocaller)
host=46.137.219.35

[twilioip-19](twiliocaller)
host=46.137.219.135

[twilioip-20](twiliocaller)
host=54.249.244.21

[twilioip-21](twiliocaller)
host=54.249.244.24

[twilioip-22](twiliocaller)
host=54.249.244.27

[twilioip-23](twiliocaller)
host=54.249.244.28
{% endhighlight %}

and even if doing `allowguest=yes` may feel insecure, you're identifying the peer by its ip... so an attacker should connect from one of those (and if the attacker had access to twilio's infrastructure... well, they could certainly make a request and get my user/pass from the original xml).

Then, after that, my xml turned into this
{% highlight xml %}
<Response>
  <Dial>
    <Sip>sip:myext@mydomain.com</Sip>
  </Dial>
</Response>
{% endhighlight %}

which also feels safer (and those U$S 7 spent on the certificate a little less worthy). And set up the extension for it on my `extensions.conf`
{% highlight ini %}
[fromtwilio]
exten => myext,1,Dial(SIP/099999999@atapstn)
{% endhighlight %}

to handle twilio's calls to that extension. This works like a charm... but I'm an absolute noobie on Asterisk, so maybe `allowguest=yes` is a vulnerability after all?

Well, and this is how I'm finishing this set of posts about Asterisk + Twilio, an experience that was extremely fun for me and I wanted to share. After this was working fine, I tweaked my logic to receive calls, so that if my Asterisk is down for whatever reason, I route the call through twilio as I used to... so the number points to an xml like this one
{% highlight xml %}
<Response>
  <Dial action="/my-phone/finished">
    <Sip>sip:myext@mydomain.com</Sip>
  </Dial>
</Response>
{% endhighlight %}

and the action that handles the call termination looks like this
{% highlight c# %}
public ActionResult MyPhoneFinished(TwilioRequestVM request)
{
  var res = new TwilioResponse();
  var validator = new Twilio.TwiML.RequestValidator();
  if (validator.IsValidRequest(System.Web.HttpContext.Current, ConfigurationManager.AppSettings["Twilio.Token"]))
  {
    if (request.CallStatus == "failed")
    {
      res.Dial(new Number("+59899999999"));
    }
  }
  return TwiML(res);
}
{% endhighlight %}

**PS:** I wish I had a cool number like the one in the examples

**PS2:** Inspired by [my question and answer at Stack Overflow](http://stackoverflow.com/q/19437548/920295)
