#!/usr/bin/env python3
# Builds the pixel icon PNGs (rev 7) — standard library only. 1pt = 2px (Retina). Theme colors are passed as arguments
#   pixel.py <output dir> <--text> <--text-3> <--warn>
# port (RJ45 11×11) · ts_on/ts_off (3×3 dots 11×11) · cat_<1-4>[_warn] (16×10, a cat newly drawn for this config)
import sys, zlib, struct, os
out, TEXT, TEXT3, WARN = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
def rgba(h):  # 0xAARRGGBB
    v = int(h, 16); return ((v >> 16) & 255, (v >> 8) & 255, v & 255, (v >> 24) & 255)
def png(path, rows):  # rows: per row, a list of colors (rgba) or None (in pt) → doubled
    w, h = len(rows[0]) * 2, len(rows) * 2
    raw = b''
    for r in rows:
        line = b''.join(bytes(c if c else (0, 0, 0, 0)) * 2 for c in r)
        raw += (b'\0' + line) * 2
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))
def bitmap(lines, col):
    return [[col if ch == '#' else None for ch in l] for l in lines]
os.makedirs(out, exist_ok=True)
T, T3, W = rgba(TEXT), rgba(TEXT3), rgba(WARN)
png(f'{out}/port.png', bitmap(['...........', '###########', '#.........#', '#.#.#.#.#.#', '#.........#', '#.........#',
                                '#.........#', '###.....###', '..#.....#..', '..#######..', '...........'], T))
def dots(on):  # 3×3 dots (3pt) · 1pt apart. on = positions of lit dots (row, col)
    g = [[None] * 11 for _ in range(11)]
    for r in range(3):
        for c in range(3):
            col = T if (r, c) in on else T3
            for y in range(3):
                for x in range(3): g[r * 4 + y][c * 4 + x] = col
    return g
png(f'{out}/ts_on.png', dots({(1, 0), (1, 1), (1, 2), (2, 1)}))
png(f'{out}/ts_off.png', dots(set()))
top = ['...........#..#.', '#..........####.', '#..........#.##.', '.#.........####.', '..#############.', '..############..', '..###########...']
legs = {1: ['.##.........##..', '#.............#.', '................'],
        2: ['..#.#.....#.#...', '..#..#...#..#...', '................'],
        3: ['...##.....##....', '....#.....#.....', '....#.....#.....']}
legs[4] = legs[2]
for k in range(1, 5):
    png(f'{out}/cat_{k}.png', bitmap(top + legs[k], T))
    png(f'{out}/cat_{k}_warn.png', bitmap(top + legs[k], W))
