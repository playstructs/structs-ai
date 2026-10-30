#!/usr/bin/env python3
"""Exercise the shipped read-only helpers with a disposable CLI fixture."""

import copy
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('assessment', ROOT / 'scripts/assessment.py')
ASSESSMENT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ASSESSMENT)
MAX = (1 << 64) - 1
BASE = {
    'status': {'node_info': {'network': 'structstestnet-111'},
               'sync_info': {'latest_block_height': '3353000', 'catching_up': False}},
    'player': {'Player': {'id': '1-1', 'substationId': '4-1', 'planetId': '2-1', 'fleetId': '9-1'},
               'gridAttributes': {'capacity': '1000000', 'load': '100000', 'structsLoad': '25000',
                                  'lastAction': '3352998', 'ore': '2'}},
    'substation': {'Substation': {'id': '4-1'}, 'gridAttributes': {'connectionCapacity': '200000'}},
    'struct-type': {'StructType': {'id': '14', 'passiveDraw': '500000'}},
    'planet': {'Planet': {'id': '2-1'}, 'gridAttributes': {'ore': '7'}},
    'fleet': {'Fleet': {'id': '9-1'}},
}
FAKE = '''#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
args=sys.argv[1:]
log=Path(os.environ['FIXTURE_LOG'])
previous=log.read_text().splitlines() if log.exists() else []
with log.open('a') as out: out.write(json.dumps(args)+'\\n')
data=json.loads(Path(os.environ['FIXTURE_DATA']).read_text())
if args[0]=='status':
    key='status_after' if previous and 'status_after' in data else 'status'
elif args[:2]==['query','structs']:
    key=args[2]
else:
    sys.exit('Fixture refuses non-query commands')
value=data[key]
if value=='FAIL': sys.exit(1)
print(value if value=='not-json' else json.dumps(value))
'''


class AssessmentTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='structs-assessment-')
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name)
        self.binary = self.path / 'fake structsd'
        self.binary.write_text(FAKE)
        self.binary.chmod(0o700)
        self.data = copy.deepcopy(BASE)

    def run_helper(self, script='power-budget.sh', args=('1-1',), **extra):
        (self.path / 'data.json').write_text(json.dumps(self.data))
        log = self.path / 'calls.jsonl'
        if log.exists():
            log.unlink()
        env = {key: value for key, value in os.environ.items() if not key.startswith('STRUCTS_')}
        env.update(STRUCTSD=str(self.binary), STRUCTS_NODE='http://fixture.invalid:26657',
                   STRUCTS_CHAIN_ID='structstestnet-111', FIXTURE_DATA=str(self.path / 'data.json'),
                   FIXTURE_LOG=str(log), **extra)
        result = subprocess.run(['bash', str(ROOT / 'scripts' / script), *args],
                                text=True, capture_output=True, env=env, timeout=10)
        calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
        return result, calls

    def assert_unavailable(self, result):
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, '', 'No partial decision on failed evidence')

    def test_exact_power_and_single_source(self):
        result, calls = self.run_helper(args=('1-1', '--type', '14'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('stored margin: 1075000 mW', result.stdout)
        self.assertIn('after +500000 mW (struct type 14 passiveDraw): 575000 mW', result.stdout)
        self.assertIn('do not prove live usable supply', result.stdout)
        self.assertEqual([call[0] for call in calls], ['status', 'query', 'query', 'query', 'status'])
        for call in calls:
            self.assertEqual(call[-2:], ['--node', 'http://fixture.invalid:26657'])
            if call[0] == 'query':
                self.assertEqual(call[call.index('--height') + 1], '3353000')

    def test_uint64_boundaries_and_unbounded_totals(self):
        for value in [0, (1 << 53) + 1, 1 << 63, MAX]:
            with self.subTest(value=value):
                self.data['player']['gridAttributes'] = {'capacity': str(value), 'load': '0', 'structsLoad': '0'}
                self.data['substation']['gridAttributes']['connectionCapacity'] = str(value)
                result, _ = self.run_helper(args=('1-1', str(MAX)))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f'total capacity: {2 * value} mW', result.stdout)
                self.assertIn(f'after +{MAX} mW: {2 * value - MAX} mW stored margin', result.stdout)

    def test_overloaded_totals_do_not_wrap_or_saturate(self):
        self.data['player']['gridAttributes'] = {'capacity': str(MAX), 'load': str(MAX), 'structsLoad': str(MAX)}
        self.data['substation']['gridAttributes']['connectionCapacity'] = str(MAX - 1)
        result, _ = self.run_helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('stored margin: -1 mW (stored load exceeds capacity)', result.stdout)

    def test_assessment_defaults_require_known_entities(self):
        self.data['player']['gridAttributes'] = {}
        self.data['substation']['gridAttributes'] = {}
        self.data['planet']['gridAttributes'] = {}
        result, _ = self.run_helper('assess.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('charge: 3353000 (height - lastAction)', result.stdout)
        self.assertIn('planet ore left: 0', result.stdout)
        self.assertIn('status=onStation', result.stdout)
        self.assertIn('stored margin: 0', result.stdout)

    def test_assessment_complete_snapshot(self):
        result, calls = self.run_helper('assess.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('charge: 2', result.stdout)
        self.assertIn('unrefined ore: 2 (stealable)', result.stdout)
        self.assertIn('planet ore left: 7', result.stdout)
        self.assertEqual(len([call for call in calls if call[0] == 'query']), 4)

    def test_no_associations_are_authoritative_absence(self):
        self.data['player']['Player'] = {'id': '1-1'}
        result, calls = self.run_helper('assess.sh', args=(), STRUCTS_PLAYER='1-1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('capacitySecondary: 0', result.stdout)
        self.assertIn('planet: none', result.stdout)
        self.assertIn('fleet: none', result.stdout)
        self.assertEqual(len(calls), 3)

    def test_every_required_read_failure_refuses_output(self):
        for key in BASE:
            for failure in ['FAIL', 'not-json', {}, None]:
                with self.subTest(key=key, failure=failure):
                    self.data = copy.deepcopy(BASE)
                    self.data[key] = failure
                    mode = 'power-budget.sh' if key == 'struct-type' else 'assess.sh'
                    args = ('1-1', '--type', '14') if key == 'struct-type' else ('1-1',)
                    result, _ = self.run_helper(mode, args)
                    self.assert_unavailable(result)

    def test_invalid_numeric_inputs_and_fields(self):
        for value in ['', '-1', '01', '1.0', '1e3', str(MAX + 1), True, None, 1.5]:
            with self.subTest(value=value):
                self.data['player']['gridAttributes']['capacity'] = value
                result, _ = self.run_helper()
                self.assert_unavailable(result)
        self.data = copy.deepcopy(BASE)
        for value in ['', '-1', '01', str(MAX + 1)]:
            result, calls = self.run_helper(args=('1-1', value))
            self.assert_unavailable(result)
            self.assertEqual(calls, [])

    def test_wrong_entities_and_missing_grids(self):
        for key, kind in [('player', 'Player'), ('substation', 'Substation'), ('planet', 'Planet'), ('fleet', 'Fleet')]:
            with self.subTest(key=key):
                self.data = copy.deepcopy(BASE)
                self.data[key][kind]['id'] = '1-999'
                result, _ = self.run_helper('assess.sh')
                self.assert_unavailable(result)
        for key in ['player', 'substation', 'planet']:
            self.data = copy.deepcopy(BASE)
            del self.data[key]['gridAttributes']
            result, _ = self.run_helper('assess.sh')
            self.assert_unavailable(result)

    def test_future_charge_and_invalid_fleet_do_not_become_defaults(self):
        self.data['player']['gridAttributes']['lastAction'] = '3353001'
        self.assert_unavailable(self.run_helper('assess.sh')[0])
        self.data = copy.deepcopy(BASE)
        self.data['fleet']['Fleet']['status'] = None
        self.assert_unavailable(self.run_helper('assess.sh')[0])

    def test_source_changes_and_expected_chain(self):
        for after in [dict(BASE['status'], node_info={'network': 'other'}),
                      dict(BASE['status'], sync_info={'latest_block_height': '3352999', 'catching_up': False})]:
            self.data['status_after'] = after
            self.assert_unavailable(self.run_helper()[0])
        self.data = copy.deepcopy(BASE)
        self.data['status']['node_info']['network'] = 'other'
        result, calls = self.run_helper()
        self.assert_unavailable(result)
        self.assertEqual(len(calls), 1)

    def test_cli_deadline_is_bounded_and_does_not_expose_stderr(self):
        snapshot = object.__new__(ASSESSMENT.Snapshot)
        snapshot.binary = 'structsd'; snapshot.node_args = []
        with patch.object(ASSESSMENT.subprocess, 'run', side_effect=subprocess.TimeoutExpired('fixture', 15)) as run:
            with self.assertRaisesRegex(ValueError, 'timed out'):
                snapshot.run(['status'])
            self.assertEqual(run.call_args.kwargs['timeout'], 15)

    def test_shared_shell_helper_refuses_failed_capacity(self):
        for response in [BASE['substation'], {'Substation': {'id': '4-1'}, 'gridAttributes': {}},
                         'FAIL', {}, {'Substation': {'id': '4-1'}, 'gridAttributes': {'connectionCapacity': None}}]:
            with self.subTest(response=response):
                self.data['substation'] = response
                data = self.path / 'data.json'; data.write_text(json.dumps(self.data))
                env = dict(os.environ, STRUCTSD=str(self.binary), STRUCTS_NODE='http://fixture.invalid:26657',
                           FIXTURE_DATA=str(data), FIXTURE_LOG=str(self.path / 'calls.jsonl'))
                result = subprocess.run(['bash', '-c', 'source "$1"; secondary_capacity "$2"', 'fixture',
                                         str(ROOT / 'scripts/lib.sh'), json.dumps(BASE['player'])],
                                        env=env, text=True, capture_output=True, timeout=10)
                valid = response == BASE['substation'] or response == {'Substation': {'id': '4-1'}, 'gridAttributes': {}}
                self.assertEqual(result.returncode == 0, valid, result.stderr)
                if valid:
                    self.assertEqual(result.stdout.strip(), '200000' if response == BASE['substation'] else '0')


if __name__ == '__main__':
    unittest.main()
