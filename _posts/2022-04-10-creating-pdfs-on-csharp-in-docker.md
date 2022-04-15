---
layout: post
title: "Creating PDFs on C# in Docker"
date: "2022-04-10 00:00:00"
---
It's incredibly hard to find a library to build PDFs on C#, so what if we cheat? [Puppetter Sharp](https://www.puppeteersharp.com/) is awesome, and we can (ab)use it to just generate PDFs.

<!--more-->

If you tried to generate PDFs on C#, you've either paid a lot or ended up super frustrated. The only library with a free (as in beer) version I could find runs only on Windows.

Now... we have [Puppetter Sharp](https://www.puppeteersharp.com/) which is an amazing library to automate Chrome. This amazing library can automate lots of things but it can also use Chrome to build PDFs.

If you generate HTML, you can use Puppetteer Sharp to get you a PDF. How? here's how (modified from [the official docs](https://www.puppeteersharp.com/api/index.html))

```c#

await new BrowserFetcher().DownloadAsync(BrowserFetcher.DefaultRevision);
var browser = await Puppeteer.LaunchAsync(new LaunchOptions
{
    Headless = true
});
var page = await browser.NewPageAsync();
await page.GoToAsync(@"data:text/html,<html>
    <body>
        <h1>Hello world!</h1>
        <p>This is awesome</p>
    </body>
</html>");
await page.PdfAsync(pathToPdfFile);

```

You can get fancy, you can use css to style your content, add images... do anything. In the end, Chrome will end up saving a PDF.

## This is all fine, but what if I run my app on a docker container?

If you run it in a docker container, this won't work. I wanted to run my stuff on alpine, on the runtime Microsoft ships... and there are dependencies that make the whole thing break hard. I found [this article Darío wrote about it](https://www.hardkoded.com/blog/puppeteer-sharp-docker) but I wanted to use a newer image (and understand what I was doing).

On that article, Darío shows that you can install Chromium and then point Puppeteer Sharp to the executable... and that's exactly what I did. I ended up with this Dockerfile

```Dockerfile

ARG ARCH=
FROM mcr.microsoft.com/dotnet/sdk:6.0.201-alpine3.15-amd64
WORKDIR /var/src
COPY src/* ./
RUN dotnet publish -c Release -o /var/publish

FROM mcr.microsoft.com/dotnet/runtime:6.0.3-alpine3.15-${ARCH}
RUN apk add --update chromium libexif udev && \
    apk info --purge
ENV CHROMIUM_EXECUTABLE=/usr/bin/chromium-browser
WORKDIR /var/output
COPY --from=0 /var/publish /var/app
CMD ["dotnet", "/var/app/SecretSplitter.dll"]

```

That also lets me build my app for ARM machines (so that I can run the same app in M1 processors). Then, on my app I can do this to launch it while I support both operation modes:

```c#

var browserLauchOptions = new LaunchOptions
{
    Headless = true
};

var executable = Environment.GetEnvironmentVariable("CHROMIUM_EXECUTABLE");
if (string.IsNullOrEmpty(executable))
{
    using var browserFetcher = new BrowserFetcher();
    await browserFetcher.DownloadAsync();
}
else
{
    browserLauchOptions.Args = new[] { "--no-sandbox" };
    browserLauchOptions.ExecutablePath = executable;
}

await using var browser = await Puppeteer.LaunchAsync(browserLauchOptions);
var page = await browser.NewPageAsync();
await page.GoToAsync(@"data:text/html,<html>
    <body>
        <h1>Hello world!</h1>
        <p>This is awesome</p>
    </body>
</html>");
await page.PdfAsync(pathToPdfFile);

```

And that's it! I'm able to build PDFs con C# inside of Docker, both for x86 and ARM architectures.

Now... how can I publish multiple architecture images under the same name from GitHub? I'm glad you asked, that's what [my next article is about]({% post_url 2022-04-14-building-multiarch-docker-images-github-actions %})