# cat circle (rev 8): one 33×33pt image = grass kept only inside the circle + cat (frames 1-4, normal/warn). The circle border and background are the SketchyBar circle (item background)
#   grass: blade tips 21 · stems 22 · ground 23 to the bottom (filled with the blade color), blade = accent 55% + bg 45% = #26795A, 9-cell pattern 0 2 1 0 2 0 1 2 0
GROUND, BLADE = (0x12, 0x28, 0x1F, 255), (0x26, 0x79, 0x5A, 255)
PAT = [0, 2, 1, 0, 2, 0, 1, 2, 0]
def png_px(path, g):  # g: 66×66 px (=33pt@2x) as-is
    w, h = len(g[0]), len(g)
    raw = b''.join(b'\0' + b''.join(bytes(c if c else (0, 0, 0, 0)) for c in row) for row in g)
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))
# cat circle (10-02 rev 3): cat size = midway between the first (1 cell 2px, 16×10pt) and the second (3px, 24×15pt) — 1 cell 2.5px (alternating 2px·3px) → 20×12.5pt
#   there is no integer scale between 2 and 3, so cells alternate 2 and 3px (Retina 1px = 0.5pt, so the unevenness is barely visible)
#   grass too: blade tips 50px · stems 52px · ground 54px~ to the circle edge in the blade color. In px (66×66 = 33pt@2x), only inside the circle (radius 31px)
def inside_px(x, y): return (x + 0.5 - 33) ** 2 + (y + 0.5 - 33) ** 2 <= 31 ** 2
def span(i): return int(i * 2.5), int((i + 1) * 2.5)   # px range covered by cell i
UP = int(os.environ.get('CAT_UP', '1')) * 2   # raises grass and cat together (cell = 1pt = 2px). By request 10-02: 1 cell
for k in range(1, 5):
    for wname, col in (('', T), ('_warn', W)):
        g = [[None] * 66 for _ in range(66)]
        for x in range(66):
            for y in range(54 - UP, 66): g[y][x] = BLADE
            h = PAT[(x // 2) % 9]
            if h >= 1: g[52 - UP][x] = g[53 - UP][x] = BLADE
            if h == 2: g[50 - UP][x] = g[51 - UP][x] = BLADE
        X0, Y0 = 13, 27 - UP   # centered 40×25px (13~53), feet end at 52px = above the blade tips
        for r, line in enumerate(top + legs[k]):
            for c, ch in enumerate(line):
                if ch == '#':
                    y0, y1 = span(r); x0, x1 = span(c)
                    for yy in range(Y0 + y0, Y0 + y1):
                        for xx in range(X0 + x0, X0 + x1): g[yy][xx] = col
        g = [[g[y][x] if inside_px(x, y) else None for x in range(66)] for y in range(66)]
        png_px(f'{out}/cc_{k}{wname}.png', g)
# pilo circle (optional): a round face with two arms = the state of your Pilo agents. No mark icons - arm pose, expression and color only
#   16×12 cells (3px each = 48×36px), dead centre of the 66px circle: origin (9, 15) → centre (33, 33). Body 10×10 cells (cols 3~12 · rows 1~10), arms 3 cells on each side
#   pilo_<state>_<frame>.png (66×66) · pilo_s_<state>_<frame>.png (popup rows, 2px cells = 16×12pt)
ERR = rgba(sys.argv[5]) if len(sys.argv) > 5 else W
BODY = ['...####...', '.########.'] + ['##########'] * 6 + ['.########.', '...####...']   # rows 1~10
ARM = {'down': [(6, 2), (7, 1), (8, 1)], 'mid': [(6, 2), (6, 1), (6, 0)], 'up': [(5, 2), (4, 1), (3, 0)], 'upb': [(5, 2), (4, 1), (3, 1)],
       'droop': [(7, 2), (8, 2), (9, 2)], 'head': [(4, 2), (3, 2), (2, 3), (1, 4)], 'headb': [(4, 2), (3, 2), (2, 3)], 'tuck': [(7, 2), (8, 2)], None: []}
EYES = {'open': [(4, 5), (5, 5)], 'shut': [(5, 4), (5, 5)], 'x': [(4, 4), (4, 6), (5, 5), (6, 4), (6, 6)], 'gt': [(4, 4), (5, 5), (6, 4)], 'dot': [(5, 5)]}   # left eye (the right one is mirrored)
MOUTH = {'smile': [(7, 6), (8, 7), (8, 8), (7, 9)], 'o': [(8, 7), (8, 8)], 'flat': [(8, 6), (8, 7), (8, 8), (8, 9)], 'frown': [(8, 6), (7, 7), (7, 8), (8, 9)],
         'low': [(8, 6), (8, 7), (8, 8), (8, 9)], 'low1': [(8, 7), (8, 8), (8, 9)], '': []}   # low/low1 = empty gauge (one cell left ↔ none)
#  state: color, frames [(left arm, right arm, eyes, mouth, breathing)]
POSES = {
  'running': (T,   [('up', 'down', 'open', 'smile', 0), ('mid', 'mid', 'open', 'smile', 0), ('down', 'up', 'open', 'smile', 0), ('mid', 'mid', 'open', 'smile', 0)]),   # arms swinging in turn
  'blocked': (ERR, [('down', 'up', 'open', 'o', 0), ('down', 'upb', 'open', 'o', 0)]),                 # one arm up, waving
  'stalled': (W,   [('droop', 'droop', 'dot', 'frown', 0), ('droop', 'droop', 'shut', 'frown', 0)]),   # arms limp, slow blink
  'failed':  (ERR, [('up', 'up', 'x', 'flat', 0), ('upb', 'upb', 'x', 'flat', 0)]),                    # both arms up, flailing
  'gaveUp':  (ERR, [('head', 'head', 'shut', 'flat', 0), ('headb', 'headb', 'shut', 'flat', 0)]),      # holding its head
  'limited': (T3,  [('down', 'down', 'gt', 'low1', 0), ('down', 'down', 'gt', 'low', 0)]),             # arms down, empty gauge
  'idle':    (T3,  [('tuck', 'tuck', 'shut', '', 0), ('tuck', 'tuck', 'shut', '', 1)]),                # arms tucked, asleep (breathing)
  'unbound': (T3,  [(None, None, None, '', 0)]),                                                      # dim outline
}
def pose(state, k):  # 16×12 cells → color or None
    col, frames = POSES[state]; la, ra, e, m, br = frames[k]
    g = [[None] * 16 for _ in range(12)]
    rows = BODY[1:] if br else BODY   # breathing: one cell shorter (the top comes down)
    for r, line in enumerate(rows):
        for c, ch in enumerate(line):
            if ch == '#': g[r + 1 + br][c + 3] = col
    if e is None:   # no session: outline only
        full = [[bool(x) for x in row] for row in g]
        for r in range(12):
            for c in range(16):
                if full[r][c] and all(0 <= r + dr < 12 and 0 <= c + dc < 16 and full[r + dr][c + dc] for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1))): g[r][c] = None
        return g
    for r, c in EYES[e] + MOUTH[m]: g[r][c] = None
    for r, c in EYES[e]: g[r][15 - c] = None
    for r, c in ARM[la]: g[r][c] = col
    for r, c in ARM[ra]: g[r][15 - c] = col
    return g
for st, (_, frames) in POSES.items():
    for k in range(len(frames)):
        g = [[None] * 66 for _ in range(66)]
        for r, row in enumerate(pose(st, k)):
            for c, col in enumerate(row):
                if col:
                    for yy in range(15 + r * 3, 18 + r * 3):
                        for xx in range(9 + c * 3, 12 + c * 3): g[yy][xx] = col
        png_px(f'{out}/pilo_{st}_{k + 1}.png', [[g[y][x] if inside_px(x, y) else None for x in range(66)] for y in range(66)])
    for k in range(len(frames)): png(f'{out}/pilo_s_{st}_{k + 1}.png', pose(st, k))   # popup rows move with the same frames
