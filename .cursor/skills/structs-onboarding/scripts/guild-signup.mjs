#!/usr/bin/env node

// Guild Signup Tool for Structs AI Agents
// Adapted from https://github.com/playstructs/structs-sign-proxy
//
// Signs a guild-join proxy message and POSTs to the guild API signup endpoint.
// Outputs JSON to stdout for agent parsing.
//
// Usage:
//   node guild-signup.mjs --mnemonic "word1 word2 ..." --guild-id "0-1" --guild-api "http://crew.oh.energy/api/" --username "my-agent"

import { DirectSecp256k1HdWallet } from "@cosmjs/proto-signing";
import { Secp256k1, sha256 } from "@cosmjs/crypto";

function bytesToHex(byteArray) {
  return Array.from(byteArray, byte => ('0' + (byte & 0xFF).toString(16)).slice(-2)).join('');
}

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    if (argv[i] === '--mnemonic' && argv[i + 1]) args.mnemonic = argv[++i];
    else if (argv[i] === '--guild-id' && argv[i + 1]) args.guildId = argv[++i];
    else if (argv[i] === '--guild-api' && argv[i + 1]) args.guildApi = argv[++i];
    else if (argv[i] === '--username' && argv[i + 1]) args.username = argv[++i];
  }
  return args;
}

async function main() {
  const args = parseArgs(process.argv);

  if (!args.mnemonic || !args.guildId || !args.guildApi) {
    console.error(JSON.stringify({
      error: "Missing required arguments",
      usage: 'node guild-signup.mjs --mnemonic "..." --guild-id "0-1" --guild-api "http://crew.oh.energy/api/" --username "my-agent"'
    }));
    process.exit(1);
  }

  const wallet = await DirectSecp256k1HdWallet.fromMnemonic(args.mnemonic, { prefix: "structs" });
  const accounts = await wallet.getAccountsWithPrivkeys();
  const account = accounts[0];
  const address = account.address;

  const nonce = "0";
  const message = `GUILD${args.guildId}ADDRESS${address}NONCE${nonce}`;
  const digest = sha256(new TextEncoder().encode(message));
  const signature = await Secp256k1.createSignature(digest, account.privkey);

  const pubkeyHex = bytesToHex(account.pubkey);
  const signatureHex = bytesToHex(signature.toFixedLength());

  const signupPayload = {
    primary_address: address,
    signature: signatureHex,
    pubkey: pubkeyHex,
    guild_id: args.guildId,
    username: args.username || null,
    pfp: null
  };

  const apiUrl = args.guildApi.replace(/\/+$/, '');

  let response;
  try {
    response = await fetch(`${apiUrl}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(signupPayload)
    });
  } catch (err) {
    console.log(JSON.stringify({
      success: false,
      error: `Failed to connect to guild API: ${err.message}`,
      address,
      guild_id: args.guildId,
      guild_api: apiUrl
    }));
    process.exit(1);
  }

  let body;
  try {
    body = await response.json();
  } catch {
    body = await response.text();
  }

  console.log(JSON.stringify({
    success: response.ok,
    status: response.status,
    address,
    guild_id: args.guildId,
    username: args.username || null,
    response: body
  }));

  process.exit(response.ok ? 0 : 1);
}

main();
