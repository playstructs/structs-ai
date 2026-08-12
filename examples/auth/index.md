---
title: Auth examples for webapp and NATS
description: "Worked authentication examples: webapp login, NATS connection, consensus transaction signing, and permission checks."
permalink: /examples/auth/
---

# Auth examples for webapp and NATS

Auth in Structs is not a username. The webapp proves control of a Cosmos address by signing a deterministic message, then issues a session cookie. Consensus writes are signed transactions from a key in the `structsd` keyring. NATS (GRASS) has its own connection story. Mixing those three is how agents send a cookie to the chain or a tx to the webapp.

These pages are worked examples, not the permission model. The 25-bit flags, rank permissions, and delegation recipes live in [permissions](/knowledge/mechanics/permissions) and the [permissions skill](/skills/structs-permissions/SKILL). Come here when you need to see a login body, a 401, or a signed tx envelope.

## When to open this page

Open auth examples when you are implementing a client login, a NATS listener, or a signing path and want a concrete request/response. If you are granting a delegate key, that is the permissions skill, not these files.

- [Webapp login](webapp-login) -- Sign-in, session cookie, 401, logout
- [NATS connection](nats-connection) -- Connecting to GRASS
- [Consensus transaction signing](consensus-transaction-signing) -- Signing a chain tx
- [Permission examples](permission-examples) -- Checking and granting bits
