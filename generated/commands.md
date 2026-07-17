---
kind: mechanics
authority: source
verified_against: structsd 0.20.0
verified_at: 2026-07-17
volatility: medium
generated_by: scripts/gen-catalogs.py
---

# CLI command catalog

> Generated from `structsd tx/query structs --help`. These are **CLI command names**, not proto message names. Do not hand-edit.

## `structsd tx structs`

| Command | Description |
|---|---|
| `address-register` | Submit a claim on an address, relating it to a player account |
| `address-revoke` | Remove an address from a player account |
| `agreement-capacity-decrease` | Decrease the Capacity of an established Agreement |
| `agreement-capacity-increase` | Increase the Capacity of an established Agreement |
| `agreement-close` | Close an Agreement with an Energy Provider |
| `agreement-duration-increase` | Increase the Duration of an established Agreement |
| `agreement-open` | Open an Agreement with an Energy Provider |
| `allocation-create` | Create an Allocation of energy from a power source |
| `allocation-delete` | Delete a dynamic Allocation |
| `allocation-transfer` | Transfer an Allocation to a different account |
| `allocation-update` | Update a dynamic Allocation |
| `fleet-move` | Move a fleet from one planet to another |
| `guild-bank-confiscate-and-burn` | Confiscate a Guild Token from an address and burn it |
| `guild-bank-mint` | Mint new Alpha-backed token for a guild |
| `guild-bank-redeem` | Redeem a Guild Token for the underlying Alpha asset |
| `guild-create` | Create a guild from an account with an associated Reactor |
| `guild-membership-invite` | Invite a player to a guild |
| `guild-membership-invite-approve` | Accept an invitation to a guild |
| `guild-membership-invite-deny` | Deny an invitation to a guild |
| `guild-membership-invite-revoke` | Cancel an invite to a player |
| `guild-membership-join` | Join a guild with enough infusions to meet minimum requirements |
| `guild-membership-join-proxy` | Add an account a guild and connect them with some power |
| `guild-membership-kick` | Kick a player from a guild |
| `guild-membership-request` | Request entry to a guild |
| `guild-membership-request-approve` | Accept a request from a player to join the guild |
| `guild-membership-request-deny` | Deny a request to join a guild |
| `guild-membership-request-revoke` | Destroy an application to join a guild |
| `guild-update-endpoint` | Update the endpoint Guild setting |
| `guild-update-entry-rank` | Update the entry rank for your guild |
| `guild-update-entry-substation-id` | Update the entry substation Guild setting |
| `guild-update-join-infusion-minimum` | Update the infusion minimum Guild setting |
| `guild-update-join-infusion-minimum-by-invite` | Update the minimum bypass level for invites Guild setting |
| `guild-update-name` | Update the cosmetic name of a guild |
| `guild-update-owner-id` | Update the owner of the Guild |
| `guild-update-pfp` | Update the profile picture of a guild |
| `guild-update-primary-reactor` | Reassign the guild's primary reactor (recovery for retired/jailed validators) |
| `permission-grant-on-address` | Grant a set of permissions to an address |
| `permission-grant-on-object` | Grant a set of permissions on an object to a player |
| `permission-guild-rank-revoke` | Revoke guild rank permission on an object |
| `permission-guild-rank-set` | Set guild rank requirement for a permission on an object |
| `permission-revoke-on-address` | Revoke a set of permissions on from an address |
| `permission-revoke-on-object` | Revoke a set of permissions on an object from a player |
| `permission-set-on-address` | Clear previous permissions and apply a new full set on from an address |
| `permission-set-on-object` | Clear previous permissions and apply a new full set on an object from a player |
| `planet-explore` | Explore a new planet, optionally giving it a name |
| `planet-raid-complete` | Complete a Planet Raid |
| `planet-raid-compute` | Do the work to raid a planet |
| `planet-update-name` | Update the cosmetic name of a planet |
| `player-send` | Send tokens from any player-owned address |
| `player-update-guild-rank` | Update the guild rank of a player in your guild |
| `player-update-name` | Update the cosmetic name of a player |
| `player-update-pfp` | Update the profile picture of a player |
| `player-update-pfp-cr-attributes` | Update the client render attributes for a player's local profile picture |
| `player-update-primary-address` | Update the primary address for a player |
| `provider-create` | Create a new Energy Provider offering |
| `provider-delete` | Delete an Energy Provider and Cancel all Agreements |
| `provider-update-access-policy` | Update the Access Policy of a Provider |
| `provider-update-capacity-maximum` | Update the Maximum Capacity of a Provider |
| `provider-update-capacity-minimum` | Update the Minimum Capacity of a Provider |
| `provider-update-duration-maximum` | Update the Maximum Duration of a Provider |
| `provider-update-duration-minimum` | Update the Minimum Duration of a Provider |
| `provider-withdraw-balance` | Withdraw the pending earnings from a Provider |
| `reactor-begin-migration` | Migrate Alpha from one Reactor to another |
| `reactor-cancel-defusion` | Place cooling Alpha back into the Reactor to resume generating energy |
| `reactor-defuse` | Defuse Alpha from a Reactor, returning it to the player after a cooldown |
| `reactor-infuse` | Infuse Alpha from a player address into a reactor |
| `struct-activate` | Bring a Struct online |
| `struct-attack` | Attack a Struct with a Struct |
| `struct-build-cancel` | Cancel an unfinished Struct |
| `struct-build-complete` | Bring a Struct online |
| `struct-build-compute` | Do the work to finish a Struct build |
| `struct-build-initiate` | Initiate the construction of a Struct |
| `struct-deactivate` | Take a Struct offline |
| `struct-deactivate-batch` | Take multiple Structs offline in one transaction |
| `struct-defense-clear` | Clear the defensive relationship for a defending Struct |
| `struct-defense-set` | Set a defensive relationship for a Struct |
| `struct-generator-infuse` | Infuse Alpha into a generating Struct (cannot be undone!) |
| `struct-move` | Move a Struct to a different ambit, slot, or location |
| `struct-ore-mine-complete` | Complete a Struct mining action |
| `struct-ore-mine-compute` | Do the work to extract an Ore from the planet |
| `struct-ore-refine-complete` | Complete a Struct refining action |
| `struct-ore-refine-compute` | Do the work to convert Alpha Ore into Alpha Matter |
| `struct-stealth-activate` | Activate the Stealth systems on a Struct |
| `struct-stealth-deactivate` | Deactivate the Stealth systems on a Struct |
| `struct-trash` | Destroy (trash) a Struct, consuming the build charge |
| `substation-allocation-connect` | Connect an Allocation to a Substation |
| `substation-allocation-disconnect` | Disconnect an Allocation from a Substation |
| `substation-create` | Create a new Substation with an initial allocation |
| `substation-delete` | Delete a Substation |
| `substation-player-connect` | Connect a Player to a Substation |
| `substation-player-disconnect` | Disconnect a Player from a Substation |
| `substation-player-migrate` | Migrate a list of Players to another Substation |
| `substation-update-name` | Update the cosmetic name of a substation |
| `substation-update-pfp` | Update the profile picture of a substation |

