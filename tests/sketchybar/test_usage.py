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
            with patch('os.path.expanduser', return_value=directory), patch('time.time', return_value=NOW), patch('subprocess.run', side_effect=OSError):
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


if __name__ == '__main__':
    unittest.main()
