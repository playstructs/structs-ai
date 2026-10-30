#!/usr/bin/env python3
"""Read-only, exact stored-state diagnostics through the pinned structsd CLI."""

import argparse
import json
import os
import re
import subprocess
import sys


UINT64_MAX = (1 << 64) - 1
QUERY_TIMEOUT = 15


def uint(value, name):
    if isinstance(value, bool) or not isinstance(value, (str, int)):
        raise ValueError(f'{name} must be an exact uint64')
    text = str(value)
    if not re.fullmatch(r'0|[1-9][0-9]{0,19}', text) or int(text) > UINT64_MAX:
        raise ValueError(f'{name} must be an exact uint64')
    return int(text)


def object_id(value, prefix):
    if not isinstance(value, str) or not re.fullmatch(prefix + r'-[1-9][0-9]*', value):
        raise ValueError('Invalid entity id')
    uint(value.split('-', 1)[1], 'entity index')
    return value


def mapping(value, name):
    if not isinstance(value, dict):
        raise ValueError(f'Missing or invalid {name}')
    return value


def entity(response, kind, expected):
    result = mapping(response.get(kind), kind)
    if result.get('id') != expected:
        raise ValueError(f'{kind} query returned a different entity')
    return result


def grid(response):
    # A successful typed response supplies this object. Only omitted primitive
    # fields inside it have protobuf zero defaults; missing responses do not.
    return mapping(response.get('gridAttributes'), 'gridAttributes')


class Snapshot:
    def __init__(self):
        self.binary = os.environ.get('STRUCTSD', 'structsd')
        node = os.environ.get('STRUCTS_NODE', '')
        self.node_args = ['--node', node] if node else []
        self.chain, self.height, self.catching_up = self.status()
        expected = os.environ.get('STRUCTS_CHAIN_ID')
        if expected and self.chain != expected:
            raise ValueError('RPC chain does not match STRUCTS_CHAIN_ID')

    def run(self, args):
        try:
            result = subprocess.run([self.binary, *args, *self.node_args],
                                    text=True, capture_output=True, timeout=QUERY_TIMEOUT)
        except (OSError, subprocess.TimeoutExpired) as error:
            raise ValueError('structsd read unavailable or timed out') from error
        if result.returncode:
            raise ValueError('structsd read failed; no assessment is available')
        try:
            return mapping(json.loads(result.stdout), 'query response')
        except (ValueError, TypeError) as error:
            raise ValueError('Invalid structsd JSON response') from error

    def status(self):
        result = self.run(['status'])
        info = mapping(result.get('node_info', result.get('NodeInfo')), 'node info')
        sync = mapping(result.get('sync_info', result.get('SyncInfo')), 'sync info')
        chain = info.get('network')
        if not isinstance(chain, str) or not re.fullmatch(r'[A-Za-z0-9._-]{1,128}', chain):
            raise ValueError('Invalid chain identity')
        height = uint(sync.get('latest_block_height'), 'source height')
        if not 0 < height <= (1 << 63) - 1 or not isinstance(sync.get('catching_up'), bool):
            raise ValueError('Invalid source status')
        return chain, height, sync['catching_up']

    def query(self, command, identity):
        # Cosmos query commands propagate --height into the ABCI request. This
        # trusts the configured node/CLI, not a light-client consensus proof.
        return self.run(['query', 'structs', command, identity,
                         '--height', str(self.height), '-o', 'json'])

    def finish(self):
        chain, height, _ = self.status()
        if chain != self.chain or height < self.height:
            raise ValueError('RPC identity or height changed during assessment')


