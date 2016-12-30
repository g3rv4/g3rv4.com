---
layout: post
title: Mac OS Notifications from Python - with PyCharm debugging :)
description: "This one was interesting... I learned about application bundles how to use the OSX notification system from python (via PyObjC, which I didn't know existed)"
date: '2015-08-31T11:49:00.003-03:00'
tags:
- application bundle
- notifications
- pycharm
- info.plist
- pyobjc
- NSUserNotification
- NSUserNotificationCenter
- mac os
- NSUserNotificationAlertStyle
modified_time: '2015-09-02T19:06:14.175-03:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-5282861200093004190
blogger_orig_url: http://blog.gmc.uy/2015/08/mac-os-notifications-python-pyobjc.html
---
I built a small python app that notifies me about when my local currency changes... what's interesting about it is that it uses OSX's built in notification system. On this post I explain how I made it happen.

<!--more-->

I wanted to create an application that notifies me of interesting things through different means (it could be an SMS, an email or... Mac OS neat notification system).

I found this [Stack Overflow answer](http://stackoverflow.com/a/21534503/920295) that explained how to do that from Python, and even letting you add an action button (something like "View"). Here's that answer with a minor tweak on the init code (as the original way doesn't work anymore)

{% highlight python %}
import Foundation
import objc

class MountainLionNotification(Foundation.NSObject):
    # Based on http://stackoverflow.com/questions/12202983/working-with-mountain-lions-notification-center-using-pyobjc

    def init(self):
        self = objc.super(MountainLionNotification, self).init()
        if self is None: return None

        # Get objc references to the classes we need.
        self.NSUserNotification = objc.lookUpClass('NSUserNotification')
        self.NSUserNotificationCenter = objc.lookUpClass('NSUserNotificationCenter')

        return self

    def clearNotifications(self):
        """Clear any displayed alerts we have posted. Requires Mavericks."""

        NSUserNotificationCenter = objc.lookUpClass('NSUserNotificationCenter')
        NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()

    def notify(self, title, subtitle, text, url):
        """Create a user notification and display it."""

        notification = self.NSUserNotification.alloc().init()
        notification.setTitle_(str(title))
        notification.setSubtitle_(str(subtitle))
        notification.setInformativeText_(str(text))
        notification.setSoundName_("NSUserNotificationDefaultSoundName")
        notification.setHasActionButton_(True)
        notification.setActionButtonTitle_("View")
        notification.setUserInfo_({"action":"open_url", "value":url})

        self.NSUserNotificationCenter.defaultUserNotificationCenter().setDelegate_(self)
        self.NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification_(notification)

        # Note that the notification center saves a *copy* of our object.
        return notification

    # We'll get this if the user clicked on the notification.
    def userNotificationCenter_didActivateNotification_(self, center, notification):
        """Handler a user clicking on one of our posted notifications."""

        userInfo = notification.userInfo()
        if userInfo["action"] == "open_url":
            import subprocess
            # Open the log file with TextEdit.
            subprocess.Popen(['open', "-e", userInfo["value"]])
{% endhighlight %}
... but things weren't that simple. In order for an application to be able to send notifications, it needs to be part of an [application bundle](https://en.wikipedia.org/wiki/Bundle_(OS_X)#OS_X_application_bundles) and have, on its `Info.plist` the `CFBundleIdentifier` key populated. As I'm using virtualenv, the application that's being run is `/path/to/my/virtualenv/bin/python` and that obviously is not a bundle. Also, that's what PyCharm uses, and I want to set up my script to be run as a `launchd` script. Some people suggested using py2app, but I wanted to be able to debug as needed.

Do you want to show alert notifications? (the ones that don't disappear automatically and that let you use an action button) you need your `Info.plist` to have `NSUserNotificationAlertStyle` = `alert` (and enable them on System Preferences, or have your code signed)

The way I found to make all of that happen was:

* create a python.app bundle containing an Info.plist inside of the environment, with a link to the python executable
* create a python bash script on the environment that calls the python.app application

With your virtualenv activated, paste this and it will take care of everything for you

{% highlight bash %}
# disable bash history so that we can paste it without issues
set +o history

if [ -z $VIRTUAL_ENV ];then echo "please activate a virtualenv";set -o history;else

# choose application name
read -p "What do you want to use as application name? [python]" APPNAME;if [ -z $APPNAME ];then APPNAME="python";fi;

if [ -d ${VIRTUAL_ENV}/bin/${APPNAME}.app ]; then
 echo "The application ${APPNAME}.app already exists"
 set -o history
else

# create bundle directory and Info.plist
mkdir -p ${VIRTUAL_ENV}/bin/${APPNAME}.app/Contents/MacOS
cat >${VIRTUAL_ENV}/bin/${APPNAME}.app/Contents/Info.plist <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>CFBundleExecutable</key>
 <string>python</string>
 <key>NSUserNotificationAlertStyle</key>
 <string>alert</string>
 <key>CFBundleIdentifier</key>
 <string>${APPNAME}.app</string>
 <key>CFBundleName</key>
 <string>${APPNAME}</string>
 <key>CFBundlePackageType</key>
 <string>APPL</string>
 <key>NSAppleScriptEnabled</key>
 <true/>
</dict>
</plist>
EOL

# doing this so that I can have multiple apps in a virtual environment, to have different icons
if [ ! -f ${VIRTUAL_ENV}/bin/realpython ]; then
    ln -s `readlink ${VIRTUAL_ENV}/bin/python` ${VIRTUAL_ENV}/bin/realpython
fi

# create symbolic link
ln -s ../../../`readlink ${VIRTUAL_ENV}/bin/realpython` ${VIRTUAL_ENV}/bin/${APPNAME}.app/Contents/MacOS/python

# only delete the original symlink. After the first execution, leave the bash script as is
if [ -L ${VIRTUAL_ENV}/bin/python ]; then
 # delete the python one (as we'll use a shell script, so that it loads the app bundle info)
 rm ${VIRTUAL_ENV}/bin/python

 # create shell script
 echo "#!/bin/bash
${VIRTUAL_ENV}/bin/${APPNAME}.app/Contents/MacOS/python $@" >> ${VIRTUAL_ENV}/bin/python
 chmod +x ${VIRTUAL_ENV}/bin/python
fi;

# enable history back
set -o history
fi;
fi;
{% endhighlight %}
If you hate pasting so many lines (as I do), you can just do
{% highlight bash %}
bash <(curl -sL https://gmc.uy/appify_with_notifications.sh)
{% endhighlight %}

And that should be it! you now have a python file on your environment that's a bundle, and on pycharm you'll be able to debug the notifications code and see the notifications pop up :) You can see [my project here](https://gitlab.gmc.uy/gervasio/notify_me_anything).
