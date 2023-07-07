---
layout: post
title: "Installing Mastodon on an IPv6-only host running Ubuntu 22.04"
date: "2023-07-07 00:00:00"
---
I got my Hetzner account and I took the questionable decision of saving €0.60/mo by only having an IPv6. In order to make financial sense I'll have to wait some years, but it was fun!

<!--more-->

I wanted to host my brand new instance on Hetzner, a cheap yet reliable provider. I wanted to make it extra cheap, so I went for an ARM VM with IPv6 only. At the time of writing, that costs €3.29 and includes 2 vCPUs and 4 GB RAM memory. Should be more than enough for my single user instance.

Now Mastodon needs to interact with all the servers, and I need to reach it even if the network I'm connected on is IPv4 only. So that means I had to solve two problems:

* Contacting 3rd party IPv4-only servers
* Receiving traffic from 3rd party IPv4-only servers and clients

What I didn't anticipate is that some things don't quite work if your host only can route traffic through IPv6. I'm documenting this primarily hoping it can help me next time :) if it also helps other folks, awesome!

## Connecting to a world that still has IPv4 hosts

Considering we had a [World IPv6 launch](https://www.worldipv6launch.org/) on 2012, I'm pretty convinced IPv4 is not going anywhere. The way to solve this is with DNS64 and NAT64.

> DNS64 is a DNS service that returns AAAA records with these synthetic IPv6 addresses for IPv4-only destinations (with A but not AAAA records in the DNS). This lets IPv6-only clients use NAT64 gateways without any other configuration.

and:

> NAT64 is an IPv6 transition mechanism that facilitates communication between IPv6 and IPv4 hosts by using a form of network address translation (NAT).

The way it works is:

* Both DNS64 and NAT64 need to agree on a prefix. The common one is `64:ff9b::/96`
* When an IPv6 host does a request to a domain that only has an IPv4 host, the DNS64 returns an IPv6 on the reserved range
* The host sends the request to the mapped range to NAT64, which is a machine that has both an IPv6 and an IPv4. It then forwards the request using its IPv4 (that's the IP that the recipient will see) and then returns it to the IPv6 host. It's doing NAT :)

Hetzner doesn't have DNS64/NAT64 available, but fortunately [nat64.net](https://nat64.net/). Just by setting the nameservers to those three values, your IPv6 host gains IPv4 connectivity.

In order to change the nameservers, we have to change a yaml file at `/etc/netplan`. And we can use `yq` to edit it on the console. Now... `yq` is downloaded from github.com, which only has IPv4... so in order to access the IPv4 network, we need to download from a site that only has IPv4 addresses. Fortunately, we can do a little trick... since we know the IPv6 is just a prefix + the IPv4 address, we can do exactly that.

```
curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 \
     --resolve 'github.com:443:2a00:1098:2c::5:'`dig github.com A +short` \
     --resolve 'objects.githubusercontent.com:443:2a00:1098:2c::5:'`dig objects.githubusercontent.com A +short` \
     --output /usr/bin/yq; \
chmod +x /usr/bin/yq
```

It's now time to turn off dhcp4, set the nameservers and apply the changes!

```
find /etc/netplan -type f -name "*.yaml" -exec yq e '.network.ethernets.eth0.dhcp4 = false' -i {} \;
find /etc/netplan -type f -name "*.yaml" -exec yq e '.network.ethernets.eth0.nameservers.addresses = ["2a00:1098:2c::1", "2a01:4f9:c010:3f02::1", "2a00:1098:2b::1"]' -i {} \;
netplan apply;
```

## Install Tailscale

And that's it! it can now connect to IPv4 hosts! At this point, I install tailscale. I want to enable it as an exit node and avoid the DNS changes (because of... reasons)

```
curl -fsSL https://tailscale.com/install.sh | sh
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
tailscale up --advertise-exit-node --ssh --accept-dns=false
```

## Install Mastodon

And now I can start with the mastodon installation. I don't want to post the steps here because they will be old quick. You can follow the steps [here](https://docs.joinmastodon.org/admin/install/), but there's one thing to keep in mind. When running `yarn set version classic`, you will probably get this error:

```
Internal Error: Error when performing the request
    at ClientRequest.<anonymous> (/usr/lib/node_modules/corepack/dist/corepack.js:43953:14)
    at ClientRequest.emit (node:events:513:28)
    at TLSSocket.socketErrorListener (node:_http_client:494:9)
    at TLSSocket.emit (node:events:513:28)
    at emitErrorNT (node:internal/streams/destroy:157:8)
    at emitErrorCloseNT (node:internal/streams/destroy:122:3)
    at processTicksAndRejections (node:internal/process/task_queues:83:21)
```

This is because _something_ is trying to use the IPv4 address to download content. The problem is that the tailscale interface has an IPv4. Even if there are no IPv4 routes, _something_ fails. The fix is to delete the IPv4 from the interface. This means that in your tailscale network, you gotta use the machine's IPv6 address to connect to it.

```
IP=$(ip addr show tailscale0 | grep 'inet ' | awk '{print $2}')
ip addr del $IP dev tailscale0
```

Now you can run `yarn set version classic` and complete the installation.

## Receiving connections from IPv4-only hosts

And this last part is achieved by using a proxy. In my case, I'm using Cloudflare. I added an AAAA record with my IPv6, enabled proxy mode, and they take care of sending IPv4 (and IPv6) traffic to my server.
