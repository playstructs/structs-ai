# Structs + OpenClaw (and NanoClaw, PicoClaw)

Use the structs-ai repository as your OpenClaw workspace so the agent has full access to skills, scripts, and game knowledge.

---

## Setup

1. **Clone structs-ai**

   ```
   git clone https://github.com/playstructs/structs-ai
   cd structs-ai
   ```

2. **Set the OpenClaw workspace** to the structs-ai path.

   In `~/.openclaw/openclaw.json`:

   ```json
   {
     "agent": {
       "workspace": "/path/to/structs-ai",
       "skipBootstrap": true
     }
   }
   ```

   Or, if your config uses `agents.defaults`:

   ```json
   {
     "agents": {
       "defaults": {
         "workspace": "/path/to/structs-ai"
       }
     },
     "agent": {
       "skipBootstrap": true
     }
   }
   ```

   `skipBootstrap: true` prevents OpenClaw from overwriting our AGENTS.md, SOUL.md, and other files with its defaults.

3. **Skills** — The repo includes a `skills/` directory with symlinks to `.cursor/skills/`. OpenClaw will discover structs-onboarding, structs-building, structs-mining, etc. automatically.

4. **Seed missing files** (optional):

   ```
   openclaw setup --workspace /path/to/structs-ai
   ```

   This creates any missing OpenClaw-expected files (e.g., USER.md) without overwriting existing ones.

5. **Install structsd** — Use the structsd-install skill or install manually. See `.cursor/skills/structsd-install/SKILL.md`.

6. **Fill TOOLS.md** — Add your server addresses, account, chain ID, and secrets.

7. **Play** — Tell your agent: "Read SOUL.md and AGENTS.md. Play Structs."

---

## File Mapping

| OpenClaw expects | Structs-ai provides |
|------------------|---------------------|
| AGENTS.md | Yes |
| SOUL.md | Yes |
| IDENTITY.md | Yes |
| USER.md | Yes (references COMMANDER.md) |
| TOOLS.md | Yes |
| memory/ | Yes |
| skills/ | Yes (symlinks to .cursor/skills/) |

---

## NanoClaw / PicoClaw

NanoClaw and PicoClaw extend the OpenClaw concept with different runtimes. Our skills use the AgentSkills format (SKILL.md with YAML frontmatter), which should work where that format is supported. Set the workspace to the structs-ai path and verify the skills directory is discovered. If your variant uses a different workspace layout, adjust the path accordingly.

---

## Troubleshooting

- **Skills not loading** — Ensure `skills/` exists in the repo root. It contains symlinks to `.cursor/skills/*`. If missing, run: `mkdir -p skills && for d in .cursor/skills/*/; do ln -sf "../$d" "skills/$(basename $d)"; done` from the repo root.
- **OpenClaw overwrote my files** — Set `agent.skipBootstrap: true` and restore from git.
- **create-player script fails** — Ensure you're in the structs-ai workspace. The script lives at `.cursor/skills/structs-onboarding/scripts/create-player.mjs`. Run `npm install` in that directory first.
