# Webapp Banned Word API Endpoints

**Category**: webapp (catalog read)
**Entity**: BannedWord (`structs.banned_word`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

The seeded list of banned tokens used by the chain's UGC validators. The on-chain `MsgPlayerUpdateName` / `MsgGuildUpdateName` / `MsgPlanetUpdateName` / `MsgSubstationUpdateName` (and the matching `Pfp` variants) reject names containing any of these tokens. Webapps surface the list so client-side forms can preflight the same check before signing. See `knowledge/mechanics/ugc-moderation.md` for the full validation pipeline.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/banned-word/all/page/{page}` | List every banned word, paginated | No |

---

## Endpoint Details

### GET `/api/banned-word/all/page/{page}`

List every banned word.

- **ID**: `webapp-banned-word-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
