---
layout: post
title: "Bundling, signing and notarizing a Go application so that Gatekeeper is happy"
date: "2019-06-16 10:00:00 -0300"
description: "Want to have your executable accepted by Gatekeeper? hope this helps."
---

macOS has Gatekeeper... a mechanism to prevent users from installing software they've downloaded UNLESS it's signed by a developer enrolled in they program AND they've shomehow verified it's not extremely malicious. I've read it's not that complicated to do it when building Cocoa apps, but the story is different for a Go application.

<!--more-->

A couple days ago, I wrote [OnChrome](https://onchro.me). It's a Firefox extension with a couple native command line applications. It was all good until I tried to download the file and run it, when I saw this:

![](/public/images/unidentifiedDeveloper.png)

I could Cmd + right click -> Open... but it's definitely not a great experience for a user.

So I started reading how I could get rid of it. I had a couple requirements:

* It should be a familiar experience for macOS users
* It shouldn't ask for the root password
* Gatekeeper should be happy about it

I was able to make it and automate it, but it was an interesting road. This is not a short article as I'm sharing a couple dead ends I hit, so maybe you just want to take a look into [the script that does everything](https://github.com/g3rv4/OnChrome/blob/master/BuildApp.ps1) and save some time.

My application consists of 2 terminal executables built with Go. Nothing more and nothing less... so there iss no app bundle or fancy GUI for it. I just want to distribute these 2 files without Gatekeeper complaining.

# What does it take for Gatekeeper to be happy?

Apple has a [notarization process](https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution) where you send them your application, they run some tests on it and emit a token that can be used to verify that they didn't find anything wrong with your app.

Then, you can stamp that token so that users of your app can verify it's legit (and even if they are offline, have their Macs run your software).

Now, notarization comes with a couple requirements that you can see on the link. One of them is that the app is linked against the macOS 10.9 or later SDK. go1.12.5 linked against 10.7.0, so I had to tweak go and build it locally... fortunately, go1.12.6 is live and there's no need to do so today. Just make sure you're using 1.12.6 or greater.

# Getting a certificate from Apple

Gatekeeper only trusts Apple's certificates. That means that if you want Gatekeeper to trust your app, you need to register as an [Apple Developer](https://developer.apple.com/) and pay $99/yr for the privilege of having your Apple-issued certs.

In order to codesing an app for independent distribution (what I wanted), you need a certificate of type "Developer ID Application".

# Signing the applications

Alright, once you've installed the certificate, you can run

```

bin/macOS [master●] » security find-identity -v
  1) AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA "Developer ID Installer: Gervasio MARCHAND (XXXXXXXXXX)"
  2) BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB "Developer ID Application: Gervasio MARCHAND (XXXXXXXXXX)"

```

I have two certs. AAA should be used to sign installers and BBB should be used to sign applications. As I want to sign applications, I'm going to use use AAA. Apple also requires the use of a hardened runtime and a timestamp signature. Both things can be accomplished when signing by using the `--timestamp --options runtime` parameters.

So I went ahead and signed my two executables by running

```

bin/macOS [master●] » codesign -s AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -v --timestamp --options runtime Menu
bin/macOS [master●] » codesign -s AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -v --timestamp --options runtime FirefoxEndpoint

```

And that's it! they are signed!

# Notarizing the applications

Here's when things get fun. You can't upload an executable to the notarization service, but you can send a zip file.

You need to have an [app-specific password](https://support.apple.com/en-us/HT204397) if you have 2FA enabled, because the app is going to ask you for one and it doesn't support 2FA.

So I tried this:

```

bin/macOS [master●] » zip -r OnChrome0.2.zip . -x ".*" -x "__MACOSX"
bin/macOS [master●] » xcrun altool --notarize-app --primary-bundle-id "article"  --username my@email.com --file OnChrome0.2.zip
2019-06-15 10:05:36.837 altool[2345:37734] No errors uploading 'OnChrome0.2.zip'.
RequestUUID = b54e637c-934f-41cf-b098-04088492f316

```

yay! that's good... after a couple minutes I received an email from Apple telling me that my software was ready to be distributed. You can also run this to verify the status of your request (which is good because... the end goal is to automate all of this!)

```

bin/macOS [master●] » xcrun altool --notarization-info b54e637c-934f-41cf-b098-04088492f316 -u my@email.com
apple@findme.email's password:
2019-06-15 10:23:19.208 altool[4113:89624] No errors getting notarization info.

   RequestUUID: b54e637c-934f-41cf-b098-04088492f316
          Date: 2019-06-15 13:11:30 +0000
        Status: success
    LogFileURL: <long_url>
   Status Code: 0
Status Message: Package Approved

```

So things were looking good... the last step was to staple the executables... I ran

```

bin/macOS [master●] » xcrun stapler staple FirefoxEndpoint
Processing: /Users/gervasio/Projects/OnChrome/bin/macOS/FirefoxEndpoint
The staple and validate action failed! Error 73.

```

Hmm alright... so error 73... I then run it in verbose mode and this is what I got

```

bin/macOS [master●] » xcrun stapler staple -v FirefoxEndpoint
Processing: /Users/gervasio/Projects/OnChrome/bin/macOS/FirefoxEndpoint
...
Downloaded ticket has been stored at file:///var/folders/fq/264y6gtn6dq6w_t11ctv673m0000gn/T/d550a95c-f62a-4f91-b9c5-977f90ebb176.ticket.
Could not remove existing ticket from FirefoxEndpoint/Contents/CodeResources -- file:///Users/gervasio/Projects/OnChrome/bin/macOS/ because an error occurred. Error Domain=NSCocoaErrorDomain Code=512 "“CodeResources” couldn’t be removed." UserInfo={NSFilePath=/Users/gervasio/Projects/OnChrome/bin/macOS/FirefoxEndpoint/Contents/CodeResources, NSUserStringVariant=(
    Remove
), NSUnderlyingError=0x7fabee421b10 {Error Domain=NSPOSIXErrorDomain Code=20 "Not a directory"}}
The staple and validate action failed! Error 73.

```

That means... it's trying to remove the existing ticket from `FirefoxEndpoint/Contents/CodeResources` but it's failing with an error `Not a directory`. Duh, of course it's not a directory... it's because FirefoxEndpoint is an executable, not a macOS bundle.

I tried making a package (with `pkgbuild` and `productbuild`) but there was no way to avoid asking for a root password and installing it on the user's home directory (even using Apple's [documented](https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/DistributionDefinitionRef/Chapters/Distribution_XML_Ref.html) `domains` element in the `distribution.xml` file)... and since I don't need a root password, I'd rather not have a root password. The installer is quite... [buggy it seems](http://simx.me/technonova/tips/packagemaker_and_installer.html).

After trying several things I realized that making it a macOS bundle was the easiest path forward. After all, it's not more than a [pretty well documented](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW1) folder structure.

I created a [template for my bundle](https://github.com/g3rv4/OnChrome/tree/master/app/MacOSBundleStructure) and then it's just a matter of putting the executables inside `Contents/MacOS`. One interesting thing is having an app bundle that opens Terminal to run an executable... I did that by [defining as entry point](https://github.com/g3rv4/OnChrome/blob/f46b8f6b23c84d036b58d304852d8f1006045cbb/app/MacOSBundleStructure/Contents/Info.plist#L15-L16) a [bash script](https://github.com/g3rv4/OnChrome/blob/f46b8f6b23c84d036b58d304852d8f1006045cbb/app/MacOSBundleStructure/Contents/MacOS/OnChrome) that calls `open -a Terminal` (and it checks if the app is translocated, to show an error).

So once I have the bundle template, I need to:

1. Copy the template to `OnChrome.app`
2. Copy the unsigned executables into `OnChrome.app/Contents/MacOS`

And I have my bundle ready! not signed, but ready.

The next step is signing it (using the `--deep` parameter so that everything is signed in one go)

```

bin/macOS [master●] » codesign -s AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -v --timestamp --deep --options runtime OnChrome.app
OnChrome.app: signed app bundle with generic [me.onchro]

```

And in order to notarize it, it needs to be either a zip file or a dmg. I initially zipped it, but if a user unzipped it on the Downloads folder, it would trigger Gatekeeper's [App Translocation](https://lapcatsoftware.com/articles/app-translocation.html) and I need the app's path to register itself as a valid native messaging app for Firefox.

Choosing a dmg sounded easier since it doesn't automatically extract its content, but opens a Finder window with the app that the user moves somewhere else. In order to build a dmg that I like without spending too much time learning about it, I decided to use [appdmg](https://github.com/LinusU/node-appdmg). So after writing a [dmgspec.json](https://github.com/g3rv4/OnChrome/blob/6bbf56a8bb992936f0dbc1487ad6227cd2773c28/dmgspec.json) that I like, I could just build the dmg.

```

Projects/OnChrome [master●] » appdmg dmgspec.json bin/macOS/OnChrome.dmg
[ 1/21] Looking for target...                [ OK ]
[ 2/21] Reading JSON Specification...        [ OK ]
[ 3/21] Parsing JSON Specification...        [ OK ]
[ 4/21] Validating JSON Specification...     [ OK ]
[ 5/21] Looking for files...                 [ OK ]
[ 6/21] Calculating size of image...         [ OK ]
[ 7/21] Creating temporary image...          [ OK ]
[ 8/21] Mounting temporary image...          [ OK ]
[ 9/21] Making hidden background folder...   [ OK ]
[10/21] Copying background...                [SKIP]
[11/21] Reading background dimensions...     [SKIP]
[12/21] Copying icon...                      [SKIP]
[13/21] Setting icon...                      [SKIP]
[14/21] Creating links...                    [SKIP]
[15/21] Copying files...                     [ OK ]
[16/21] Making all the visuals...            [ OK ]
[17/21] Blessing image...                    [ OK ]
[18/21] Unmounting temporary image...        [ OK ]
[19/21] Finalizing image...                  [ OK ]
[20/21] Signing image...                     [SKIP]
[21/21] Removing temporary image...          [ OK ]
[22/21] Removing target image...             [ OK ]

Your image is ready:
bin/macOS/OnChrome.dmg
Projects/OnChrome [master●] » xcrun altool --notarize-app --primary-bundle-id "article2"  --username my@email.com --file bin/macOS/OnChrome.dmg
apple@findme.email's password:
2019-06-15 19:07:19.148 altool[1574:15107] No errors uploading 'OnChromeMacOS.0.1.dmg'.
RequestUUID = d50edb61-39d3-4101-831e-5e3f1d75494b

```

After a couple minutes I get the email from Apple saying that everything is alright. The only missing thing is stapling it:

```

bin/macOS [master●] » xcrun stapler staple OnChrome.dmg
Processing: /Users/gervasio/Projects/OnChrome/bin/macOS/OnChrome.dmg
Processing: /Users/gervasio/Projects/OnChrome/bin/macOS/OnChrome.dmg
The staple and validate action worked!

```

And... this is all! I can distribute the dmg and when people open the application, they *just* see this message from Gatekeeper:

![](/public/images/OnChromeNotSigned.png)

And this is the best you can get... there's no warning icon on the Gatekeeper logo and it says "Apple checked it for malicious software and none was detected". It's true that the default is Cancel, but yeah... that's the best you can get without distributing the app through the app store.

At this point I thought it could help if I signed it, but when opening the signed dmg (that contains the stapled application), I get this instead:

![](/public/images/OnChromeSigned.png)

It sounds like it sees the signed dmg and then tries to see if it was notarized to say it doesn't have malicious software. Since I didn't notarize the dmg, then it makes sense that it won't find one. However, after notarizing and stapling it I got the exact same error message... so... **don't sign it or staple the image** and it should be alright.

# Automating everything

I could do everything manually... but it's a PITA. So I went ahead and automated everything with Powershell. [You can see the script here](https://github.com/g3rv4/OnChrome/blob/master/BuildApp.ps1), in the notarization step it checks every 10 second the status and it staples once everything is ok.

You can pass as many arguments to it as you want, if you don't set `-CodeSign`, then it won't ask for any of the codesigning details.

# Thanks for reading

If you have ideas of how to improve the process, let me know! I'm @g3rv4 on twitter.