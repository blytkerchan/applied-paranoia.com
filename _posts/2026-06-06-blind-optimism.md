---
title: Unbridled optimism and friendly handshakes over beer govern the Internet
author: rlc
date: 2026-06-06
layout: post
---

A paper in the latest issue of Communications of the ACM took me down a rabbit hole, and I'd like you to come with me.

The paper, ["Are We Actually There? Assessing RPKI Maturity" by Schulmann et al.](https://dl.acm.org/doi/pdf/10.1145/3769687), is an incisive and comprehensive review of the maturity of RPKI and its application to global internet routing.

Like most users of the internet, I have largely ignored — and frankly been ignorant of — BGP, the Border Gateway Protocol, which is used to interconnect the thousands of networks that compose the internet. It's a protocol I typically don't think much about, but of course I use it on a daily basis, because I use Google, email, and so on, and so do you.

Anyway, BGP's lack of robust security and its vulnerability to both innocent typos and malicious attacks does not surprise me, but it also has not concerned me as much as it probably could or should.

The internet backbone is not secure. Back in the late 1980s when the Border Gateway Protocol was created, everything was based on optimism, a friendly smile, and a handshake — something worked out on the back of a napkin over a few beers. And honestly, some of the nicer networking protocols came about exactly like that: discussed over dinner and beers. One of the protocols I actually do think about a lot was born that way as well.

Anyway, back in 2012, RPKI was standardised as a suite of RFCs. The SIDR working group published the core specifications in a batch: RFC 6480 as the architectural overview, followed by a cluster of RFCs covering repository structure (6481), the ROA profile (6482), route origination validation (6483), certificate policy (6484), algorithm requirements (6485), manifests (6486), the X.509 resource certificate profile (6487), the signed object template (6488), and several more covering key rollover, trust anchor locators, and provisioning. The RPKI-to-Router protocol — which defines how a Relying Party validator feeds validated data to BGP routers — followed about a year later as RFC 6810.

RFC 7115 came out in 2014 and laid out the best current practice for deploying origin validation, including the fail-open posture that most networks still use today. Then in 2017, RFC 8182 introduced RRDP, which is an HTTP-based alternative to rsync for pulling down repository data. That same year, RFCs 8205 through 8209 defined BGPsec, which goes beyond just validating where a route originated and actually cryptographically authenticates the whole AS path. RFC 8210 also came out in 2017 as an update to the RTR protocol.

Standard tooling was added in 2018: RFC 8416 introduced SLURM, which lets operators locally override RPKI validity decisions when they need to work around known misconfigurations or complex multi-homing configurations.

So RPKI has been actively developed since 2012 — over a decade now, almost a decade and a half. And yet it is not that widely adopted. As the ACM paper makes clear, even after more than a decade, it is not necessarily all that mature.

Here is what I mean by that, and what I think the authors of the paper mean by it. When you try to find a route to some other IP address, the best route — the shortest route — is through a gateway that has the most specific announcement for that destination. Routers announce which address prefixes they have access to, and a more specific prefix (more bits) wins out over a less specific one. Fewer hops is better, and a more specific prefix gives you a better path.

So your routing table tells you what your best path is, but the contents of that routing table can basically come from anywhere.

To secure that, the messages that fill up your routing table should be authenticated. Authentication is the cornerstone of everything in security. The question is: how do you authenticate those messages, how do you sign them, and what do you do when you have no authenticated messages to work with? The RFCs try to answer that, but as Schulmann et al. show, interpretations of what they mean differ between implementers, and the software that implements them is buggy and vulnerable.

The core issue is how that authentication works, and whether everyone agrees on how it works. If they do not agree, some messages may be dropped that should not be, because they are actually authentic. Some messages may be accepted that should not be, because they are actually not authentic. And some messages will simply be accepted because you have no idea whether they are authentic or not — the authentication data just isn't there.

If only half of service providers actually publish data to authenticate their routing updates, and only a quarter of the networks that consume routing messages actually validate any authentication at all, and those parties do not agree on how to authenticate or how to sign their messages — that is where things get messy.

And that is basically what this paper shows: RPKI is not mature. People do not agree on how to authenticate their messages, and people do not agree on how to validate whether those messages are authentic. It is a bit of a mess.

Now, I am not typically a big fan of any American administration, but the previous one did [get something right](https://bidenwhitehouse.archives.gov/wp-content/uploads/2024/09/Roadmap-to-Enhancing-Internet-Routing-Security.pdf). They [are trying to force](https://docs.fcc.gov/public/attachments/DOC-402609A1.pdf) the larger internet service providers to secure the backbone and at least reduce the possibility of BGP hijacks (and, as far as I can tell, the current administration has not rolled this back).

Here is what I mean by that. Back in 2021, [Facebook had a BGP routing SNAFU](https://en.wikipedia.org/wiki/2021_Facebook_outage) that removed the routes for its authoritative DNS servers. That was a mistake — a misconfiguration. The only intentional BGP hijack I am aware of is when [Rostelecom, in April 2020, misoriginated routes](https://www.thousandeyes.com/blog/rostelecom-route-hijack-highlights-bgp-security) that diverted traffic intended for Google, Facebook, AWS, and Cloudflare through Russia. I don't know exactly what they did with that traffic, but, well, you know: Russian.

The FCC has published a [notice of proposed rulemaking](https://docs.fcc.gov/public/attachments/DOC-402609A1.pdf) that requires major providers like AT&T, Comcast, Lumen, and T-Mobile to file their BGP security plans, covering how they intend to implement RPKI and handle all of that, and to update those filings on a regular basis. Those filings will be confidential, but like anything filed with the government, they will be subject to access to information requests.

Smaller providers — essentially the kind that serve residential customers like me — do not have to file those reports, but they must still have their plans. Providers that can formally attest that they have registered and maintained active ROAs covering at least 90% of originated routes for IP prefixes under their control can be exempt from filing those reports.

That creates an incentive to avoid paperwork and simply create those ROAs, which can be automated. Automating the underlying problem rather than automating the reporting is generally the better long-term approach, and appears to be the outcome they’re aiming for.

The incentive is right: if you can attest that 90% of your routes have ROAs, you don't have to file.

You also don't open up a potential leak of your vulnerable paths, and you don't create a centralised repository maintained by the government — accessible through access to information requests — that essentially tells anyone who looks exactly where the vulnerabilities in the backbone are and which addresses can be hijacked. 

The US government wanting to maintain a list like that, especially when it is not mandated by Congress and is not shielded from access to information requests or kept as an actual secret, is a real concern. The government is not good at keeping secrets.

The other thing that came to mind when reading this is the question of who controls the internet. There are six Regional Internet Registries that can assign numbers to Autonomous Systems which, loosely speaking, consist of network operators who route each other’s data.

The shortest path isn’t necessarily the best path though: you don't necessarily want the Elbonian government, or any Elbonian entity — including whatever large Elbonian businesses you care to name — to have any control over the part of the internet backbone your data flows through.

So my mind went to what an authenticated but distributed system might look like, one where participants trust each other and sign off on their own data — a web of trust, basically. The route your data takes through the internet is mostly invisible to you, and you can’t choose the ASes your data will flow through, but what if you could?

When I thought about that for a while, I went to PGP's web of trust model, where participants sign each other's public keys and use their own private keys to sign messages. So, for example, AS1, AS2, AS3, and so on would sign off for each other and say, essentially, “Yes, we trust each other — at least enough to not poison the network.” Rather than routing data through ASes blindly, you’d only route through ASes you trust to not “harvest now and decrypt later”, for example.

That's one way of saying: we trust each other, we can vouch for what the other party said. And therefore you as a consumer can say, “Well, I trust my own ISP and yea set of networks — and they in turn trust others, so I’ll trust them as well” with the usual web of trust mathematics: if I trust you at 100% and you trust Joe, I'll trust Joe at 80%, and if Joe trusts Alice, I'll trust Alice at 80% of 80%, which is 64%, and so on. At some point, if the trust score drops below, say, 50%, you start being sceptical. If I have a route through someone I trust at 80% and another through someone I trust at 40%, I'll take the one with 80%, even if it's an extra hop, because at least it doesn't go through a path I don't actually trust. This would require a level of transparency in routing we don’t currently have, but it’s a level of transparency [SCION](https://arxiv.org/pdf/1508.01651) provides to Swiss banks.

The other piece, though, is how you look up that data. HTTP and rsync, the two transport mechanisms specified in the RFCs so far, aren't necessarily all that well suited to a distributed trust model. What you really want is a distributed ledger, which is where a blockchain comes in, because that is exactly what a blockchain is. If any one access point goes down, you still have a dozen or so other access points that can serve the same data. That data is built on consensus and can contain the trust information as well.

As it turns out, there is a patent from Huawei that identifies exactly this idea: using a distributed ledger — a blockchain — as a decentralised peer-to-peer network of cryptographically immutable historical records that are signed, hashed, and so on. 

Now, I don't have a commercial interest in any of this, so I'm not going to file a patent on the web-of-trust idea. You're welcome. 😉