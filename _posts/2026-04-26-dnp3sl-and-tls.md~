---
title: 'DNP3 and TLS'
author: 'rlc'
date: 2026-04-26
---

When I joined the DNP Technical Committee in 2013, the latest version of the DNP3 standard, IEEE 1815, was less than a year old. That version of the standard contained what was then the only viable option for securing SCADA communications over serial connections. As such, DNP3-SAv5 was ahead of its time, despite its warts.

It didn't take long for the committee to recognise some of the issues DNP3-SAv5 suffered from: by the time Sergey Bratus and Adam Crain published their case study of DNP3-SAv5, ["Bolt-On Security Extensions for Industrial Control System Protocols"](https://www.cs.dartmouth.edu/~sergey/langsec/papers/crain-bratus-bolt-on-dnp3sa.pdf), the DNP TC had already stood up the Secure Authentication Task Force (SATF; now Cybersecurity Task Force, CSTF) to study what we then thought would be SAv6.

The CSTF's mandate was to design the replacement for SAv5, invite industry, protocol, and cybersecurity experts to the table, and create a secure protocol for DNP3's unique use case. Within the DNP-UG, the CSTF is unique in that it does not require DNP-UG membership to participate in the discussion: we are intentionally open to a wider audience and have had members from every corner of the industry, including security researchers, join to help ensure the protocol's security. Our discussions immediately turned to moving SA to its own layer and addressing some of the design issues in SAv5, making it "as simple as possible, but no simpler".

In the decade that followed, we have done just that: we have removed complexity from both the Application Layer and from the security protocol itself, removed the need — or even the possibility — of pre-shared secrets, and introduced post-quantum cryptography into what has become a versatile protocol layer, DNP3-SL. This layer establishes an Association with mutual authentication using post-quantum asymmetric cryptography and, within that Association, can establish any number of subsequent Sessions using only symmetric cryptography. This design intentionally targets brownfield use cases with resource-constrained devices while still providing post-quantum security.

During that same time, the CSTF has also been developing a new protocol called the Authorization Management Protocol (AMP). This protocol addresses another niche that, while not unique to brownfield SCADA networks, is most prevalent there: the management of authorisation and security policies in a hierarchical network where individual devices do not have direct access to Policy Decision Points or to Certificate Authorities.

> **Question:** "Authorization" is spelled in the American style in "Authorization Management Protocol (AMP)" — is this the official name of the protocol as standardised, and should it therefore be kept as-is rather than changed to the Canadian "Authorisation"?

As with any large-scale development process, this one has taken far longer than we would have liked. We have run over the time we had allocated to the project by several years, due in part to our rigorous review process and in part to the fact that this is largely a volunteer endeavour. At every step of the way, we have answered questions, taken comments, invited participation, and endeavoured to improve the protocol. The latest input we received, admittedly through a side channel, was again [from Adam Crain](https://stepfunc.io/blog/case-against-dnp3-sav6/). This time, he argued that SAv6 was no longer necessary, and that he wouldn't implement it.

Not implementing a layer of the DNP3 protocol is, of course, his prerogative. Some of the arguments leading him to that decision are based on faulty or outdated data, and some on his particular use case. For some use cases, you might be better off with TLS or IPsec: greenfield implementations of DNP3 that use only IP connections and don't care about application-to-application authentication or centrally managed RBAC and security policies are well-served with transport layer-only security. The extra complexity needed to implement the security deeper down (or further up) the stack may not be worth it if the risk of compromise doesn't warrant it.

> **Suggestion:** "green field" has been changed to "greenfield" (one word) to match the one-word "brownfield" used elsewhere in the post. Please revert if you have a preference.

DNP3-SL addresses application-to-application security that can be authorised by a central authority and authenticated using either self-signed or PKI-based certificates. It works over serial and IP connections and could be carried over TLS or IPsec. The difference between those protocols and DNP3-SL, however, lies in the design decisions we've made throughout the process. For example, the cryptographic primitives used target hardware acceleration available in many embedded processors, but are used sparingly to accommodate brownfield implementations. Similarly, Associations are long-lived, reducing the need to use asymmetric cryptography.

Many SCADA networks still use serial communications somewhere in the network. That cannot be changed with a simple firmware update. The version of DNP3 used by a device, and whether it's configured to use DNP3-SAv5 or DNP3-SL, can.

It is true that there are no current commercial implementations of DNP3-SL. It may also be true that some DNP3 implementations will never support it. It is, however, very likely to be implemented by at least some popular DNP3 stack vendors and by forward-looking members of the industry.

DNP3-SL is the product of more than a decade of careful, open, and collaborative work by a group of professionals who care deeply about the security of critical infrastructure. It is not a perfect protocol, and it may not be the right choice for every deployment. But for many of the brownfield SCADA networks that make up the backbone of the world's critical infrastructure, it will be the most carefully considered option available. We invite you to review the standard, participate in the CSTF, and help us make it better.
