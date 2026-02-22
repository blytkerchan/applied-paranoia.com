---
author: rlc
comments: true
date: 2026-02-15
layout: post
title: Why Post-Quantum Cryptography is important
---
Last Friday someone asked me to explain why post-quantum cryptography is important. Here’s my answer, cleaned up a bit.

**Note:** this is a transcript of a voice recording, edited to become a blog post.

## The short version: asymmetric cryptography is in trouble

Symmetric cryptography is mostly safe. Asymmetric cryptography is not and the reason comes down to trapdoor functions.

A trapdoor function is one that’s easy to compute in one direction but hard to reverse. The classic human analogy is multiplication versus division: multiplying a number by ten is trivial (just append a zero), while dividing is slightly more work for your brain. Scale that up to enormous numbers and throw in operations like factorization, and you have a very solid trapdoor for classical computers.

For quantum computers, that trapdoor is no obstacle at all. Algorithms like Shor’s can factor large numbers exponentially faster than any classical machine, which means the mathematical foundations of RSA, ECDSA, and ECDH are fundamentally vulnerable.

## We don’t have quantum computers big enough — yet

To be clear, no quantum computer today is large enough to break these algorithms in practice. But we expect that to change around 2040 or so. That might sound far away, but the timeline for replacing cryptographic infrastructure is long, which is exactly why we need to start now.

There’s also the "harvest now, decrypt later" threat: an adversary can record encrypted traffic today and decrypt it once a sufficiently powerful quantum computer exists. For long-lived secrets, that’s already a serious concern.

## The NIST competition

The National Institute of Standards and Technology (NIST) ran a years-long competition inviting mathematicians and cryptographers to propose new algorithms that are hard for *both* quantum and classical computers to break. The winners were **CRYSTALS-Dilithium** (for digital signatures) and **CRYSTALS-Kyber** (for key encapsulation), both based on lattice mathematics.

Lattice-based cryptography relies on problems in high-dimensional geometric structures that quickly become intractable. The details are complex, but the key point is that these problems appear to be hard for quantum computers just as they are for classical ones.

## What’s new, and what’s missing

The post-quantum toolkit gives us two main building blocks:

- **Digital signature algorithms** — analogous to ECDSA and RSA signatures.
- **Key encapsulation mechanisms (KEMs)** — analogous to RSA-based key exchange. In a KEM, you don’t choose the shared secret yourself; the encapsulation function generates both the key and an encapsulated version of it, which the other party decapsulates using their private key.

What we *don’t* have is a post-quantum equivalent of Diffie-Hellman. There was a candidate — SIDH — but it was broken by a classical computer, so it’s off the table. This means some protocols will need to be restructured to use KEM-based approaches instead of traditional key exchange.

## The timeline

The pressure to move is real and near-term:

- **By 2027**, certificates based on classical algorithms will begin expiring on a 47-day cycle (roughly every six weeks) rather than annually. That demands significant automation investment.
- **By 2030**, all new critical infrastructure projects should be using post-quantum cryptography.

## The case for hybrid approaches

Because post-quantum algorithms are new, they haven’t yet accumulated the decades of cryptanalysis that classical algorithms have. Some vulnerabilities may still be undiscovered. For that reason, many practitioners, myself included, advocate for **hybrid key schemes** that combine a classical algorithm and a post-quantum algorithm requiring both to agree before a secret is established or a signature accepted.

This approach makes sense for roughly the next five years. It means you’re not betting everything on post-quantum cryptography being completely sound while classical cryptography is still holding up.

The catch is that once a quantum computer powerful enough to break classical algorithms actually exists, hybrid schemes no longer help you — the classical component is compromised regardless. At that point, you need to be fully on post-quantum cryptography already. Which is yet another reason not to wait.

Also, if your secrets need to still be secret fifteen years from now, you should be using post-quantum crypto already.