## `structsd query structs`

| Command | Description |
|---|---|
| `address` | Show the details of a specific Address |
| `address-all` | Returns all Addresses |
| `address-all-by-player` | Returns all Addresses for a specific Player |
| `agreement` | Show the details of a specific Agreement |
| `agreement-all` | Returns all Agreements |
| `agreement-all-by-provider` | Returns all Agreements from a specific Provider |
| `allocation` | Show the details of a specific Allocation |
| `allocation-all` | Returns all Allocations |
| `allocation-all-by-destination` | Returns all Allocations connected to a specific destination |
| `allocation-all-by-source` | Returns all Allocations originating from a specific source |
| `block-height` | Get the current Block Height |
| `fleet` | Show the details of a specific Fleet |
| `fleet-all` | Returns all Fleets |
| `fleet-by-index` | Show the details of a specific Fleet, as looked up by the index |
| `grid` | Show the details of a specific Grid Attribute |
| `grid-all` | Returns all Grid Attributes |
| `guild` | Show the details of a specific Guild |
| `guild-all` | Returns all Guilds |
| `guild-bank-collateral-address` | Lookup a Guild Bank Collateral Address |
| `guild-bank-collateral-address-all` | Show all Guild Bank Collateral Addresses |
| `guild-membership-application` | Show the details of a specific Membership Application |
| `guild-membership-application-all` | Returns all Guild Membership Applications |
| `guild-rank-permission-by-object` | List guild rank permissions for an object |
| `infusion` | Show the details of a specific Infusion |
| `infusion-all` | Returns all Infusions |
| `infusion-all-by-destination` | Returns all Infusions to a specific destination |
| `params` | Shows the parameters of the module |
| `permission` | Show the details of a specific Permission |
| `permission-all` | Returns all Permissions |
| `permission-by-object` | Show the details of a specific Permission |
| `permission-by-player` | Show the details of a specific Permission |
| `planet` | Show the details of a specific Planet |
| `planet-all` | Returns all Planets |
| `planet-all-by-player` | Show all Planets belonging to a Player |
| `planet-attribute` | Show the details of a specific Planet Attribute |
| `planet-attribute-all` | Execute the PlanetAttributeAll RPC method |
| `player` | Show the details of a specific Player |
| `player-all` | Returns all Players |
| `player-me` | shows a specific player |
| `provider` | Show the details of a specific Provider |
| `provider-all` | Returns all Providers |
| `provider-collateral-address` | Lookup a Provider Collateral Address |
| `provider-collateral-address-all` | Show All Provider Collateral Addresses |
| `provider-earnings-address` | Lookup a Provider Earnings Address |
| `provider-earnings-address-all` | Show all Provider Earnings Addresses |
| `reactor` | Show the details of a specific Reactor |
| `reactor-all` | Returns all Reactors |
| `struct` | Show the details of a specific Struct |
| `struct-all` | Returns all Structs |
| `struct-attribute` | Show the details of a specific Struct Attribute |
| `struct-attribute-all` | Execute the StructAttributeAll RPC method |
| `struct-type` | Show the details of a specific Struct Type |
| `struct-type-all` | Returns all Struct Types |
| `substation` | Show the details of a specific Substation |
| `substation-all` | Returns all Substations |
| `validate-signature` | Execute the ValidateSignature RPC method |

