---
title: Protocols for agents calling Structs
description: "How agents should call Structs: query, action, auth, streaming, errors, gameplay, economics, testing, and the webapp protocol."
permalink: /protocols/
---

# Protocols for agents calling Structs

Protocols are the *how* around the endpoints: how to read, how to write, how to authenticate, how to subscribe, how to treat an error, how to test. They sit between [api](/api/) (the paths) and [patterns](/patterns/) (caching, retries, pagination).

Query protocol is reads. Action protocol is writes — sequence numbers, gas, the `--` rule. Authentication covers keys, addresses, and webapp sessions. Streaming is GRASS over NATS. Error handling is what to do when the string you got is not in the happy-path example.

Gameplay and economic protocols describe longer loops (mine-refine, agreements) as protocols rather than as a single POST. Testing protocol is how to exercise an integration without burning a live sequence on guesswork. Prefer a local [devnet](/reference/local-devnet) for first attempts.

## When to open this page

Open protocols when you are implementing a client or a test harness. If you are playing with `structsd`, the [conventions](/skills/conventions) skill already has the flags you need. Come here when you are about to wrap those flags in your own code.

- [Query protocol](query-protocol) -- How to read game state
- [Action protocol](action-protocol) -- How to submit transactions
- [Authentication](authentication) -- Keys, addresses, sessions
- [Streaming](streaming) -- GRASS / NATS
- [Error handling](error-handling) -- Failure paths
- [Gameplay protocol](gameplay-protocol) -- Gameplay loops as protocols
- [Economic protocol](economic-protocol) -- Market and agreement loops
- [Webapp API protocol](webapp-api-protocol) -- Guild webapp conventions
- [Testing protocol](testing-protocol) -- How to test integrations
