---
author: rlc
comments: true
date: 2022-01-06
layout: post
title: Responsible disclosure
---
When it comes to cybersecurity, surprises are generally not a good thing: they usually mean something is vulnerable, something went wrong, or something blew up (hopefully figuratively). They also *always* mean something needs to be done: some software or firmware needs to be updated, some configuration needs to be changed, operations are disrupted.

Responsible disclosure doesn't take the surprise away completely, but softens the blow a bit. It basically means that when you find a vulnerability, especially if you find it in a popular piece of software, you don't immediately post it to your blog or social media: you use the "proper channels" to tell whoever maintains the software about it, so they can fix it, communicate with their stakeholders, and make sure that when the vulnerability does become public knowledge, it's already been fixed.
<!--more-->
Responsible disclosure is not easy: it puts a burden on whoever found the vulnerability (who ends up being called a "security researcher" no matter what they do in their day-to-day life) to find the "proper channel", but it also puts a burden on whoever wrote the software in the first place to create that channel. Especially for small vendors, small teams, or open source software volunteers, that can be quite a burden.

## The sorry state of responsible disclosure in Canada
Some countries, like the US, have government agencies to take on some of the burden off the security researchers. Canada has no such government organization, as [shown by the Cybersecure Policy Exchange](https://www.cybersecurepolicy.ca/vulnerability-disclosure), a cybersecurity lobbying organization funded by RBC and run from Ryerson University in Toronto. As they point out:

* Canada does not have a "distinct and clear disclosure process for vulnerabilities involving government systems"
* Canada does not "[describe] the vulnerability submission and verification process"
* Canada does not "[provide] terms and rules for disclosures"
* Canada does not "publicly dessimate information about vulnerabilities disclosed through [a] coordinated process"
* Canada does not "publicly give acknowledgement or credit after disclosure"

Our neighbour to the South, as well as the European Union, Japan, Russia, and Great Britain do all of these, and China does all of them except for public acknowledgement, according to the Cybersecure Policy Exchange.

It's rather saddening to see that my adopted country is lagging behind, but this post is not about Canada.

A "distinct and clear disclosure process" would lighten the load on "security researchers" a bit: it allows them to contact a single (government) agency that can then coordinate with affected vendors, businesses and government services to ensure resolution of the issue and careful dissemnation of relevant information. For example, the security researcher, or the affected vendor or open source project, does not have to try to find out who is affected by the vulnerability if there's a government agency that is dedicated to doing that. Pro-actively reaching out to critical infrastructure providers (i.e. privately owned utilities for the power network, water and waste water, telephony, etc.) to get an inventory of potentially-vulnerable (that is: all) software used in critical systems or have them maintain such an inventory in case there's a vulnerability to be dealt with is a job better suited for a government agency than for dozens of small teams.

So, absent government support, who does a security researcher contact?

## Responsible disclosure in businesses, small, medium, and large
Usually, the only point of contact an "outsider" has with a company is either through sales or support. Typically, neither sales nor support are trained to deal with cybersecurity issues, but they should at least know who to route the issue to. This is where things start getting complicated, though.

While large businesses may (and really should) have a dedicated cybersecurity team to help product teams coordinate their responses to vulnerabilities and incidents, those teams should provide guidance and support but will typically not know the ins and outs of the market a particular product team operates in: that's Marketing's job. That means that such dedicated teams should not determine how to implement cybersecurity requirements, but should lay out those requirements and provide tools to analyse conformance in light of the product's threat model and deployment model. It is then up to the product teams to develop those threat models and deployment models, vulnerability management plans, provide their customers with guidelines on how to deploy the product, and show conformance to requirements assuming that those guidelines are followed. I.e. dedicated cybersecurity teams need to adopt a "you can do it, we can help" attitude.

Smaller business don't have dedicated teams for cybersecurity: such teams are expensive and, while they are worth the investment for larger businesses after some time (i.e. as cybersecurity incidents which would negatively affect the company's reputation are avoided), smaller businesses simply don't have the resources  to make that investment. They may, from time to time, be able to engage with a consultant to get training on how to develop threat models and deployment models, vulnerability management plans, what zero-trust architectures are, and what some relevant industry standards are to conform to, but such engagements do not change where the responsibility for the product and its security ultimately lies: with the product team.

That means that responsible disclosure should go to the product team first, at which point a response team made up of marketing, R&D, project management, and (internal if available, external otherwise) cybersecurity experts needs to come together and assess the issue.

## Responsible disclosure in open source projects
We'll leave businesses aside for a moment and turn our attention to unfunded open source projects. There are thousands of these, maintained by unpaid volunteers who do this important work for the love of the challenge, the community, or whatever else drives them. I've contributed to a few open source projects myself: it's fun and sometimes quite engaging.

From a cybersecurity perspective, though, it is hard to implement good security practices if the only resource you have is your own free time. GitHub and similar platforms provide some resources, such as automatic alerts to let you know you depend on something vulnerable, but it doesn't "automagically" provide you with preventative measures such as static analysis, nor with necessary project infrastructure and guidelines to build vulnerability management plans, threat models, etc.

Most open source projects do not have documentation to tell you how to safely deploy them, do not register their users so they can be updated in case there's a vulnerability, don't distribute security bulletins, etc. The Apache Foundation provides some of that infrastructure and provides a framework to work in, but many other organizations do not, and most open source project are not part of any organization to start with.

So, for a run-of-the-mill open source project with no funding, no corporate sponsor, and no foundation to support it, who you gonna call? (Usually, the developer.)

Difficulties in general
			Know who to contact
				many support teams are not trained for cybersecurity issues
					need to know what to communicate to users
						don’t acknowledge a security issue without input from R&D
						need analysis according to deployment and threat models
						need to understand how the user uses the software
							may be a vulnerable deployment rather than a vulnerable product
					need to know who to contact within the development team
						designated cybersecurity contact
				many development teams don’t have clear vulnerability management plans
					vulnerability management plans need to:
						determine how to handle incoming communications
							users reporting vulnerabilities
							the development team finding vulnerabilities
								often goes unreported, because not recognized
							static analysis finding vulnerabilities/CWEs
						determine how to triage vulnerabilities
							deployment model
							threat model
							path to vulnerability
							CVSS
						determine how to communicate vulnerabilities
							disclose to users
								may not want to know — regulatory constraints
								“canary” announcements
							timing vs. fix
								if quick fix is likely, may want to wait
								if there are work-arounds, may want to communicate early
							testing the fix
								make sure no new vulnerabilities are introduced
								breaking existing features?
							releasing the fix
					can’t make it up as you go
						know your market
						know your product
						get Marketing input
						invest in static analysis, modeling
		Difficult with Open Source
			Everything is Out There
				Hard to keep the CVE secret
				code is published to everyone (including the public, and therefore the black hats) at the same time
					commit messages will generally reference security issue (even if not CVE number)
					committed code will fix the issue, but also expose it to knowledgeable onlookers
				when published, how to urge people to update quickly without pointing to the vulnerability?
				