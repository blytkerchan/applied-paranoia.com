---
author: rlc
comments: true
date: 2022-09-30
layout: post
title: Should you encrypt everything?
---
Encryption is the mechanism by which normal data, like this text, is made to look like random gibberish -- arguably also like his text. The basic idea of encryption has been around ever since the first secret was confidentially told to someone in earshot of someone else: when the first "Alice" had a message for the first "Bob" that she didn't want the first "Eve" to understand, even if she could overhear it.

One of the most famous encryption mechanisms in history is the German Enygma machine, used by the Nazis during the Second World War to encrypt messages between different parts of the German army, and eventually cracked by the British under the leadership and guidance of Alan Turing, one of the fathers of modern computing. Since those days which, while less than a century ago and still part of living memory today, are ancient history for the annals of computing, encryption has made great strides with the development of various "block" and "stream" ciphers (i.e. encryption algorithms), and various "modes" which each have their advantages and drawbacks. All of these algorithms essentially do the same thing, though: using some mathematical trickery, they obfuscate the true meaning, and sometimes the true size, of a message or some data at rest, providing confidentiality to those who have the key to unlock that true meaning, against those who don't.

But when is it worth doing that?

