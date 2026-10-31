import json
from pathlib import Path
import subprocess
import tempfile
import unittest


LIBRARY = Path(__file__).resolve().parents[2] / 'suckless/mac_os/sketchybar/plugins/popup.sh'


class PopupCacheTests(unittest.TestCase):
    def render_with_cached_rows(self, items):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'popup.media').write_text('MEDIA\n_\tSong\twhite\t')
            (root / 'query.json').write_text(json.dumps({'popup': {'items': items}}))
            script = '''
source "$1"
POPUP_CACHE="$2"
FONT=Menlo TEXT=white TEXT2=white TEXT3=grey
sketchybar() {
  if [ "$1" = --query ]; then
    cat "$POPUP_CACHE/query.json"
  else
    printf '%s\n' "$@" >> "$POPUP_CACHE/commands"
  fi
}
printf '_\tSong\twhite\t' | popup_rows media MEDIA
'''
            subprocess.run(['/bin/bash', '-c', script, 'test', str(LIBRARY), str(root)], check=True)
            log = root / 'commands'
            return log.read_text().splitlines() if log.exists() else []

    def test_reload_rebuilds_missing_rows_even_when_content_is_cached(self):
        commands = self.render_with_cached_rows([])
        self.assertIn('--add', commands)
        self.assertIn('media.p.0', commands)

    def test_existing_unchanged_popup_is_left_alone(self):
        commands = self.render_with_cached_rows([
            'media.p.a', 'media.p.t', 'media.p.g', 'media.p.0', 'media.p.z',
        ])
        self.assertEqual(commands, [])


if __name__ == '__main__':
    unittest.main()
