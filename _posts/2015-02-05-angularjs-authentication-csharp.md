---
layout: post
title: My take on AngularJS authentication with a .NET backend
description: "... and how I think about things. I was just getting started with AngularJS and I wanted to solve authentication / authorization in a neat way."
date: '2015-02-05T13:29:00.000-02:00'
tags:
- ".net"
- authentication
- twilio registration
- oauth
- sliding expiration
- angularjs
- RESTful
modified_time: '2015-02-06T18:41:35.903-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-881335462355661846
blogger_orig_url: http://blog.gmc.uy/2015/02/my-take-on-angularjs-authentication.html
priority: 0.7
---
Doing authentication and authorization of an AngularJS application with a C# backend, using signed tokens... I thought a lot about security, is it enough? I'm not sure, but I surely like this article :)

<!--more-->
Working on the [twilio registration project I want to show on the Signal conf]({% post_url 2015-01-13-plans-signalconf %}), I decided to go on things as deep as I want to... after all, it's my project to play with :)

I'm new with AngularJS, so I'm dealing with the same stuff everyone has dealt with on their beginnings. The first thing on my way is authentication... What I've read around suggested generating an OAuth bearer token and having it expire in 24 hours (or in any time you feel comfortable with and implementing the refresh mechanism).

Coming from traditional MVC applications, I really like the idea of [sliding expiration](https://msdn.microsoft.com/en-us/library/system.web.configuration.formsauthenticationconfiguration.slidingexpiration%28v=vs.110%29.aspx)... giving away a long lived token feels... dirty. I couldn't find anything baked in that took care of this, so I started coding my own algorithm.

While I was at it, my first decision was how to hash my passwords... fortunately, I found [this awesome article about it](https://crackstation.net/hashing-security.htm) and it even included C# code, so that's what I'm using.

Then, I got to think on my authentication code... my idea is to give every authenticated user a token with an expiration... and every time they use it, have that token change its expiration (the idea isn't to change the expiration only if half the time has already passed... I don't really see the value in it, but we'll see what the [good folks at Stack Exchange have to say about it](https://security.stackexchange.com/q/80961/41022).

In order to handle the tokens on my side (and their expiration), I decided to use [redis](https://redis.io/). The reasoning behind that is:

* I don't store temporary data on my database (so that I don't need to make queries on it every time a token needs to change its expiration or to be validated... leaving the database for relational data)
* redis has a really convenient expiration logic baked in (you can basically say "store this for N seconds")
* redis is _fast_

So, every time a log in attempt is made, I would just store the token on redis (using the token as key and the account id as value, setting its TTL to the time I want it to be valid for) and verifying if the token is valid would be just verify if it's in there, and the value would get me the account id. I also wanted to block accounts after N unsuccessful login attempts. The code I came up with is something like this (rewrote it a little to improve its readability, you can find the actual code [here](https://github.com/g3rv4/twilioregistration/blob/35ec2c180f8f87c34fa814152831390a654b8662/TwilioRegistration.BusinessLogic/Managers/AccountsMgr.cs)):

{% highlight c# %}
public static LogInResultDT LogIn(string email, string password)
{
    var res = new LogInResultDT() { Status = LogInStatus.INVALID_USER_PWD };
    using (var context = new Context())
    {
        var account = GetAccount(email);
        if (account != null)
        {
            if (!account.IsActive)
            {
                res.Status = LogInStatus.INACTIVE;
                return res;
            }
            if (account.ReactivationTime.HasValue)
            {
                if (account.ReactivationTime.Value < DateTime.UtcNow)
                {
                    account.ReactivationTime = null;
                    account.FailedLoginAttempts = 0;
                }
                else
                {
                    res.Status = LogInStatus.TEMPORARILY_DISABLED;
                    return res;
                }
            }
            if (account.PasswordMatches(password))
            {
                res.Status = LogInStatus.SUCCESS;
                res.Token = System.Guid.NewGuid().ToString();

                StoreTokenOnRedis(res.Token, account.Id, GetFromConfig("Account.TokenExpirationSeconds"))
                account.FailedLoginAttempts = 0;
            }
            else
            {
                account.FailedLoginAttempts++;
                int maxFailedLogins = GetFromConfig("Account.MaxFailedLogins"));
                if (account.FailedLoginAttempts >= maxFailedLogins)
                {
                    int deactivateSeconds = GetFromConfig("Account.AccountDeactivationSeconds");
                    account.ReactivationTime = DateTime.UtcNow.AddSeconds(deactivateSeconds);
                }
            }
            context.SaveChanges();
        }
    }
    return res;
}
{% endhighlight %}
The idea behind returning the Invalid user *or* password is not letting an attacker figure out if an account exists just by entering any user or password (if the message said "invalid user", an attacker would know that when they get "invalid password" they got the user right). However, I realized that this code would let an attacker do basically the same thing. Considering that the code is open source, they would see this and instead of trying 1 user / password they could try N... and the accounts that get temporarily disabled are the ones that exist on the system.

In order to avoid this, I came up with two options:
* Return an "Invalid user or password or your account has been temporarily disabled" message. I, as a user, would hate to see this message...
* Temporarily disable all accounts (even non existent ones)

The second approach is definitely the most user friendly... but I was deactivating the accounts on the database... sooo... that's where redis helps again :)

The basic idea is: every time there's an unsuccessful log in attempt, increase the amount of failed attempts and set the TTL to the time I want to have the account deactivated... and before verifying if the account is valid, I can see how many log in attempts an email had. As the TTL takes care of removing that from redis, I don't have to do anything else.

The code is also nicer looking, and that's a plus! ([here](https://github.com/g3rv4/twilioregistration/blob/3f2fa6084107c655f96daff77dab84767b2da215/TwilioRegistration.BusinessLogic/Managers/AccountsMgr.cs) is the real version)

{% highlight c# %}
public static LogInResultDT LogIn(string email, string password)
{
    var res = new LogInResultDT() { Status = LogInStatus.INVALID_USER_PWD };
    using (var context = new Context())
    {
        int maxFailedLogins = GetFromConfig("Account.MaxFailedLogins");
        int failedLogins = GetAmountOfFailedLoginsFromRedis(email);

        if (failedLogins >= maxFailedLogins)
        {
            res.Status = LogInStatus.TEMPORARILY_DISABLED;
            return res;
        }

        var account = GetAccount(email);
        if (account != null && account.PasswordMatches(password))
        {
            // verify if the account is active once we know that the user knows their pwd and that their account isn't temporarily disabled
            if (!account.IsActive)
            {
                res.Status = LogInStatus.INACTIVE;
                return res;
            }

            res.Status = LogInStatus.SUCCESS;
            res.Token = System.Guid.NewGuid().ToString();

            StoreTokenOnRedis(res.Token, account.Id, GetFromConfig("Account.TokenExpirationSeconds"))
        }
        else
        {
            AddFailedLoginToRedis(email);
        }
    }
}
{% endhighlight %}

That's ok... then, on my Angular side of things, to log in I was doing
{% highlight javascript %}
(function () {
    app.factory('accountService', function ($resource, $http, $q, $log, baseUrl) {
        resource = $resource(baseUrl + 'accounts/:id', { id: "@Id" }, null, {stripTrailingSlashes: false})
        return {
            logIn: function (email, password) {
                var deferred = $q.defer()
                $http.post(baseUrl + 'accounts/log-in', { 'Email': email, 'Password': password })
                    .success(function (response) {
                        if (response.Status == 'SUCCESS') {
                            deferred.resolve(response.Token)
                        } else {
                            deferred.reject(response.Status)
                        }
                    })
                    .error(function (data, code, headers, config, status) {
                        $log.error('Code: ' + code + '\nData: ' + data + '\nStatus: ' + status)
                        deferred.reject(code)
                    })
                return deferred.promise
            },
            resource: resource
        }
    })
})();
{% endhighlight %}

I'm storing the token on the local session storage, so I just add it as a header on every request by doing this:
{% highlight javascript %}
app.run(function ($rootScope, $window, $http) {
    $rootScope.$on("$routeChangeError", function (event, current, previous, eventObj) {
        if (eventObj.authenticated === false) {
            $window.location.href = '/'
        }
    });

    $http.defaults.headers.common.Authorization = 'gmc-auth ' + $window.sessionStorage.token
});
{% endhighlight %}

This was all good... but then I realized I had a major flaw... passing the token like that, an attacker could just try different tokens until they got one right. That would be quite a time consuming task, as there are 2^122 or 5,316,911,983,139,663,491,615,228,241,121,400,000 possible combinations ([source](http://mrdee.blogspot.com/2005/11/how-many-guid-combinations-are-there.html) with extremely interesting comments about it) but... it still felt wrong.

That's when I included OAuth... If I can give a user a signed token, then I feel safe enough. The idea here is to give a token that expires in 24 hours, and have that token have, as a claim, the GUID I'm using to authenticate them on redis. Then, even if the OAuth token is valid, I'd verify if it's expired (using the redis data).

Adding OAuth to the solution was extremely easy following [this great article](http://bitoftech.net/2014/06/01/token-based-authentication-asp-net-web-api-2-owin-asp-net-identity/), but I did a few changes to make it fit my particular scenario:

* I created [TWRAuthorizationServerProvider](https://github.com/g3rv4/twilioregistration/blob/b6dfaf79cdd3d68ab0ba3edcfda443e778cc4ed7/TwilioRegistration.Frontend/Utils/TWRAuthorizationServerProvider.cs) a (deriving from `OAuthAuthorizationServerProvider`) using my `AccountsMgr` to handle the log in. It also adds the roles from the database and the permissions (so that I don't need to query the database, I just use the data on the token).
* I created a [TokenValidationAttribute](https://github.com/g3rv4/twilioregistration/blob/b6dfaf79cdd3d68ab0ba3edcfda443e778cc4ed7/TwilioRegistration.Frontend/Utils/TokenValidationAttribute.cs) authentication filter (implementing IAuthenticationFilter) that takes care of validating if a GUID is valid as a token and adding the accountId as a claim. As I also want to have some users act as other users (usually admins, or... me) I'm here also changing the claims if they need to be changed.
* I created a [ClaimsAuthorizeAttribute](https://github.com/g3rv4/twilioregistration/blob/b6dfaf79cdd3d68ab0ba3edcfda443e778cc4ed7/TwilioRegistration.Frontend/Utils/ClaimsAuthorizeAttribute.cs) to use on the controllers to validate that users have the appropriate claims on their tokens
* I created a [BaseApiController](https://github.com/g3rv4/twilioregistration/blob/b6dfaf79cdd3d68ab0ba3edcfda443e778cc4ed7/TwilioRegistration.Frontend/Controllers/BaseApiController.cs) that my WebApi controllers derive from that it just makes available the AccountId so that the controllers can use it freely.

So now, a .NET controller with special claims requirements looks like this:
{% highlight c# %}
[ClaimsAuthorize]
[RoutePrefix("api/accounts")]
public class AccountsController : BaseApiController
{
    [ClaimsAuthorize("permission", "view-all-accounts")]
    public async Task<IEnumerable<AccountDT>> Get()
    {
        return await AccountsMgr.GetAccountsAsync();
    }

    [HttpGet]
    [Route("current")]
    public async Task<AccountDT> CurrentAccountId()
    {
        return await AccountsMgr.GetAccountAsync(_AccountId);
    }
}
{% endhighlight %}

And a .NET controller that just requires a user logged in looks like this:
{% highlight c# %}
[ClaimsAuthorize]
public class DevicesController : BaseApiController
{
    public async Task<IEnumerable<DeviceDT>> Get()
    {
        return await DevicesMgr.GetDevicesAsync(_AccountId);
    }
}
{% endhighlight %}

The angular accountService is pretty straightforward:
{% highlight javascript %}
(function () {
    app.factory('accountService', function ($resource, $http, $q, $log, baseUrl) {
        resource = $resource(baseUrl + 'accounts/:id', { id: "@id" }, {
            current: {
                method: 'GET',
                url: baseUrl + 'accounts/current',
                isArray: false
            }
        })
        return {
            logIn: function (email, password) {
                var deferred = $q.defer()
                data = "grant_type=password&username=" + email + "&password=" + password;
                $http.post(baseUrl + 'token', data, { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
                    .success(function (response, status) {
                        deferred.resolve(response.access_token)
                    })
                    .error(function (data, code, headers, config, status) {
                        if (data.error) {
                            deferred.reject(data.error)
                        } else {
                            $log.error('Code: ' + code + '\nData: ' + data + '\nStatus: ' + status)
                            deferred.reject(code)
                        }
                    })
                return deferred.promise
            },
            resource: resource
        }
    })
})();
{% endhighlight %}

The angular controller that logs a user in has this method:
{% highlight javascript %}
_this.logIn = function (loginForm) {
    if (loginForm.$valid) {
        accountService.logIn(_this.email, _this.password).then(
            function (token) {
                $window.sessionStorage.token = token
                $window.location.href = '/control-panel'
            }, function (reason) {
                errors = []
                if (isFinite(reason)) {
                    errors.push('HTTP Error: ' + reason)
                } else {
                    switch (reason) {
                        case 'INVALID_USER_PWD': reason = 'Invalid email or password'; break
                        case 'INACTIVE': reason = 'Your account is inactive'; break
                        case 'TEMPORARILY_DISABLED': reason = 'Your account has been temporarily disabled due to many unsuccessful login attempts. Try again later.'; break
                        default: reason = 'Unknown code: ' + reason
                    }
                    errors.push(reason)
                }
                _this.showErrors(errors)
            }
        )
    }
    else
    {
        errors = []
        if (loginForm.email.$error.required) {
            errors.push('The email is required')
        } else if (loginForm.email.$error.email) {
            errors.push('The email entered is invalid')
        }
        if (loginForm.password.$error.required) {
            errors.push('The password is required')
        }
        _this.showErrors(errors)
    }
}
{% endhighlight %}

The angular code that takes care of sending the token (and redirecting the user out if we get a 401 due to an invalid token) looks like this
{% highlight javascript %}
(function(){
    app.config(function ($routeProvider, $locationProvider, $httpProvider) {
        // if we receive a 401, delete the token and redirect to the homepage
        $httpProvider.interceptors.push(function ($q, $window) {
            return {
                'responseError': function (response) {
                    var status = response.status;
                    if (status == 401) {
                        $window.sessionStorage.removeItem('token');
                        $window.location.href = '/';
                    }
                    return $q.reject(response);
                },
            };
        });
    })

    app.run(function ($rootScope, $window, $http) {
        if (!$window.sessionStorage.token) {
            $window.location.href = '/'
        }

        $http.defaults.headers.common.Authorization = 'Bearer ' + $window.sessionStorage.token
        if ($window.sessionStorage.actingAs) {
            $http.defaults.headers.common['Acting-As'] = $window.sessionStorage.actingAs
        }
    });
})();
{% endhighlight %}

And an angular service that uses it just does
{% highlight javascript %}
(function () {
    app.factory('deviceService', function ($resource, baseUrl) {
        resource = $resource(baseUrl + 'devices/:id', { id: "@id" })
        return {
            resource: resource
        }
    })
})();
{% endhighlight %}
The only database queries that are done on every request are those the managers need to do in order to perform their tasks... mission accomplished! (or so I think).

You can download the code of the whole project from [here](https://github.com/g3rv4/twilioregistration). It's my intention to eventually pack this as a separate thing so that I can use it on other projects without copying and pasting... but until I find the time to do it, it's going to live in there :)

I'd love to hear your thoughts in the comments :) is it too much effort for something that that's pointless? after all, if an attacker got their hands on a token, they could do pretty much everything for 24 hours (except for changing the email / password, as the email will require email confirmation and the password will require knowledge of the old password).
