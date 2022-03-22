---
author: rlc
comments: true
date: 2022-03-20
layout: post
title: Responsible disclosure
---
When it comes to cybersecurity, surprises are generally not a good thing: they usually mean something is vulnerable, something went wrong, or something blew up (hopefully figuratively). They also *always* mean something needs to be done: some software or firmware needs to be updated, some configuration needs to be changed, operations are disrupted.

Responsible disclosure doesn't take the surprise away completely, but softens the blow a bit. It basically means that when you find a vulnerability, especially if you find it in a popular piece of software, you don't immediately post it to your blog or social media: you use the "proper channels" to tell whoever maintains the software about it, so they can fix it, communicate with their stakeholders, and make sure that when the vulnerability does become public knowledge, it's already been fixed.
<!--more-->
Responsible disclosure is not easy: it puts a burden on whoever found the vulnerability (who ends up being called a "security researcher" no matter what they do in their day-to-day life) to find the "proper channel", but it also puts a burden on whoever wrote the software in the first place to create that channel. Especially for small vendors, small teams, or open source software volunteers, that can be quite a burden.

## The sorry state of responsible disclosure in Canada
Some countries, like the US, have government agencies to take on some of the burden of the security researchers. Canada has no such government organization, as [shown by the Cybersecure Policy Exchange](https://www.cybersecurepolicy.ca/vulnerability-disclosure), a cybersecurity lobbying organization funded by RBC and run from Ryerson University in Toronto. As they point out:

* Canada does not have a "distinct and clear disclosure process for vulnerabilities involving government systems"
* Canada does not "[describe] the vulnerability submission and verification process"
* Canada does not "[provide] terms and rules for disclosures"
* Canada does not "publicly dessimate information about vulnerabilities disclosed through [a] coordinated process"
* Canada does not "publicly give acknowledgement or credit after disclosure"

Our neighbour to the South, as well as the European Union, Japan, Russia, and Great Britain do all of these, and China does all of them except for public acknowledgement, according to the Cybersecure Policy Exchange.

It's rather saddening to see that my adopted country is lagging behind, but this post is not about Canada.

A "distinct and clear disclosure process" would lighten the load on security researchers a bit: it allows them to contact a single (government) agency that can then coordinate with affected vendors, businesses and government services to ensure resolution of the issue and careful dissemination of relevant information. For example, the security researcher, or the affected vendor or open source project, does not have to try to find out who is affected by the vulnerability if there's a government agency that is dedicated to doing that. Pro-actively reaching out to critical infrastructure providers (i.e. privately owned utilities for the power network, water and waste water, telephony, etc.) to get an inventory of potentially-vulnerable (that is: all) software used in critical systems or have them maintain such an inventory in case there's a vulnerability to be dealt with is a job better suited for a government agency than for dozens of small teams.

So, absent government support, who does a security researcher contact?

## Who to contact for responsible disclosure
### Who to contact in businesses, small, medium, and large
Usually, the only point of contact an "outsider" has with a company is either through sales or support. Typically, neither sales nor support are trained to deal with cybersecurity issues, but they should at least know who to route the issue to. This is where things start getting complicated, though.

While large businesses may (and really should) have a dedicated cybersecurity team to help product teams coordinate their responses to vulnerabilities and incidents, those teams should provide guidance and support but will typically not know the ins and outs of the market a particular product team operates in: that's Marketing's job. That means that such dedicated teams will not necessarily know who uses the product and how it is used, and will not be able to analyse the issue to ascertain whether it is actually a cybersecurity issue in the product. It is up to the product teams to develop threat models, deployment models, and vulnerability management plans, provide their customers with guidelines on how to deploy the product, and show conformance to requirements assuming that those guidelines are followed, and ultimately to respond to any issues that may occur. I.e. dedicated cybersecurity teams need to adopt a "you can do it, we can help" attitude.

Smaller business don't have dedicated teams for cybersecurity: such teams are expensive and, while they are worth the investment for larger businesses after some time (i.e. as cybersecurity incidents which would negatively affect the company's reputation are avoided), smaller businesses simply don't have the resources  to make that investment. They may, from time to time, be able to engage with a consultant to get training on how to develop threat models and deployment models, vulnerability management plans, what zero-trust architectures are, and what some relevant industry standards are to conform to, but such engagements do not change where the responsibility for the product and its security ultimately lies: with the product team. Such engagements also do not typically include rapid response to cybersecurity incidents, even when such services are available.

