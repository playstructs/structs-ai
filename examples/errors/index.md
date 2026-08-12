---
title: Error response examples for agents
description: "Worked HTTP error shapes for Structs agents: 404 not found, 429 rate limit, and 500 server error, with what to do next."
permalink: /examples/errors/
---

# Error response examples for agents

Happy-path examples lie by omission. These pages show the bodies you actually get when the entity is missing, when you have been throttled, and when the server failed. Parse the status code first; then the payload. A 404 is not a 500 with extra steps, and retrying a 404 will not create the planet.

Rate limits are expected under load. Back off, do not tight-loop, and read [rate limits](/api/rate-limits) plus the [rate-limiting pattern](/patterns/rate-limiting) before you wrap a client. Server errors are retryable with jitter; missing entities are not.

The canonical error catalog is [api/error-codes](/api/error-codes). These files are the shapes. [play/errors](/play/errors) maps the strings you will see in `structsd` to the skill that fixes them.

## When to open this page

Open error examples when you are writing a client parser or a retry loop. If you just got an error string while playing, start at [play/errors](/play/errors), not here.

- [404 not found](404-not-found) -- Missing entity or path
- [429 rate limit](429-rate-limit) -- Throttle headers and backoff
- [500 server error](500-server-error) -- Upstream failure, retry with jitter
