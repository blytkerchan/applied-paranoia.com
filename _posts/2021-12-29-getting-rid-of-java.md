---
author: rlc
comments: true
date: 2021-12-29
layout: post
title: Getting rid of Java - without getting rid of Java code
---
In my [previous post here on applied-paranoia.com](https://applied-paranoia.com/2021/12/23/log4j.html), I concluded that one of the lessons learned from the log4j debacle was that we should get rid of public-facing interfaces (UI and API) based on Java technologies. How do we do that, without also getting rid of the thousands upon thousands of lines of Java code, IP, and “sunk” investment? Clearly, just deleting the code and re-writing it all in some other language is not an option!
<!--more-->

Let’s start with some low-hanging fruit: **don't start any new Java projects**. Java developers can be converted to other, similar languages such as C# with fairly minimal effort and contrary to common belief, C# is just as portable as Java for the vast majority of use-cases. C# also doesn't have some of the cybersecurity issues that Java has been plagued with over the last few decades, in large part because it has had the opportunity to learn from Java, and from Windows, in that respect. If there is a choice for programming languages, *Java should only be used if no other options are available* for new projects.

But let's face it: how often do you really start something new? In the vast majority of cases, the "something new" builds on code you already have, in a code base that may be years or decades old. If you have Java-based IP, you will be writing Java code for a very long time to come.

So, how do you go about securing those services and applications, despite them being written in Java? 

## The issues
There are two major issues to be concerned with:

1. The JVM may "reach out" and connect to third-party servers
2. The JVM may make changes to your filesystem

There are several other issues that you may be concerned about, but that are not specific to the JVM: 

### The JVM reaching out to third party servers
The main issue with log4j is that it could be coerced into using JDNI to download and execute code from a third-party server. Even if the code wasn't executed, because the (unauthenticated) user had full control over the URI used to fetch the code and could use environment variables from the server as well, data from the environment could be leaked by the same occasion even if foreign code execution was turned off.

TLS is usually the go-to technology to secure connections between servers, and it does authenticate the server you're connecting to, but all *that* does in this case is tell you that the server at very.evil.address really is at very.evil.address. It provides authentication and encryption, but it doesn't tell you whether you can trust the resources you're downloading, especially if they are code.

On the other hand, shutting off execution of downloadable code may break your application if it had a legitimate use for such a pattern. Remember Java is a pre-REST technology and many applications from the late 1990s are still used today. There's a reason why similar technologies are still in every-day use. *Should* they be put behind a RESTful interface in stead? Probably, yes. But that can be a lot of work.

So to resolve the issue of the JVM reaching out to third-party servers, without breaking the the applications we're trying to secure, can't just be a matter of "no longer doing that".

### The JVM making changes to the filesystem
Once someone has been able to exploit a vulnerability, they need to "make it stick" if they want to be able to take control of the server (e.g. to enrol it in a botnet) later. Direct ways of doing that would include vulnerabilities that can upload arbitrary files and put them in a pre-set location (such as [CVE-2016-3088](https://nvd.nist.gov/vuln/detail/CVE-2016-3088)), but if you can get the JVM to execute arbitrary code (which most of the recent vulnerabilities appear to be about), you can certainly have that arbitrary code install malware as well.

Changing things in the filesystem is not a bad thing per se: there are many legitimate reasons to do that that have no bearing whatsoever on cybersecurity. It is not something you want to disallow outright, nor something you usually *can* disallow outright without breaking applications. Of course, you could use databases (SQL or NoSQL alike) to  manage your non-volatile state in stead, and in most cases, you should.

## Approaches to a solution
The issues above can be addressed with a number of common tools. These tools may require a bit of extra infrastucture to set up and manage, but most of that can be done using IAAS services which can, in turn, be deployed using an Infrastructure-As-Code approach. I won't go into to the details of setting up and deploying the required infrastructure below, but I will provide a bit of an overview of each of the tools I propose to use as countermeasures to Java's two main issues, and how they help overcome them.

### Sandboxing
One advantage of using a virtual machine is that it can be used to "sandbox" an application: the resources the application gets access to are limited to the ones available within the sandbox. Communications with a sandboxed application is always an issue, though.

The JVM does this as well: you can limit the amount of memory, CPUs, etc. the JVM can use for any particular application, and you can tell it where to find the classes it needs. This actually used to be an argument *for* using Java. The whole issue we're discussing here, though, is that the JVM itself cannot be trusted. The first thing to do, therefore, is to sandbox the JVM.

In general, the easiest way to do this for a monolithic application (like most decades-old Java applications will tend to be), would be to wrap the whole thing in a VM of which the entire contents is controlled. This approach also works with more modern Java applications, which may be less monolithic in nature.

The question then becomes how to control the entire environment within a VM. The answer to that one is actually fairly simple: using an approach that allows you to write, as a single file or a small set of files, the procedure to set up your VM. These files should not end up in the VM itself, or should at least be deleted before the VM is deployed, but they can be versioned and tested.

Now, forget for a moment that I said "VM" in the last two paragraphs.

The "procedure to set up your VM" should of course be a `Dockerfile`. The VM itself could be either a pod in a Kubernetes cluster or just a Docker container running by itself. It's not all that important which one it is, as long as you have a Docker container that contains only what your application needs to run.

Once you have that, you can (and should) set up a mechanism to *frequently* update your image (by re-running Docker and making sure your `Dockerfile` updates the image when run) so at least the underlying "VM" stays up to date. You could make this part of your CI/CD pipeline.

### Limiting filesystem access
Even if you use either disposable VMs or Docker containers to host your Java applications in, you should still limit the JVM's access to the filesystem as much as possible: run the JVM with the least privileges required (even inside the Docker container) and if you mount volumes into the Docker container or disposable VM, make sure you restrict the mount options as much as possible.

For example: most host systems will allow you to strip the "executable" bit from files written to the filesystem and will allow you to filter it out when read. This is a security measure that has been available for decades now, and is still useful today.

If you have applications that communicate with each other through shared files, make sure that once the file is written and published to the other application (or step in the pipeline), it can no longer be altered. It should effectively disappear from view for the publisher before the subscriber can access it. If you don't, you'll have a race condition that may become exploitable.

Configuration and code files should generally be read-only to the application, so *make it so*: if you have the code of the application, make sure it doesn't need anything other than read-only access to those files.

The less your (untrusted) application can do, the less likely its capabilities will be exploited.

### Code signing
Java has implemented optional code signing and signature verification for a while now. It requires the application to be distributed in a JAR file (which is very common) and requires that JAR file to be signed using (the private key corresponding to) a trusted certificate. Once that has been put in place, attempts to execute classes outside of appropriatey signed JARs will fail with an access error.

This is a simple, though somewhat arduous, way to make sure only code that you actually trust is executed: you need to make sure that all the JARs that contain such code are signed, that all the code you need is in those JARs, and that you require signature verification.

For this to *actually* work, though, you need a bit more than just signing all your JARs (which you can do as part of your CI/CD pipeline, provided you run that on a trusted infrastructure):

1. you need to set up a PKI, including expiry policies and the like
2. you need to audit *all* of your dependencies for trust
3. you need to re-package your application, using only those trusted dependencies, into signed JARs
4. you need to reconfigure your deployment to only run signed JARs
5. you need to version-control that deployment configuration
6. you need to test the deployment configuration (preferably regularly) for its inability to run badly signed, or unsigned, JARs
7. you need to make sure you re-deploy your entire application before the certificates you use to sign them expire (so likely at least once a year)

Some of these, like setting up your PKI, would be worth their own post, but I'll just go through each in a single paragraph to explain what I mean and why it's important.

Setting up a PKI is the first step: you need to be sure that what you trust is indicated as such, and to do that you need to authenticate it. Setting up a PKI does not have to be expensive, but you do need to know what you're doing and you need to keep your root CA certificate safe. In this case, you *should not* use a commercial CA unless you root your trust in an intermediate CA certificate that you create yourself: using a commercial CA means that anyone who can pay the fee can get a trusted certificate -- not what you want. There are quite a few caveats to consider here, but without a PKI you can't implement code signing effectively. It's just that simple.

Once you have a PKI in place you need to be sure about what you're signing, which means auditing the code. Some of that can be done automatically: you can, for example, use a static analyzer to analyze all the third-party open source code. If you fix the issues you find (which you generally should) you should contribute the fixes back upstream: it's the right thing to do as a netizen, and it means you don't have to maintain the patches afterwards. Remember to use responsible disclosure if you find security issues in third party code.

Once you've audited your application, you should re-package it into signed JAR files, using only the trusted dependencies that you have now audited. That's just how code signing works in Java.

Once you've done that, you need to configure your deployment to run only signed JAR files. There's plenty of documentation on how to do this, so it shouldn't be too hard, dependending on how your deployment works. This should be part of your CI/CD as well.

Make sure the deployment configuration is version controlled: you want to make sure you can audit any changes that were made to the configuration, and you want to make sure that, just like your code should have, you have a review and approval process in place that explicitly looks for cybersecurity issues. For any change made to the configuration, you need to be able to show why it was done, when it was done, by whom it was done, and what the change was.

Also make sure you (periodically) test that you really can't run unsigned JARs or JARs signed using some other CA: a large part of your security depends on this, so the risk associated with failure is high (the likelihood of things going wrong is high, and so is the impact).

Finally, depending on your PKI expiry policies, you will need to re-deploy the entire application on a regular basis to refresh the certificates being used. This generally means that if you redeploy your application anyway, say on a monthly basis, you don't have anything special to do other than monitor the age of your oldest deployment. Make sure this works, because your application *will* stop working if you forget!

### Proxy
To prevent the JVM from unexpectedly reaching out to the internet, the application should be behind a proxy.

Proxies are what IT in big companies use to eavesdrop on their staff's use of the Internet. Like you shouldn't trust the JVM, IT doesn't trust non-IT staff, so internet usage is monitored for anything illegal, inappropriate, or unsafe for company IP and infrastructure.

While we don't expect the JVM to download videos of cute cats or to spontaneously buy illegal firearms, we do need to make sure that it doesn't connect to any servers on the Internet that aren't on a "white list", and you'll want to scan the contents of the messages being exchanged.

Being able to scan the messages being exchanged usually means the proxy will "spoof" the external site's certificate with its own, which, again, means you need a PKI. Note that this implies that the proxy implements its own CA. It also means its CA certificates *should not* be signed by a commercial trusted root (because doing that would be ***very*** dangerous) and should not be trusted anywhere outside of your organization.

The proxy should basically, at the very least, check that the server being reached out to is on the white list, create a certificate to spoof the target, reach out to the server itself, validate then relay the request, validate then relay the response, and keep validating and relaying requests and responses as long as it passes muster.

Obviously, if your application has no legitimate reason to reach out to the Internet, you don't need a proxy: you just need a firewall (which you need anyway).

### API Gateways and deep firewalls
Outgoing traffic is not the only problem, though: ultimately, the issue is that someone from the outside is trying to coerce your application into doing something you don't want it to do. It would be a pretty odd approach to lock your application up in a sandbox without even looking at what's going into the application.

An API Gateway does just that. It's usually used for three things: load balancing, HTTPS-to-HTTP forwarding (so your application code doesn't have to deal with HTTPS), and deep inspection. We're interested in the deep inspection in this case.

OWASP, the Open Web Application Security Project, has a set of "core rules" that you can find at [coreruleset.org](https://coreruleset.org/). Implement them. Use ModSecurity if you must (but not it will no longer have commercial support in 2024).

This is probably the hardest part (this and the proxy, really): it will cost the most to implement and maintain, but it is also your first line of defense.