That means that responsible disclosure should go to the product team first, at which point a response team made up of marketing, R&D, project management, and (internal if available, external otherwise) cybersecurity experts needs to come together and assess the issue, under the responsibility of the product team.

Customer support teams are often not trained for cybersecurity issues. In light of this, they need to be kept in the loop and, while they often won't be included in the response team directly, they should at least be listened to and be allowed to voice their concerns and those of the customers they're in contact with, and be informed on the progress of the analysis and the fix.

The support team will often be the best informed within the company as to how customers use the product, and may therefore be better informed than the development team to know how vulnerable systems really are. This can be an important input into the analysis, as the vulnerability may be one of deployment rather than the product itself.

### Who to contact in open source projects
We'll leave businesses aside for a moment and turn our attention to unfunded open source projects. There are thousands of these, maintained by unpaid volunteers who do this important work for the love of the challenge, the community, or whatever else drives them. I've contributed to a few open source projects myself: it's fun and sometimes quite engaging, but I wouldn't be able to express what drove me do to it.

From a cybersecurity perspective, though, it is hard to implement good security practices if the only resource you have is your own free time. GitHub and similar platforms provide some resources, such as automatic alerts to let you know you depend on something vulnerable, but it doesn't "automagically" provide you with necessary project infrastructure and guidelines to build vulnerability management plans, threat models, etc. or to respond to emergent threats.

Most open source projects do not have documentation to tell you how to safely deploy them, do not register their users so they can be updated in case there's a vulnerability, don't distribute security bulletins, etc. The Apache Foundation provides some of that infrastructure and provides a framework to work in, but many other organizations do not, and most open source project are not part of any organization to start with.

So, for a run-of-the-mill open source project with no funding, no corporate sponsor, and no foundation to support it, who you gonna call? Usually, the developer.

## A few prerequisites for responsible disclosure
Regardless of who you end up contacting, here's a few things that need to be true for any responsible disclosure:

1. **Disclosure needs to *not* be public**, or at least not right away: the product team (or lonesome developer) needs to have time to prepare a response, figure out whether the vulnerability is legitimate, fix it if it is, update documentation, prepare a security bulletin, etc. A lot of work goes into responding to a vulnerability, so disclosing it too quickly will do more harm than good.
2. **The product team (or lonesome developer) needs to be responsive**: they need to quickly set up their response team, which needs to include someone who is in charge of coordinating the response, someone who can analyse and fix the underlying issue, and someone who knows who the stakeholders are and can coordinate with them. For small businesses and open source projects, this may well all be the same person (who is in for a pretty stressful few days/weeks in that case), but for larger businesses it really shouldn't be.
3. **Do not acknowledge a security issue without input from the development team**: they need to analyse the issue first, and confirm that it's a cybersecurity issue (and not just a run-of-the-mill bug). This is especially important for support teams: if someone calls support about an issue, acknowledging it as a cybersecurity issue may set of vulnerability management plans at the customer which may not have an "exit clause" in case the issue was not a vulnerability to begin with.

## Difficulties with responsible disclosure in open source projects
Aside from the difficulties already mentioned above, open source projects have some extra difficulties that commercial software does not when it comes to responsible disclosure. These may be summarized as "everything is out there".

If there is any kind of team or community to speak of for the project, any issues or changes to the software will generally be discussed on a mailing list that will often be public. Such mailing lists may be monitored by so-called "black hat hackers", especially if the software is popular. Keeping vulnerabilities off that public forum is often more difficult than it may seem, as that requires the developers of the project to have some other, non-public means of communication.

Even if that is the case, a fix will eventually be published in source code, by being pushed to a git repo or even just published as a tarball. Most open source projects publish source code, and may or may not publish binaries. Again, it is easy to monitor such releases and black hat hackers generally will do just that. While the commit message may not refer to a CVE number directly, it will still generally describe something like "fix a race condition that could occur if ...", which may be enough to understand that a vulnerability is being addressed. Such changes may fix the issue, but will also expose it to knowledgeable onlookers, who may then exploit deployments that haven't been updated yet.

Once the fix has been published, open source projects don't necessarily know who uses their software, so it becomes difficult to discreetly contact stakeholders to have them update their software without making the vulnerability public. That means that stakeholders have no choice but to learn about the vulnerability at the same time (or after) the "bad guys" do as well.

