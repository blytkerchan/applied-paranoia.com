---
author: rlc
date: 2021-09-09
layout: post
title: Transient execution of non-canonical accesses -- too paranoid?
---
In their pre-print paper ["Transient execution of non-cacnonical accesses"](https://arxiv.org/pdf/2108.10771.pdf), researches Saidgani Musaev and Christof Fetzer demonstrate a flaw in AMD CPUs that have the potential of leaking data through a side-channel similar to the Meltdown and Spectre vulnerabilities found in Intel CPUs. While their work is certainly interesting, and I have no reason to doubt what they found, they've pushed the paranoia a bit further than I think is necessary in this case.

<!--more-->

The paper makes a few excellent points, among which the fact that if you don't look for vulnerabilities in a category of CPUs, you won't find them there. As they put it, "(...) most research was focused on Intel CPUs, with few exceptions. As a result, few vulnerabilities have been found in other CPUs (...)". In other words, you won't find flaws where you don't look for them.

They go into some depth explaining the origins of the types of flaws their looking for: speculative and out-of-order execution used by modern CPUs to optimize execution of user code (basically by keeping the CPU busy and not having it wait needlessly for the results of previous operations) can lead to the CPU accessing memory it's not supposed to access. As the CPU is responsible for process isolation and memory protection, this essentially breaks one of the basic promises the CPU makes, cutting corners for expediency. This is well-known, and generally not considered a bad thing *per s&eacute;*, but breaking your most basic promises comes at a price.

These optimizations rely on things that should not become "architecturally visible" (i.e. are not visible to the software if the software does not rely on bugs) will not become visible to the running software. Attacks on these optimizations become possible when things that are not *architecturally* visible become visible through side-channels and data races. I.e., the CPU relies on the software to only rely on well-defined behavior and not have any bugs, intentional or otherwise. The attacks are intentional bugs that exploit undefined behavior by causing the CPU to fault, and exploiting visible side-effects of that fault.

The flaw found by the researchers exploits a fault the CPU encounters when the software attemps to access memory that it is not allowed to access. Apparently, the CPU only validates the 48 least significant bits of a 64-bit address when performing speculative loads, and does its complete check (according to the researcher's hypothesis) only when the instruction leaves the pipeline in program order. At that point, a fault will occur, but the load will nonetheless have taken place.

For this flaw to occur, the CPU has to validate part of the address using the CPU's Translation Lookaside Buffer. That buffer is a per-process buffer that does not survive a context switch from one process to another. Because of this, the flaw is restricted to leaking memory between threads within the same process.

This is why I think there's a wee bit too much paranoia here.

In general, threads in the same process have complete access to eachother's memory: there is no isolation of threads in the same way as there is isolation of processes. Being able to "trick" a thread into giving up some of its secrets by matching the 48 least significant bits of the address of the secret you want to obtain is only a security issue if the process was essentially trying to keep a secret from itself. If you're paranoid enough to want to keep secrets from yourself, wouldn't you *at least* put those secrets in a different process?

The AMD security team, I think, were generous with their assigning "medium" severity to CVE-2020-12965. Using CVSS v3.1, I got a score of 2.9 (low) with vector CVSS:3.1/AV:L/AC:H/PR:N/UI:N/S:U/C:L/I:N/A:N/E:P/RL:U/RC:C.

This does not take anything away from the research Musaev and Fetzer did: they've found a genuine flaw in AMD processors that could conceivably be used to augment a side-channel attack, they disclosed it responsibly to AMD and their research seems sound. However, I don't think anyone at AMD will lose any sleep over this bug.
