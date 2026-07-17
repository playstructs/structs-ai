# Commander (compatibility stub)

The human operator profile now lives in one file: **[`config/operator.md`](config/operator.md)**
(copy it from [`config/operator.example.md`](config/operator.example.md)).

It holds your goals, risk, autonomy level, guild preference, connection details, and
standing orders (Tier 1 caps, Tier 2 escalation, known-hostile, forbidden). The Tier
definitions live in [`SAFETY.md`](SAFETY.md).

This stub remains so older prompts that reference `COMMANDER.md` still resolve. New work
should read `config/operator.md`.
