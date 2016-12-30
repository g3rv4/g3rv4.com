---
layout: post
title: A home made DDNS service with AWS's Route 53
date: '2013-10-20T02:23:00.003-02:00'
tags:
- sip
- amazon
- ddns
modified_time: '2013-12-17T20:41:30.866-02:00'
blogger_id: tag:blogger.com,1999:blog-7815098159792356641.post-6389703513275711119
blogger_orig_url: http://blog.gmc.uy/2013/10/a-home-made-ddns-service.html
---
This is how I _used_ to update my Route 53 DNSs record. Right now I'm using a python script, but as soon as I'm bored enough to update it, I want to switch to DigitalOcean's DNS... they're <s>free</s> included and update super fast.

<!--more-->
I have a dynamic IP, and playing with twilio and SIP, I needed something fairly reliable to work as DDNS. As I have a synology box, I was using their service... but lately it wasn't working fine (sometimes it just said that the ip was updated when it wasn't)

I've been using AWS for different things... SES to send emails, Route 53 for DNS and what's awesome about it is that everything is webservice accessible. I checked several DDNS commercial offers but they were really expensive for the money I wanted to spend on it... so I figured I could update my DNS on Route 53 using AWS's API.

It was extremely simple... I have a cron on my Synology station that does a request to a server I own every minute. The only thing I didn't like about the Route 53 webservice is that you can't do just an update... you need to delete the old record and then create the new one... but this code gets the job done for me.
{% highlight c# %}
public ActionResult UpdateIp(string token)
{
 if (token != ConfigurationManager.AppSettings["UpdateIpToken"])
 {
  return Json(false, JsonRequestBehavior.AllowGet);
 }
 var current = (string)HttpContext.Cache["lastIp"];
 if (current == null || current != Request.UserHostAddress)
 {
  var credentials = new BasicAWSCredentials(ConfigurationManager.AppSettings["AWS.AccessKey"], ConfigurationManager.AppSettings["AWS.SecretKey"]);
  Amazon.Route53.AmazonRoute53Client client = new Amazon.Route53.AmazonRoute53Client(credentials);

  //get the current ip
  var listreq = new Amazon.Route53.Model.ListResourceRecordSetsRequest();
  listreq.HostedZoneId = ConfigurationManager.AppSettings["AWS.HostedZoneId"];
  listreq.StartRecordType = "A";
  listreq.StartRecordName = ConfigurationManager.AppSettings["AWS.Domain"];
  listreq.MaxItems = "1";
  var res = client.ListResourceRecordSets(listreq);
  string oldip = null;
  if (res.ListResourceRecordSetsResult.ResourceRecordSets.Count > 0 &amp;&amp; res.ListResourceRecordSetsResult.ResourceRecordSets.First().Name == ConfigurationManager.AppSettings["AWS.Domain"] + ".")
  {
   oldip = res.ListResourceRecordSetsResult.ResourceRecordSets.First().ResourceRecords.First().Value;
  }

  var req = new Amazon.Route53.Model.ChangeResourceRecordSetsRequest();
  req.HostedZoneId = ConfigurationManager.AppSettings["AWS.HostedZoneId"];
  req.ChangeBatch = new Amazon.Route53.Model.ChangeBatch();

  Amazon.Route53.Model.Change reqitem = null;
  Amazon.Route53.Model.ResourceRecord resourceRecord = null;
  if (oldip != null)
  {
   reqitem = new Amazon.Route53.Model.Change();
   req.ChangeBatch.Changes.Add(reqitem);
   reqitem.Action = "DELETE";
   reqitem.ResourceRecordSet = new Amazon.Route53.Model.ResourceRecordSet();
   reqitem.ResourceRecordSet.Name = ConfigurationManager.AppSettings["AWS.Domain"];
   reqitem.ResourceRecordSet.Type = "A";
   reqitem.ResourceRecordSet.TTL = 60;
   reqitem.ResourceRecordSet.ResourceRecords = new List<Amazon.Route53.Model.ResourceRecord>();
   resourceRecord = new Amazon.Route53.Model.ResourceRecord();
   reqitem.ResourceRecordSet.ResourceRecords.Add(resourceRecord);
   resourceRecord.Value = oldip;
  }

  reqitem = new Amazon.Route53.Model.Change();
  req.ChangeBatch.Changes.Add(reqitem);
  reqitem.Action = "CREATE";
  reqitem.ResourceRecordSet = new Amazon.Route53.Model.ResourceRecordSet();
  reqitem.ResourceRecordSet.Name = ConfigurationManager.AppSettings["AWS.Domain"];
  reqitem.ResourceRecordSet.Type = "A";
  reqitem.ResourceRecordSet.TTL = 60;
  reqitem.ResourceRecordSet.ResourceRecords = new List<Amazon.Route53.Model.ResourceRecord>();
  resourceRecord = new Amazon.Route53.Model.ResourceRecord();
  reqitem.ResourceRecordSet.ResourceRecords.Add(resourceRecord);
  resourceRecord.Value = Request.UserHostAddress;

  client.ChangeResourceRecordSets(req);
  HttpContext.Cache["lastIp"] = Request.UserHostAddress;
 }
 return Json(true, JsonRequestBehavior.AllowGet);
}
{% endhighlight %}
