---
date: 2026-06-06
---

A paper in the latest issue of Communications of the ACM took me down a rabbit hole, and I'd like you to come with me.

The paper, "Are We Actually There? Assessing RPKI Maturity" by Schulmann et al., is an incisive and comprehensive review of the maturity of RPKI and its application to global internet routing.

Like most users of the internet, I have largely ignored — and frankly been ignorant of — BGP, the Border Gateway Protocol, which is used to interconnect the thousands of networks that compose the internet. It's a protocol I typically don't think much about, but of course I use it on a daily basis, because I use Google, email, and so on, and so do you

Anyway, BGP's lack of robust security and its vulnerability to both innocent typos and malicious attacks does not surprise me, but it also has not concerned me as much as it probably could or should.

The internet backbone is not secure. Back in the late 1980s when the Border Gateway Protocol was created, everything was based on optimism, a friendly smile, and a handshake — something worked out on the back of a napkin over a few beers. And honestly, some of the nicer networking protocols came about exactly like that: discussed over dinner and beers. One of the protocols I actually do think about a lot was born that way as well.

Anyway, back in 2012, RPKI was standardized as a suite of RFCs. The SIDR working group published the core specifications in a batch: RFC 6480 as the architectural overview, followed by a cluster of RFCs covering repository structure (6481), the ROA profile (6482), route origination validation (6483), certificate policy (6484), algorithm requirements (6485), manifests (6486), the X.509 resource certificate profile (6487), the signed object template (6488), and several more covering key rollover, trust anchor locators, and provisioning. The RPKI-to-Router protocol — which defines how a Relying Party validator feeds validated data to BGP routers — followed about a year later as RFC 6810.

RFC 7115 came out in 2014 and laid out the best current practice for deploying origin validation, including the fail-open posture that most networks still use today. Then in 2017, RFC 8182 introduced RRDP, which is an HTTP-based alternative to rsync for pulling down repository data. That same year, RFCs 8205 through 8209 defined BGPsec, which goes beyond just validating where a route originated and actually cryptographically authenticates the whole AS path. RFC 8210 also came out in 2017 as an update to the RTR protocol.

Standard tooling was added in 2018: RFC 8416 introduced SLURM, which lets operators locally override RPKI validity decisions when they need to work around known misconfigurations or complex multi-homing configurations.

So RPKI has been actively developed since 2012 — over a decade now, almost a decade and a half. And yet it is not that widely adopted. As the ACM paper makes clear, even after more than a decade, it is not necessarily all that mature.

Here is what I mean by that, and what I think the authors mean by it. When you try to find a route to some other IP address, the best route — the shortest route — is through a gateway that has the most specific announcement for that destination. Routers announce which address prefixes they have access to, and a more specific prefix (more bits) wins out over a less specific one. Fewer hops is better, and a more specific prefix gives you a better path.

So your routing table tells you what your best path is, but the contents of that routing table can basically come from anywhere.

To secure that, the messages that fill up your routing table should be authenticated. Authentication is the cornerstone of everything in security. The question is: how do you authenticate those messages, how do you sign them, and what do you do when you have no authenticated messages to work with? The RFCs try to answer that, but as Schulmann et al. show, interpretations of what they mean differ between implementers and the software that implement them is buggy and vulnerable.

The core issue is how that authentication works, and whether everyone agrees on how it works. If they do not agree, some messages may be dropped that should not be, because they are actually authentic. Some messages may be accepted that should not be, because they are actually not authentic. And some messages will simply be accepted because you have no idea whether they are authentic or not — the authentication data just isn’t there.

If only half of service providers actually publish data to authenticate their routing updates, and only a quarter of the networks that consume routing messages actually validate any authentication at all, and those parties do not agree on how to authenticate or how to sign their messages — that is where things get messy.

And that is basically what this paper shows: RPKI is not mature. People do not agree on how to authenticate their messages, and people do not agree on how to validate whether those messages are authentic. It is a bit of a mess.
