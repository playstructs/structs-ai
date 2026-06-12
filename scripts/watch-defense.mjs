#!/usr/bin/env node
// watch-defense.mjs — real-time defense alerts via GRASS (NATS WebSocket).
//
// Watches your planet/struct/player subjects and prints a line every time
// something defense-relevant happens: a raid against you, an attack on your
// struct, or your Command Ship going offline/destroyed (which drops your
// shields and makes the planet raidable in v0.18.0).
//
// READ-ONLY: it never signs or submits anything. It only observes and alerts.
//
// Usage:
//   node scripts/watch-defense.mjs structs.planet.2-117 [more.subjects ...]
//   GRASS_URL=ws://crew.oh.energy:1443 node scripts/watch-defense.mjs structs.planet.2-117
//
// Find your GRASS endpoint from your guild config (services.grass_nats_websocket);
// see the structs-streaming skill. Requires: npm install nats.ws

const GRASS_URL = process.env.GRASS_URL || "ws://crew.oh.energy:1443";
const subjects = process.argv.slice(2);

if (subjects.length === 0) {
  console.error("usage: node scripts/watch-defense.mjs <subject> [<subject> ...]");
  console.error("example: node scripts/watch-defense.mjs structs.planet.2-117 structs.player.0-1.1-42");
  process.exit(1);
}

let connect;
try {
  ({ connect } = await import("nats.ws"));
} catch {
  console.error("Missing dependency 'nats.ws'. Install it: npm install nats.ws");
  process.exit(1);
}

// Categories worth waking a human (or the agent) for.
const ALERT = new Set([
  "raid_status",
  "struct_attack",
  "struct_status",
  "struct_health",
  "fleet_arrive",
]);

function isCommandShipDown(ev) {
  // Heuristic: a struct status/health event reporting offline or destroyed.
  const status = String(ev.status || ev.state || "").toLowerCase();
  if (ev.destroyed === true || ev.targetDestroyed === true) return true;
  return /offline|destroyed|inactive/.test(status);
}

function stamp() {
  return new Date().toISOString();
}

const nc = await connect({ servers: GRASS_URL });
console.error(`[watch-defense] connected to ${GRASS_URL}; watching: ${subjects.join(", ")}`);

for (const subject of subjects) {
  (async () => {
    const sub = nc.subscribe(subject);
    for await (const msg of sub) {
      let ev;
      try {
        ev = JSON.parse(new TextDecoder().decode(msg.data));
      } catch {
        continue;
      }
      const cat = ev.category || ev.type || "";
      if (!ALERT.has(cat)) continue;

      let level = "INFO";
      if (cat === "raid_status") level = "ALERT";
      if (cat === "struct_attack") level = "ALERT";
      if ((cat === "struct_status" || cat === "struct_health") && isCommandShipDown(ev)) {
        level = "CRITICAL";
      }

      console.log(
        JSON.stringify({
          ts: stamp(),
          level,
          subject: msg.subject,
          category: cat,
          event: ev,
        })
      );

      if (level === "CRITICAL") {
        console.error(`[watch-defense] CRITICAL: a struct went offline/destroyed on ${msg.subject}. If it's your Command Ship, your shields are down — restore power immediately.`);
      }
    }
  })();
}

process.on("SIGINT", async () => {
  console.error("\n[watch-defense] closing");
  await nc.close();
  process.exit(0);
});
