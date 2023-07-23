---
layout: post
title: "Using Docker on an IPv6 only host on Ubuntu 22.04"
date: "2023-07-17 00:00:00"
---

After setting up my Mastodon instance on Hetzner, with only an IPv6, I wanted to move a couple droplets there. But they all use Docker, and... having Docker work in a host with only IPv6 connectivity wasn't as straightforward as I expected.

<!--more-->

Setting up Docker on an IPv6 only host is not tricky... the tricky part is letting that container connect to the outer world. After trying lots of things (there are several blog posts, mostly outdated) I came up with a solution that works for me :)

## Setting up DNS64/NAT64

The first step is enabling connectivity to IPv4-only hosts. I'm using [nat64.net](https://nat64.net/) and `yq` to modify yaml files. Now, installing `yq` requires downloading it from github (that has only IPv4 addresses), so here I'm exploiting the fact that I know the nat64.net prefix to convert the IPv4 to a NATed IPv6:

```
curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 \
     --resolve 'github.com:443:2a00:1098:2c::5:'`dig github.com A +short` \
     --resolve 'objects.githubusercontent.com:443:2a00:1098:2c::5:'`dig objects.githubusercontent.com A +short` \
     --output /usr/bin/yq; \
chmod +x /usr/bin/yq;
find /etc/netplan -type f -name "*.yaml" -exec yq e '.network.ethernets.eth0.dhcp4 = false' -i {} \;
find /etc/netplan -type f -name "*.yaml" -exec yq e '.network.ethernets.eth0.nameservers.addresses = ["2a00:1098:2c::1", "2a01:4f9:c010:3f02::1", "2a00:1098:2b::1"]' -i {} \;
netplan apply;
yq e  -n '.network.config = "disabled"' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg;
```

## Install Tailscale

And that's it! it can now connect to IPv4 hosts! At this point, I install tailscale. I want to enable it as an exit node and avoid the DNS changes

```
curl -fsSL https://tailscale.com/install.sh | sh
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
tailscale up --advertise-exit-node --ssh --accept-dns=false
```

## Install docker

Installing docker as usual...

```
sudo apt update;
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg;
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
sudo apt update;
sudo apt install -y docker-ce;
sudo usermod -aG docker ${USER};
su - ${USER};
```

### Setting up Docker's networks

And now comes the fun part. The first thing I tried was using the `2001:0db8::` address range (that's what's used on Docker's documentation), and it worked! but then I realized that was a reserved range for documentation. Then [ULA addresses](https://en.wikipedia.org/wiki/Unique_local_address) sounded like the right thing, but for some reason that didn't work.

Then, I used the actual server range... Hetzner assigns a /64 IPv6 range. We have to tell Docker the network new containers are going to have, and we also have to specify the network ranges new networks will have (docker compose creates them).

If the server has been assigned the `2001:0db8:2a01:4f8::/64` range, that means it can control all the addresses from `2001:0db8:2a01:04f8:0000:0000:0000:0000` to `2001:0db8:2a01:04f8:ffff:ffff:ffff:ffff`. That's... a lot of addresses. The server is using `2001:0db8:2a01:4f8::1` (or `2001:0db8:2a01:04f8:0000:0000:0000:0001`).

Now, each docker network needs at least an /80 range so that it can generate ip addresses from mac addresses.

So what I'm going to do is:

1. Set `2001:0db8:2a01:4f8:1000::/68` as the default network range. It means the default network will have addresses from `2001:0db8:2a01:04f8:1000:0000:0000:0000` to `2001:0db8:2a01:04f8:1fff:ffff:ffff:ffff`
2. Add a default address pool that's `2001:0db8:2a01:4f8:2000::/68`, but so that new networks take /80 ranges. In a /68 range there are 4096 /80 ranges, so that's more networks that I'll need.

Another small detail: if you don't specify the dns on daemon.json, it won't use the host's information when running in a docker swarm (it's not needed if you don't use a swarm though).

Now, this code is very hacky. I couldn't find a reliable way of manipulating IPv6 ranges on bash so instead of requiring another tool, I'm just doing something that works for my use case.

```
ipv6_with_prefix=$(ip -6 addr show eth0 | grep "scope global" | awk '{print $2}' | head -n1)
IFS="/" read -ra ADDR <<< "$ipv6_with_prefix"
ipv6=${ADDR[0]}
length=${ADDR[1]}

if (( length != 64 )); then
    echo "Error: Prefix length is not 64"
    exit 1
fi

ipv6_68_default="${ipv6%%::*}:1000::/68"
ipv6_68_new_networks="${ipv6%%::*}:2000::/68"

# Generate /etc/docker/daemon.json
cat <<EOF | sudo tee /etc/docker/daemon.json >/dev/null
{
  "ipv6": true,
  "fixed-cidr-v6": "$ipv6_68_default",
  "experimental": true,
  "ip6tables": true,
  "default-address-pools":[
    {"base": "172.31.0.0/16", "size": 24},
    {"base": "$ipv6_68_new_networks", "size": 80}
  ],
  "dns": ["2a00:1098:2c::1", "2a01:4f9:c010:3f02::1", "2a00:1098:2b::1"]
}
EOF

sudo systemctl restart docker
```

### Use docker!

And now, I can use docker happily :) I can expose ports and connect to hosts. One thing I've noticed is that there _is_ some NATting going on, as if I send traffic from a container the traffic is sent from the `2001:0db8:2a01:4f8::1` ip (instead of the container's one). I don't care about as much honestly (if you have ideas on how to change it, I'd love to know though).

A couple interesting things to test:

#### Checking our IPv6
```
docker run --rm alpine wget -qO - https://api64.ipify.org && echo ""
```

#### Checking our IPv4

Here we will see one of nat64.net IPs (they're the ones forwarding our traffic)
```
docker run --rm alpine wget -qO - https://api.ipify.org && echo ""
```

#### Using docker compose

Docker compose creates a default network for each docker compose file you run (I learned that this week, while trying to make things work, you can use `docker network ls` and `docker network inspect`).

Adding the `:2000::/68` network the the list of pools (with 80 as size) makes a compose defined like this:

```
services:
  test:
    image: alpine
    command: /bin/sh -c "wget -qO - https://api64.ipify.org && echo ''"
networks:
  default:
    enable_ipv6: true
```

generate an /80 network that actually works! you can see it working by running

```
docker compose run --rm test
```

and that's it. The only thing I have to be mindful of is enabling IPv6 on the default network in my docker compose files.
