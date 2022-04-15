---
layout: post
title: "Building multi architecture docker images on GitHub Actions"
date: "2022-04-14 00:00:00"
---
On my previous article I showed how I could use Puppeteer Sharp to create PDFs on Docker... now, it's time to publish a multi-arch image to Docker hub from GitHub Actions.

<!--more-->

On my [previous blog post]({% post_url 2022-04-10-creating-pdfs-on-csharp-in-docker %}) I showed the following Docker compose for building a .NET Core app that uses Puppeteer Sharp for creating PDFs.

{% raw %}

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

What's interesting about it is that it can build x64 images and ARM images. And I'm doing exactly that on my [SecretSplitter project](https://github.com/g3rv4/SecretSplitter).

This is a bit of an interesting project because it needs to have Chromium installed, and the Chromium installation is different based on the architecture. If you look closely, you will notice that I'm always building my app on the `amd64` image, and only use the actual architecture for installing chromium.

Now, I don't want my users to have to know the name (or tag) of the image to pull when they want to use my app... I want it to be a regular Docker experience. I saw [this article](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/) where Docker explains how to build multi-arch images "the simple way", but I hit two issues with this approach:

1. I don't think .NET Core images follow this convention
2. I don't want to _always_ use ARM images when building my app... amd64 is way faster for compiling the app, and the .NET Core dlls are exactly the same for all the architectures (what changes is the runtime)
3. I want to parallelize the work.

What's nice is that they show the "hard way", and it's exactly what I need.

You can see all the details [on my build yaml](https://github.com/g3rv4/SecretSplitter/blob/main/.github/workflows/build.yml), but TL;DR:

I defined [a reusable workflow](https://github.com/g3rv4/SecretSplitter/blob/main/.github/workflows/build-image-for-arch.yml) that I can use for building images for every architecture. And for GitHub Actions to be able to build an ARM image, I did this little trick:

```pwsh
if ('${{ inputs.architecture }}' -eq 'arm64v8') {
    sudo apt-get install qemu binfmt-support qemu-user-static
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
}
```

The workflow itself ends up pushing to Docker Hub an image tagged `latest-${{ inputs.architecture }}`, so I have `g3rv4/secretsplitter:latest-arm64v8` and `g3rv4/secretsplitter:1.1.6-amd64`.

These are separate jobs, so they run in parallel... and once both finish, I have one last job that creates the multi-arch one:

```pwsh
docker manifest create `
        g3rv4/secretsplitter:latest `
        --amend g3rv4/secretsplitter:latest-amd64 `
        --amend g3rv4/secretsplitter:latest-arm64v8
docker manifest create `
        g3rv4/secretsplitter:${{ needs.build-amd64.outputs.version }} `
        --amend g3rv4/secretsplitter:${{ needs.build-amd64.outputs.version }}-amd64 `
        --amend g3rv4/secretsplitter:${{ needs.build-amd64.outputs.version }}-arm64v8
docker manifest push g3rv4/secretsplitter:latest
docker manifest push g3rv4/secretsplitter:${{ needs.build-amd64.outputs.version }}
```

You can see the latest GitHub Actions runs [here](https://github.com/g3rv4/SecretSplitter/actions).

And any user can execute my app by running this, regardless of their architecture:

```

docker run --rm -v ~/secretssplitted:/var/output --network none -ti g3rv4/secretsplitter

```

It took me a bit to put all the pieces together, so hopefully I'll save you some hours :)

{% endraw %}