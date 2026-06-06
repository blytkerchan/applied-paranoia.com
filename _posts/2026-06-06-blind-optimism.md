---
title: Unbridled optimism and friendly handshakes over beer govern the Internet
author: rlc
date: 2026-06-06
---

A paper in the latest issue of Communications of the ACM took me down a rabbit hole, and I'd like you to come with me.

The paper, "Are We Actually There? Assessing RPKI Maturity" by Schulmann et al., is an incisive and comprehensive review of the maturity of RPKI and its application to global internet routing.

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

Now, I am not typically a big fan of the current American administration, but they did get something right. They are trying to force the larger internet service providers to secure the backbone and at least reduce the possibility of BGP hijacks.

Here is what I mean by that. Back in 2021, Facebook had a BGP routing failure that removed the routes for its authoritative DNS servers. As far as I can recall, that was a mistake — a misconfiguration. The only intentional BGP hijack I am aware of is when Rostelecom, in April 2020, misoriginated routes that diverted traffic intended for Google, Facebook, AWS, and Cloudflare through Russia. I don't know exactly what they did with that traffic, but, well, you know: Russian.

The FCC has published a notice of proposed rulemaking that requires major providers like AT&T, Comcast, Lumen, and T-Mobile to file their BGP security plans, covering how they intend to implement RPKI and handle all of that, and to update those filings on a regular basis. Those filings will be confidential, but like anything filed with the government, they will be subject to access to information requests.

> **Question:** You mention "access to information requests" — in the US context, this would typically be called Freedom of Information Act (FOIA) requests. Did you want to use the US-specific terminology here, or keep the more generic phrasing?

Smaller providers — essentially the kind that serve residential customers like me — do not have to file those reports, but they must still have their plans. Providers that can formally attest that they have registered and maintained active ROAs covering at least 90% of originated routes for IP prefixes under their control can be exempt from filing those reports.

That creates an incentive to avoid paperwork and simply create those ROAs, which can be automated. Automating the underlying problem rather than automating the reporting is generally the better long-term approach, and appears to be the outcome they’re aiming for.

The incentive is right: if you can attest that 90% of your routes have ROAs, you don't have to file. You don't open up a potential leak of your vulnerable paths, and you don't create a centralised repository maintained by the government — accessible through access to information requests — that essentially tells anyone who looks exactly where the vulnerabilities in the backbone are and which addresses can be hijacked.

> **Suggestion:** Consider clarifying the concern about the government-maintained list more explicitly, since you move quickly from the incentive to the privacy/security concern. A brief transitional sentence might help readers follow the shift.

That part I think is probably not great — the US government wanting to maintain a list like that, especially when it is not mandated by Congress and is not shielded from access to information requests or kept as an actual secret. But at least they are going in the right direction.

The other thing that came to mind when reading this is the question of who controls the internet. We don't necessarily want the American government, or any American entity — including the big five or whatever large American businesses you care to name — to have sole control over the internet backbone. So my mind went to what an authenticated but distributed system might look like, one where participants trust each other and sign off on their own data — a web of trust, basically.

When I thought about that for a while, I went to PGP's web of trust model, where participants sign each other's public keys and use their own private keys to sign messages. So, for example, Google, AWS, Microsoft, AT&T, SkyNet, and so on would sign off for each other and say, essentially, “Yes, we trust each other — at least enough to not poison the network.” Rather than the hierarchical approach that a traditional PKI would have, you'd just have them sign each other's routing announcements that way.

That's one way of saying: we trust each other, we can vouch for what the other party said. And therefore you as a consumer can say, “Well, I trust Google, Amazon, Microsoft, AT&T, Comcast, my own ISP — and they in turn trust others, so I’ll trust them as well” with the usual web of trust mathematics: if I trust you at 100% and you trust Joe, I'll trust Joe at 80%, and if Joe trusts Alice, I'll trust Alice at 80% of 80%, which is 64%, and so on. At some point, if the trust score drops below, say, 50%, you start being sceptical. If I have a route from someone I trust at 80% and another from someone I trust at 40%, I'll take the one with 80%, even if it's an extra hop, because at least it doesn't go through a path I don't actually trust.

The other piece, though, is how you look up that data. HTTP and rsync, the two transport mechanisms specified in the RFCs so far, aren't necessarily all that well suited to a distributed trust model. What you really want is a distributed ledger, which is where a blockchain comes in, because that is exactly what a blockchain is. If any one access point goes down, you still have a dozen or so other access points that can serve the same data. That data is built on consensus and can contain the trust information as well.

As it turns out, there is a patent from Huawei that identifies exactly this idea: using a distributed ledger — a blockchain — as a decentralised peer-to-peer network of cryptographically immutable historical records that are signed, hashed, and so on. It doesn't include the web-of-trust idea, but at least it has the concept of accessing the ledger from a distributed network.

Now, I don't have a commercial interest in any of this, so I'm not going to file a patent on the web-of-trust idea. But now you can't either. You're welcome.

But yes — the core idea is that rather than relying on a traditional PKI, you'd have the signatures governed by something that is not centralised. The way to do that would be to have a distributed network of signatories. You can still use PKI to tie things to an identity — for example, you could still have a trusted root certificate that establishes that you are SkyNet, and others trust you to a certain degree not to poison the network. So they will sign off on your ability to update routing information in their routers, and the same goes for Google, AT&T, and so on.

But not necessarily for parties that others don't trust — the Russian providers, for example, may not be trust AT&T and other US ISPs to the same degree those parties trust each other.

This also gives the consumer side the ability to determine who gets to populate their routing tables, which may well be a national security concern for them. An X.509 certificate can attest that you have an authentic identity; it doesn't necessarily say that you should be trusted to sign off on routing announcements. So it's not just authentication — it's trust as well, and that trust is better built into a peer-to-peer network in the style of PGP's web of trust than into a centralised PKI hierarchy, in my opinion.
