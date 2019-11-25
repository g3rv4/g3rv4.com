---
layout: post
title: "Using Azure Pipelines with auto-provisioned self-hosted agents."
date: "2019-11-25 09:00:00 -0300"
---
I started playing with Azure Pipelines, and while it looked great, the lack of caches and inspectability on Microsoft's agents made it clear that I wanted self-hosted agents. BUT I didn't want to pay for a machine that I will only house a couple of hours a month. In this post, I touch on my motivations, the challenges I found, and how I made it work.

<!--more-->

I have lots of small projects... some are abandoned, others are being used but very stable for my needs. And when I work on one of them, it's usually a couple of hours, and then it goes back to the dormant state.

Because I enjoy playing with CI/CD, I use TeamCity for their build and deploy (I have 0 projects with tests, so I guess I could just say CD). I have a $20 DigitalOcean droplet where I run a Linux SQL Server Express, all my projects as Docker containers, and an NGINX reverse proxy that exposes them.

On that same droplet, I have TeamCity with three agents (also Docker containers). That works, but... I'm paying $20/mo just because TC is quite resource-intensive. Without it, I'd be ok with a $10/mo droplet.

Some people at work mentioned Azure Pipelines, and it sounded interesting. It's a build management and continuous integration server on Microsoft's cloud. For public projects, they let you use up to 10 agents hosted by them (with restrictions on the time that can be used) and one self-hosted agent.

Self-hosted agents are better for me since I can log in to the machine and debug what happened to figure out why. Also, Microsoft agents start from scratch on every run. That means that if you're pulling a docker image, you do so on _every_ build even if you do ten builds in 10 minutes.

Initially, the options I thought were available were either:

* Have the agents be docker containers running on my server (this is not great... docker ends up using lots of space when you recreate images a lot over the years. Also, on every build you're taking resources from your applications)
* Have a secondary server that's used only for building. This kind of works, but I'd end up paying for a server running all the time when I need it 3 or 4 times per month.

But then, I realized that a better scenario would be:

* Have an agent provisioned as soon as a build is needed
* Have the agent destroyed after X minutes without builds

I would only pay for what I use. No builds? No invoices to pay.

## Provisioning an agent using Terraform

I wanted to build this in a way that wasn't tied to a particular cloud provider. Part of the project is figuring out what's the best provider that works for this scenario, so I knew I had to find a way to provision and deprovision virtual machines _somewhere_ in a way that didn't involve learning and orchestrating proprietary API calls.

I had my eyes set on Terraform. I checked out Ansible, but Terraform won just because it's a tool we use at work, and I like to keep the tooling in sync (even if it's a bit more complicated than what's needed) so that I learn things that I can apply on my day to day work.

Provisioning an agent on DigitalOcean was super straightforward (and I can say that for Azure and Google Cloud as well: you can find examples on the Terraform docs and they just work). Same thing about destroying the environment. What came as a surprise to me was that I suddenly needed to keep the state file _somewhere_ that was secure... and considering my scenario required automatically triggering actions as a reaction of events, it meant I had to expose it somehow. Which also involved dealing with authentication. It all sounded non-trivial.

### Terraform Cloud

But lucky me! Terraform has a Cloud version where they do exactly what I need. They get the definition files from a repository and expose an API I can hit to create and destroy the environment. And they manage secrets in a better way than I could on a side project, they store the state file and offer a free tier that works very well for me (you don't get multiple users or scoped API tokens).

So this is what I'm going to use to create and destroy agents! There's a caveat though: you can auto-approve creations, but you can't auto-approve destroy plans. So to destroy an environment via the API, you need to:

1. Create a destroy plan via the API
2. Wait for the plan to be completed (by polling or by receiving an HTTP notification)
3. Approving the plan via the API

This adds a tiny bit of complexity to the project, but manageable. I don't want to expose an HTTP endpoint for this initially.

### Creating an agent

You can see [here](https://github.com/g3rv4/terraform-pipeline-agent/tree/c51506de96909523f45756f1d865144e3233e49c) what the definition of my first agent looked like. I then decided to [use cloud-init](https://github.com/g3rv4/terraform-pipeline-agent/commit/45bb8bbeb328dd6b6751d9ac15edfd31a7473ad6) because all the providers I'm considering support it, and I want to get things done _fast_. cloud-init sounds like it would be called as soon as possible, while the ssh agent may take some time to be initialized.

So I did a little trick:

* I have an ssh provisioner that checks for a finished file, not existing on the VM creation. While it doesn't find it, it just tails the cloud-init log file, so that I get to see what's going on
* Once cloud-init finishes, it touches a finished file that the provisioner uses to stop tailing the log, and it starts doing its thing

Cloud-init installs some dependencies (I want to be able to run Powershell, and I want to have docker available always) and the Azure Pipelines agent. The ssh provisioner starts the agent.

So now, I have an API-invokable way of creating and destroying an agent. YAY!

Note that I don't care about multiple agents at this point. This is because I haven't bought any parallel jobs (yet).

## Playing with Azure Pipelines and its API

I need to be told that "hey, there's a build starting!" somehow so that I create an agent if required. Unfortunately, Azure Pipelines doesn't have that notification. You can be notified when a build ends, but that doesn't help me.

You can see the agents you have, their status, and their last job (which is useful for "destroy the agent if there haven't been any builds in the last X minutes"), but there's nothing in terms of learning about a queued job.

Another interesting bit is that if there are no agents at all, a build will fail. So there's needs to be an agent (even offline) for the build to be queued. But that's also not ideal... in the following scenario:

* There's an agent offline
* A build is queued
* The agent comes online

The build doesn't start! You need to queue another build for the first one to be started. That's not great.

Now, what I *can* do is run whatever code I want on Microsoft's agents. That means I can make _that_ agent responsible for creating the agent that will eventually build my code. Or it can do nothing if there's already an agent online.

## Choosing a cloud provider

Part of this quest is to find a fast cloud provider (I don't want to sit forever the first time I push to a project) and cheap. I don't care as much about the price of the VM itself: considering this would be on sporadically, the cost per hour is not that important. I'm more interested in what intervals they use for their charges and what's their minimum charge for a VM.

To improve the speed of the agent creation, I'm open to:

1. Creating an agent with cloud-init and all the initial set up
2. Creating an image from that agent
3. Use that image for agent creation from then on

### DigitalOcean

I'm used to DigitalOcean; I know where things are. They are also quite fast, but the image creation trick didn't work. Well, it does work, but I couldn't get a significant improvement on the droplet creation time over running all the steps. It sounds like if creating a VM from one of their predefined images was significantly faster than from a custom image (they probably have some droplets already created that they initialize on demand. They can't do that with custom images). If we add that we're paying for that image, it doesn't make sense.

### Azure

I really really really wanted to like Azure. It's what we use at work, and I have a $50/mo MSDN subscription that should be enough to cover for this (if the terms allow this use, which I'd check after choosing it). They also bill per second.

But I didn't like it. VM creation takes a ridiculous amount of time... and you need to create oh-so-many resources to even start creating the VM. It's just slow, really slow. In the time DigitalOcean has an Azure Pipelines agent reporting as online, Azure still doesn't have a VM for me.

I kept on rewriting history, so I can't link you to a Terraform config using Azure.

### Google Cloud

Google Cloud was... all I was looking for. They create a VM in under 10 seconds (from their images or a custom one), and then it takes ~40 seconds to boot. They charge per second and have Preemptible VMs. These are machines that can be destroyed at any time and can run up to 24 hours at a time but are significantly discounted. This is perfect for my use case! And I get a safeguard that if my logic to destroy agents is buggy, Google will take care of destroying it after a day.

[This is my Terraform config for an agent on GCP](https://github.com/g3rv4/terraform-pipeline-agent/tree/5e0990903afca82b57fc64b1f2e9af000bdda9c4).

### AWS

After Google being so amazing, I didn't even test AWS.

## Choosing a strategy to tie everything together

There are several moving parts to this project. When thinking about how to make _something_ orchestrate those moving parts and after a failed approach using Powershell (things worked, but it was quickly becoming spaghetti code) I decided to build a dotnet library and CLI tool (both are available on NuGet)

### PipelinesAgentManager

PipelinesAgentManager is a library that makes it easy to support this specific use case. It lets you:

* Start an agent if needed (if needed = there's no online agent on Azure Pipelines in the given agent pool)
* Destroy agent if needed (if needed = there's an online agent on the given agent pool, and there haven't been builds in the last X minutes)
* Apply a Terraform plan if needed (if needed = there's a plan awaiting manual confirmation)
* Apply a Terraform plan given its run id
* Get details for a Terraform run
* Get details for an agent

I did this as a library since I wanted to play a bit with AWS Lambda functions to trigger the confirmation after Terraform notifies of a run in this state (you can see the project [here](https://github.com/g3rv4/TerraformAutoApply)). This gets you the fastest destroy possible (since it starts as soon as it's notified), but it adds one moving piece. Also, I don't care how long it takes to destroy an agent... I care about creation being fast.

### PipelinesAgentManager.Cli

PipelinesAgentManager.Cli is a CLI tool that lets you call the functionality exposed by PipelinesAgentManager, with some added things like "create an agent if needed and wait for Azure Pipelines to report the agent as online."

### Putting everything together.

The idea is to:

* As the first stage on every build, have a "wake up" step that runs on a Microsoft hosted agent. That wake up is going to call "Start an agent if needed" and wait for Azure Pipelines to report it as online (so that builds don't get in the weird state where they're enqueued but don't start until there's another build)
* On the agent provisioning logic, add a couple of cron jobs:
   * One that runs every minute that calls "Destroy agent if needed."
   * One that runs every minute that calls "Apply a Terraform plan if needed."

And... that's it! Whenever I push to an Azure Pipelines project, an Azure agent runs. If there's an agent, it does nothing. If there isn't, it provisions one and waits for it. And it's the agent the one that takes care of its own destruction.

## Deploying my build to production

This is the painful part of Azure Pipelines. I want to:

* Have my builds automatically deployed to my staging environment
* Have my builds deployed to my production environment once I approve them

Azure Pipelines now has multi-staged pipelines, where you can define the different steps, and on their UX, you can specify which approvals are needed. That is good... with the exception that if you go this route, you can't use Deployment Groups (the deploy logic only runs on one agent, the one that happens to pick up the job) and the deploy counts as a parallel job, getting in the middle of other builds.

I wanted to use deployment groups... but there's no way to specify their logic in the YAML file. To set up the release logic, you need to click like a savage.

To reduce all the clicking (and also to make it easier to reuse the code), I set up a release process that goes like this:

* Is automatically triggered by an artifact being published
* The deploy to dev stage runs two deployment group jobs:
 1. Clone a repo with deploy scripts
 2. Runs the deploy script passing `-Environment Dev`
* The deploy to prod stage runs the same jobs as the deploy to dev stage, but passing `-Environment Prod`

It works for me... but if this was a real project, it's an extremely brittle solution since you have no visibility on the release if/when the deploy scripts get modified. This may cause Release N to work but Release N+1 to fail even when using the same artifact (since the clone is getting master's head).

It also makes it impossible to run the release steps as they were on a particular release. If you know that release P works, you can't just reapply it. You also need to modify the version of the release scripts that get pulled to match what it was when release P was run.

I guess this is the thing I liked the least about the whole experience, and [it seems like I'm not alone](https://github.com/MicrosoftDocs/vsts-docs/issues/4486).

## Last words

This is my first attempt into solving this... it's all very rough, so if you have ideas on how to make it better (or reduce the custom tooling), let me know! I'd love to improve it and learn better ways of provisioning / deprovisioning agents.

## Resources

* You can find [my Terraform creation files](https://github.com/g3rv4/terraform-pipeline-agent).
* You can find [PipelinesAgentManager](https://www.nuget.org/packages/PipelinesAgentManager) and [PipelinesAgentManager.Cli](https://www.nuget.org/packages/PipelinesAgentManager.Cli) on NuGet. You can also [find their code on GitHub](https://github.com/g3rv4/PipelinesAgentManager).
* You can see the [azure-pipelines.yml file](https://github.com/g3rv4/g3rv4.com/blob/master/azure-pipelines.yml) I'm using to deploy this blog.
* You can see the [AWS Lambda auto-approver project](https://github.com/g3rv4/TerraformAutoApply).
* You can also check out [my deploy scripts](https://github.com/g3rv4/ReleaseScripts).

Unfortunately, I don't know of a way of sharing the deploy configuration.