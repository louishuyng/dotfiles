import contextlib
import io
import json
from pathlib import Path
import runpy
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[2] / 'suckless/mac_os/sketchybar/plugins/usage.py'
NOW = 1800000000
RESET = '2027-01-16T12:00:00Z'


class ClaudeUsageTests(unittest.TestCase):
    def read_usage(self, files):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            for name, value in files.items():
                file = home / name
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text(json.dumps(value))
            output = io.StringIO()
            with patch('os.path.expanduser', return_value=directory), patch('time.time', return_value=NOW):
                with contextlib.redirect_stdout(output):
                    runpy.run_path(str(SCRIPT))
            return json.loads(output.getvalue())

    def test_missing_usage_stays_unknown(self):
        result = self.read_usage({'.claude.json': {}})
        self.assertEqual(result['claude']['windows'], [])

    def test_legacy_usage_cache(self):
        result = self.read_usage({'.claude.json': {'cachedUsageUtilization': {
            'fetchedAtMs': NOW * 1000,
            'utilization': {'five_hour': {'utilization': 42, 'resets_at': RESET}},
        }}})
        self.assertEqual(result['claude']['windows'][0]['percent'], 42)

    def test_new_limits_array(self):
        result = self.read_usage({'.claude.json': {'cachedUsageUtilization': {
            'fetchedAtMs': NOW * 1000,
            'utilization': {'limits': [{'kind': 'five_hour', 'percent': 37, 'resets_at': RESET}]},
        }}})
        self.assertEqual(result['claude']['windows'][0]['percent'], 37)

    def test_newest_pilo_report_wins_and_bad_reports_are_skipped(self):
        result = self.read_usage({
            '.claude.json': {'cachedUsageUtilization': {
                'fetchedAtMs': (NOW - 100) * 1000,
                'utilization': {'five_hour': {'utilization': 10, 'resets_at': RESET}},
            }},
            '.pilo/usage/old.json': {'at': (NOW - 200) * 1000, 'rateLimits': [
                {'kind': 'five_hour', 'percentUsed': 5, 'resetsAt': RESET},
            ]},
            '.pilo/usage/current.json': {'at': NOW * 1000, 'rateLimits': [
                {'kind': 'five_hour', 'percentUsed': 48, 'resetsAt': RESET},
                {'kind': 'seven_day', 'percentUsed': 63, 'resetsAt': RESET},
            ]},
            '.pilo/usage/bad.json': {'at': 'invalid'},
        })
        windows = {window['key']: window['percent'] for window in result['claude']['windows']}
        self.assertEqual(windows, {'session': 48, 'weekly_all': 63})

    def test_expired_pilo_report_does_not_invent_zero_usage(self):
        result = self.read_usage({'.pilo/usage/session.json': {
            'at': NOW * 1000,
            'rateLimits': [{'kind': 'five_hour', 'percentUsed': 99, 'resetsAt': '2020-01-01T00:00:00Z'}],
        }})
        self.assertNotIn('claude', result)


if __name__ == '__main__':
    unittest.main()
