---
layout: post
date: 2026-06-07
---

In a recent discussion with one of my colleagues on the cyber security task force (CSTF) for the DNP Users Group, I asserted that digital signature schemes and PKI in particular cannot work without static keys. You cannot use ephemeral keys for digital signature schemes and public key infrastructures. In this post I’d like to explain the reasoning behind that assertion.

> **Question:** You mention "service security task force for the DNP Users Group" — should this be "DNP3 Users Group" or another specific group name? Please confirm the correct name so it can be rendered accurately.

Let's do a proof by contradiction. What would a digital signature scheme or a public key infrastructure look like without static keys? What would it look like with only ephemeral keys? As it turns out, we don't have anything that's even close to being able to do that. So let's look at what ephemeral keys would mean in this context.

An ephemeral key, in the worst case, would be a single-use key for signing something. Basically, I have a document that certifies my identity, and I can only sign with the associated private key once. If I sign a second time with the same key, my private key becomes compromised. If an adversary were to see two signatures produced with the same private key, they would be able to deduce the private key and generate any number of signatures that look like they've been produced with my private key. They would therefore be able to spoof me, and I would no longer be able to repudiate the signatures produced by that malicious adversary.

That is the essential issue. Signatures provide non-repudiation of the authenticity of whatever is signed. So if I sign something with my private key, whoever validates that signature has to be sure, or at least trust, that the signature can only be validated using the public key associated with my private key and that I’m keeping my private key private.

This is why signatures with symmetric keys don't work for non-repudiation. If I share my symmetric key with someone and then use that symmetric key to sign a message, the recipient, having that same symmetric key, can validate my signature, but can also produce a signature using that same key. The more people share that symmetric key, the more people are able to generate signatures that look like they've been signed by whoever originated that key, or whatever identity that key is associated with.

Now, sometimes that's just fine: it just means that you're a member of that group. As long as that group keeps the symmetric key secret, it's a shared secret within the group, and only members of the group can sign, encrypt, decrypt, or validate signatures using it. That's all fine. But as soon as that key is leaked outside of that group, you've essentially enlarged the group to include whoever now has that symmetric key.

It's a shared secret, and that shared secret, if used for signatures, can be used by anyone who possesses it.

That shows you the strength of asymmetric cryptography: you have two keys, one private and one public. The public key can be used to validate a signature produced by the private key, but only the holder of the private key can actually sign with it.

> **Question:** The original draft says "inhibited it" near the end of this section, which appears to be a transcription error. Based on context, "forged it" was used here — please confirm this is the intended meaning, or provide the correct word.

So in a shared-secret network — a group of people who share a secret — you cannot implement non-repudiation on a signature. You need something else to demonstrate that the signer is actually who you believe them to be, because anyone within the group could have signed the message, or could have forged it.

You can still demonstrate authenticity in the sense that a message is authentic within the network of people who share that symmetric secret. But with a private key, you can actually pin it to the one person who is supposed to hold that key, whose identity is tied to it, and who is supposed to keep it secret.

Now, if you have an ephemeral key with the restriction we discussed above, and you use that same private key twice for signing, an adversary who obtains both of those signatures can deduce the private key from them. At that point, non-repudiation is gone, and authentication is essentially gone as well.

So that's the core issue. A public key infrastructure is based on the idea that a certificate authority (CA) signs a number of certificates. Each certificate identifies the holder of a given private key: the public key embedded in the certificate is associated with an identity. An identity certificate contains the public key and essentially states that whosoever can generate a signature that can be validated with the public key in this certificate is certified by the CA to have the identity embedded in that certificate.

That identity certificate is signed by the CA, which has its own certificate. That CA certificate states that whosoever can generate a signature that can be validated with the public key embedded in it is that certificate authority. The CA certificate, which is tied to the identity of the CA, can itself be signed by a higher-level CA, all the way up to a root certificate. The root certificate states that whosoever can produce a signature that can be validated with its public key is the holder of the root certificate — the entity that holds the associated private key.

A scheme like that only works if the root certificate can be used to sign more than one intermediate CA certificate, which can then be used to sign more than one identity certificate. If we had a single chain with just a root certificate, a single intermediate CA certificate, and a single identity certificate, that would be a very odd and wasteful approach. It would mean you'd need a separate root certificate for every individual identity certificate in existence.

That is not how anything works. It would mean you'd have to preload every root CA certificate into your firmware, your OS, and so on — which is already the case, actually. Those trusted root certificates are preloaded into your phones, your computers, your firmware, your smartwatches, your everything. They all have a set of those installed. But if you had a single root CA certificate per certificate generated, and knowing that thousands of certificates are generated every day — one for basically every website, every API, every service, and so on — that would be completely unmanageable. The sheer number of root CA certificates you'd have to generate would be enormous.

You would also have to securely distribute them to every device in the world. Which is where the next problem comes in: if you want to create a connection to a server, you will typically create a connection using TLS. One of the things that happens in a TLS handshake is that the server signs a message. That message says: "This message is from me. Here's my certificate to show you who I am, and you know this message is from me because I signed it with the private key associated with this certificate. You can validate that by verifying my signature using the public key in my certificate, and that certificate is signed by the CA."

So every single connection, every single handshake, starts with a signature. If we had ephemeral keys only — if we only had keys that could be used once per connection — that would mean every connection would require a new private key for that signature. Obviously, that is untenable. You're creating new connections to servers every time you connect to any service: when you check your email, when you go to a website, when you read my blog. Every time any of that happens, the server is creating a signature using the private key associated with its certificate, which is itself signed by a CA.

So it's not just that you'd need a separate root certificate per certificate — you'd be creating new keys for every single connection. It's quite untenable, I think that's obvious at this point.

Now, there are ephemeral keys in these types of connections. There are keys created just for that connection, and those are typically the keys used to derive the symmetric key you share with the server. That symmetric key is then used to encrypt and authenticate everything between you and the server. It is an ephemeral session key that lasts only as long as the session. The ephemeral key used to generate it is pure random data, created only for that session, and can be discarded at the end. But the message containing the public key for that ephemeral key is signed using the private key associated with your certificate — and that has to be a static private key.

So there may be ephemeral keys. There may be symmetric keys. There may be lots of cryptographic data that gets discarded at the end of the session, and that is all fine. But all of that is tied back to the identity of the server by being linked to a signature produced with a static private key, for which there is a corresponding public key in a certificate signed by the CA. That is why that key has to be a static key.

Now, that static key may not live longer than a year, because the certificate will be replaced within roughly that timeframe. That's fine. The CA certificate may have a somewhat longer lifespan, and the root CA certificate is typically valid for about a decade to a decade and a half. That's all fine. But within that year, that private key may be used thousands of times. That is what makes it a static key.