def assess(args):
    player_id = object_id(args.player, '1')
    if args.mode == 'assess' and (args.load is not None or args.type_id is not None):
        raise ValueError('assess takes only a player id')
    if args.load is not None and args.type_id is not None:
        raise ValueError('Choose a prospective load or --type, not both')
    new_load = uint(args.load if args.load is not None else '0', 'prospective load')
    type_id = str(uint(args.type_id, 'struct type')) if args.type_id is not None else None
    if type_id == '0':
        raise ValueError('struct type must be positive')
    snapshot = Snapshot()
    response = snapshot.query('player', player_id)
    player = entity(response, 'Player', player_id)
    attributes = grid(response)
    capacity = uint(attributes.get('capacity', '0'), 'capacity')
    load = uint(attributes.get('load', '0'), 'load')
    structs_load = uint(attributes.get('structsLoad', '0'), 'structsLoad')
    secondary = 0
    substation = player.get('substationId', '')
    if substation:
        object_id(substation, '4')
        sub_response = snapshot.query('substation', substation)
        entity(sub_response, 'Substation', substation)
        secondary = uint(grid(sub_response).get('connectionCapacity', '0'), 'connectionCapacity')
    elif not isinstance(substation, str):
        raise ValueError('Invalid substation association')
    label = ''
    if type_id is not None:
        result = snapshot.query('struct-type', type_id)
        struct_type = mapping(result.get('StructType'), 'StructType')
        if uint(struct_type.get('id'), 'returned struct type') != int(type_id):
            raise ValueError('Struct type query returned a different entity')
        new_load = uint(struct_type.get('passiveDraw', '0'), 'passiveDraw')
        label = f' (struct type {type_id} passiveDraw)'

    # Individual attributes are uint64; their sums and signed differences are
    # deliberately not clamped to a machine word or the native return type.
    total_capacity = capacity + secondary
    total_load = load + structs_load
    margin = total_capacity - total_load
    lines = [f'== Stored power: player {player_id} ==',
             f'  source: {snapshot.chain} at height {snapshot.height}',
             f'  node catching up: {str(snapshot.catching_up).lower()}',
             f'  capacity: {capacity} mW',
             f'  capacitySecondary: {secondary} mW (substation connectionCapacity)',
             f'  load: {load} mW', f'  structsLoad: {structs_load} mW',
             f'  total capacity: {total_capacity} mW', f'  total load: {total_load} mW',
             f'  stored margin: {margin} mW' + (' (stored load exceeds capacity)' if margin < 0 else '')]
    if args.mode == 'power' and (args.load is not None or type_id is not None):
        lines.append(f'  after +{new_load} mW{label}: {margin - new_load} mW stored margin')
    if args.mode == 'assess':
        last_action = uint(attributes.get('lastAction', '0'), 'lastAction')
        if last_action > snapshot.height:
            raise ValueError('lastAction is newer than the source height')
        ore = uint(attributes.get('ore', '0'), 'ore')
        lines.extend([f'  charge: {snapshot.height - last_action} (height - lastAction)',
                      f'  unrefined ore: {ore}' + (' (stealable)' if ore else '')])
        for field, kind, prefix in [('planetId', 'Planet', '2'), ('fleetId', 'Fleet', '9')]:
            identity = player.get(field, '')
            if not isinstance(identity, str):
                raise ValueError(f'Invalid {field}')
            if not identity:
                lines.append(f'  {kind.lower()}: none')
                continue
            object_id(identity, prefix)
            detail = snapshot.query(kind.lower(), identity)
            found = entity(detail, kind, identity)
            if kind == 'Planet':
                remaining = uint(grid(detail).get('ore', '0'), 'planet ore')
                lines.append(f'  planet ore left: {remaining} ({identity})')
            else:
                status = found.get('status', 'onStation')
                if status not in ('onStation', 'away'):
                    raise ValueError('Invalid fleet status')
                lines.append(f'  fleet: {identity} status={status}')
    snapshot.finish()
    lines.append('  Stored totals do not prove live usable supply, online status or action eligibility.')
    lines.append('  Verify the actual action with native preflight and its committed result.')
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['assess', 'power'])
    parser.add_argument('player', nargs='?', default=os.environ.get('STRUCTS_PLAYER'))
    parser.add_argument('load', nargs='?')
    parser.add_argument('--type', dest='type_id')
    args = parser.parse_args()
    try:
        print(assess(args))
    except ValueError as error:
        print(f'error: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
