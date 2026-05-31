---
title: 'Late publication: Performing a mutually authenticated key exchange with perfect forward secrecy using a KEM'
author: 'rlc'
date: 2026-05-26
layout: post
---
In June 2024, I wrote a paper entitled "Performing a mutually authenticated key exchange with perfect forward secrecy using a KEM" that I have never gotten around to publishing. I should note it has not been reviewed yet, and I'd be interested in any constructive feedback (you can get in touch on LinkedIn or Blue Sky -- though I may be slow to respond, I've been rather busy).

**Abstract**:
> The advent of quantum computing lends urgency to the development of secure protocols that can be built entirely with post-quantum algorithms. This excludes the use of the family of algorithms Diffie-Hellman and Elliptic Curve Diffie Hellman belong to, as there are no algorithms in that family that are likely to be selected in the NIST program for post-quantum cryptography, and previous candidates have been eliminated due to security issues. This paper presents a new protocol for a secure mutually authenticated key exchange with perfect forward secrecy, based on the use of KEM algorithms.

[Read it here](/assets/2026/kem-make.pdf).

**Note**:
> The introduction is a little out of date: ML-KEM is now the standard that CRYSTALS-Kyber was expected to become when I wrote the paper. Other than that, I believe the paper is correct.
> The reasons I didn't publish it two years ago are twofold: 
> 1. I intended to write a section on why the schemes in the original Kyber paper don't provide perfect forward secrecy (it's because they're missing the two ephemenral keys and two nonces), and 
> 2. The paper had completely slipped my mind due to personal circumstances.
> 
> I should also note that, as an alternative to using an AEAD for the c_m value in the third message, an HMAC over the handshake can also be used.
