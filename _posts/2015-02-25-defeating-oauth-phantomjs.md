---
layout: post
title: Defeating OAuth2's purpose with PhantomJS and Selenium
description: "or how to use PhantomJS to do the OAuth2 dance. This may not be particularly interesting for you if you've already used it, but when I wrote this I felt great."
date: '2015-02-25T23:49:00.000-02:00'
tags:
- selenium
- phantomjs
- oauth
- python
modified_time: '2015-09-16T19:40:48.943-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-3741580046731553688
blogger_orig_url: http://blog.gmc.uy/2015/02/defeating-oauth-with-phantomjs.html
priority: 0.5
---
TL;DR: As part of a system to report the time I've worked on an issue from TimeDoctor to JIRA, I'm doing the OAuth2 dance using selenium and PhantomJS (effectively doing what OAuth2 without a password grant tries to avoid... having the application know the user password).

<!--more-->
I'm taking a small break from the SIP registration project for twilio to work on a quick app that automatically updates the time spent on my [JIRA](https://www.atlassian.com/software/jira) issues based on my [TimeDoctor](https://www.timedoctor.com/#545c29e26f8ab) logs. I also want it to send me a weekly report and a monthly report. I originally [designed everything to be extremely modular](https://github.com/g3rv4/horas) (so that you could use different "notification" plugins and time tracking services) but I got discouraged by the time it was taking me. This needs to be something that makes my life easier, not an extra project :). I'm using Python here because... I want to!

TimeDoctor has an API that lets me retrieve my worklogs... and that's cool, but the only way to authenticate a user is through [OAuth2](https://oauth.net/2/) without the possiblity of using `grant_type` = `password`. That is great if you're creating an app that lots of people are going to use and most importantly: if the app you're building is a web app. I want to do this as a console app, so that I can put it in a cron and just forget about it. This approach requires me to put my TimeDoctor credentials in the application, but I'm ok with that.

My [first approach](https://github.com/g3rv4/hours/blob/76f9c227268ac911d2417ff1cd5b0775581756c1/run.py) was using Flask, and launching a web server if the tokens (access and refresh) failed. That seemed like a decent workaround, given that refresh tokens should get me access for as long as the application remains approved by the user... but that's not enough, I want the cron to be completely independent from me...

So, that's where I remembered I had read about [PhantomJS](http://phantomjs.org/) and how cool I thought it sounded (I've built some scrapers and having to figure out what a JS could be doing is one of the most painful things I've worked on). PhantomJS is just a headless browser... it means that it has no window but it processes everything as a regular browser would. It then lets you interact with the different elements programatically. This seems like the exact challenge it's able to solve... javascript, redirections and redirections done through javascript. I would have my system use PhantomJS to complete all the steps in the authentication... Spoiler alert: it works great.

This particular API implements the [Authorization Code Grant flow](https://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1). In plain English, this is how it's meant to work:

1. You should register your app and provide a redirection url. That's where your users would land once they complete the registration process. They give you a `client_id` and a `client_secret`
2. You show a link to your user saying "Log in with TimeDoctor" that points to `https://webapi.timedoctor.com/oauth/v2/auth?client_id=<YOUR_CLIENT_ID>&response_type=code&redirect_uri=<REDIRECT_URI>`
3. The user enters their credentials in the TimeDoctor site, and then choose to allow your application to access their data
4. TimeDoctor's site redirects the user to whatever you set as `redirect_uri` when redirecting the user to them and appends `?code=<SOME_WEIRD_CODE>` (the hostname needs to match with what you used when registering your app on the very first step)
5. Once your server has the code, it should query `https://webapi.timedoctor.com/oauth/v2/token?client_id=<YOUR_CLIENT_ID>&client_secret=<YOUR_CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=<REDIRECT_URI>&code=<RETURNED_CODE_FROM_POINT.4>` which now will return the `access_token` (that you need to access the API) and the `refresh_token` (that you need to use when the `access_token` expires and you want a new one)

One of my goals is not to have a server. In order to accomplish that, I'm going to have PhantomJS tell me what's the URL on step 4 and parse the code from it.

I originally set it so that my redirect url was `http://127.0.0.1:1234` but that didn't work. For some (extremely weird) reason, if PhantomJS doesn't find a server in the port you specify, it doesn't change the page. So what I ended up doing was using their own server... I set up my TimeDoctor app to redirect to `https://webapi.timedoctor.com/oauth/v2/token` with the code.

Requirements for this code to work:

* Have PhantomJS installed (running `npm -g install phantomjs` if you have [nodejs](https://nodejs.org/en/) installed)
* Have the [selenium](https://pypi.python.org/pypi/selenium) package (running `pip install selenium`)
* If you're on a mac and installed nodejs with brew, you may need to do `sudo ln -s /usr/local/bin/node /usr/bin/node` (thanks to [this answer](https://stackoverflow.com/a/15699761/920295)!)

Here is the extremely simple code
{% highlight python %}
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from urllib import quote
from urlparse import urlparse

timedoctor_oauth_url = ('https://webapi.timedoctor.com/oauth/v2/auth?'
                       'client_id=%s&response_type=code&redirect_uri=%s')
                       % (config['client_id'],
                          quote('https://webapi.timedoctor.com/oauth/v2/token'))

# Initialize driver
driver = webdriver.PhantomJS(executable_path=config['phantomjs_path'])
driver.get(timedoctor_oauth_url)

# Fill username
username_field = driver.find_element_by_id('username')
username_field.send_keys(config['username'])

# Fill password
password_field = driver.find_element_by_id('password')
password_field.send_keys(config['password'])

# Submit authentication form
password_field.send_keys(Keys.ENTER)

# In the second form, where the user is asked to give access to your
# app or not, click on the "Accept" button.
# The element's id is 'accepted'
accept_button = driver.find_element_by_id('accepted')
accept_button.click()

# The browser is now in the example.com url, get that url and extract the code
url = urlparse(driver.current_url)
query_dict = dict([tuple(x.split('=')) for x in url.query.split('&')])
code = query_dict['code']

r = requests.post('https://webapi.timedoctor.com/oauth/v2/token', {
    'client_id': config['client_id'],
    'client_secret': config['client_secret'],
    'grant_type': 'authorization_code',
    'code': code,
    'redirect_uri': 'https://webapi.timedoctor.com/oauth/v2/token'
})

if r.status_code != 200:
    print 'Unable to retrieve code, token service status code %i' % r.status_code
    sys.exit(-1)

data = json.loads(r.content)

access_token = data['access_token']
refresh_token = data['refresh_token']
{% endhighlight %}
And if at any time you want to really see what PhantomJS is seeing, you can do `driver.save_screenshot('screen.png')` and it creates an image for you... soooo cool!

Hope it helps someone! Oh, and I wouldn't have been able to figure out how to use PhantomJS via selenium without [this answer](https://stackoverflow.com/a/15699761/920295). If you're interested in this particular project, you can take a look and clone the repo [here](https://github.com/g3rv4/hours).
