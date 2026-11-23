// 8x8 pixel sprites for space avatars. Drawn for Herdr, not taken from any game.
// "." clear, "x" the space's color, "o" white, "k" near-black.
// pixel-spaces and pixel-picker each carry this file (a mod can't import from another
// mod's folder): change both copies together.

export const SPRITES = {
  slime: [
    "........",
    "...xx...",
    "..xxxx..",
    ".xxxxxx.",
    ".xokxok.",
    "xxxxxxxx",
    "xxxxxxxx",
    ".xxxxxx.",
  ],
  ghost: [
    "..xxxx..",
    ".xxxxxx.",
    "xxxxxxxx",
    "xokxxokx",
    "xxxxxxxx",
    "xxxxxxxx",
    "xxxxxxxx",
    "xx.xx.xx",
  ],
  cat: [
    ".x....x.",
    ".xx..xx.",
    ".xxxxxx.",
    "xxoxxoxx",
    "xxxxxxxx",
    "xxxkkxxx",
    ".xxxxxx.",
    "..xxxx..",
  ],
  robot: [
    "...xx...",
    ".xxxxxx.",
    ".xoxxox.",
    ".xxxxxx.",
    ".xkkkkx.",
    ".xxxxxx.",
    "..x..x..",
    ".xx..xx.",
  ],
  mushroom: [
    "..xxxx..",
    ".xoxxox.",
    "xxxxxxxx",
    "xoxxxxox",
    "xxxxxxxx",
    ".oooooo.",
    ".okooko.",
    "..oooo..",
  ],
  octopus: [
    "..xxxx..",
    ".xxxxxx.",
    "xxxxxxxx",
    "xokxxokx",
    "xxxxxxxx",
    ".xxxxxx.",
    "x.x..x.x",
    ".x.xx.x.",
  ],
  skull: [
    ".xxxxxx.",
    "xxxxxxxx",
    "xkkxxkkx",
    "xkkxxkkx",
    "xxxkkxxx",
    ".xxxxxx.",
    ".x.xx.x.",
    ".xxxxxx.",
  ],
  heart: [
    "........",
    ".xx..xx.",
    "xoxxxxxx",
    "xxxxxxxx",
    "xxxxxxxx",
    ".xxxxxx.",
    "..xxxx..",
    "...xx...",
  ],
  potion: [
    "...oo...",
    "...xx...",
    "...xx...",
    "..xxxx..",
    ".xxxxxx.",
    ".xoxxxx.",
    ".xxxxxx.",
    "..xxxx..",
  ],
  frog: [
    ".xx..xx.",
    "xokxxokx",
    "xxxxxxxx",
    "xkxxxxkx",
    "xxkkkkxx",
    "xxxxxxxx",
    ".xxxxxx.",
    "xx....xx",
  ],
  rocket: [
    "...xx...",
    "..xxxx..",
    "..xoox..",
    "..xxxx..",
    ".xxxxxx.",
    "xxxxxxxx",
    "x.xxxx.x",
    "...oo...",
  ],
  terminal: [
    "xxxxxxxx",
    "xkkkkkkx",
    "xokkkkkx",
    "xkokkkkx",
    "xokkookx",
    "xkkkkkkx",
    "xxxxxxxx",
    "..xxxx..",
  ],
  coffee: [
    ".o..o...",
    "..o..o..",
    "xxxxxx..",
    "xxxxxxxx",
    "xxxxxx.x",
    "xxxxxxxx",
    "xxxxxx..",
    ".xxxx...",
  ],
  bomb: [
    "......o.",
    ".....x..",
    "..xxxx..",
    ".xxxxxx.",
    "xoxxxxxx",
    "xxxxxxxx",
    ".xxxxxx.",
    "..xxxx..",
  ],
  star: [
    "...xx...",
    "...xx...",
    "xxxxxxxx",
    ".xxxxxx.",
    "..xxxx..",
    ".xxxxxx.",
    ".xx..xx.",
    ".x....x.",
  ],
};

export const NAMES = Object.keys(SPRITES);

// Each run of one color in a row is one rectangle: [char, length].
function runs(row) {
  const out = [];
  for (let i = 0; i < row.length; ) {
    let j = i;
    while (j < row.length && row[j] === row[i]) j++;
    out.push([row[i], j - i]);
    i = j;
  }
  return out;
}

// `hex` moved `by` of the way to white (by > 0) or black (by < 0).
// Anything but #rrggbb comes back as it is.
export function shade(hex, by) {
  if (!/^#[0-9a-f]{6}$/i.test(hex)) return hex;
  const to = by > 0 ? 255 : 0;
  const k = Math.abs(by);
  const part = (i) => Math.round(parseInt(hex.slice(i, i + 2), 16) * (1 - k) + to * k).toString(16).padStart(2, "0");
  return `#${part(1)}${part(3)}${part(5)}`;
}

// The sprite with a one-pixel margin, every clear pixel that touches the sprite
// turned into "w": the white edge of a die-cut sticker.
function dieCut(rows) {
  const wide = rows[0].length + 2;
  const grid = [".".repeat(wide), ...rows.map((r) => `.${r}.`), ".".repeat(wide)];
  const inked = (y, x) => (grid[y]?.[x] ?? ".") !== ".";
  return grid.map((row, y) => [...row].map((c, x) => {
    if (c !== ".") return c;
    for (let dy = -1; dy <= 1; dy++) for (let dx = -1; dx <= 1; dx++) if (inked(y + dy, x + dx)) return "w";
    return ".";
  }).join(""));
}

const PAPER = "#f6f5ee";
const GLINT = { from: -70, to: 90, period: 5200 }; // mostly off the sticker: a glint, then a rest

// The sprite as a sticker of GPUI rectangles, `px` pixels per sprite pixel: white
// die-cut edge, hard shadow, lit from above. `shine` sweeps a glint across it.
export function sprite(name, fill, { div, v_flex, h_flex }, px = 2, shine = false) {
  const rows = dieCut(SPRITES[name] ?? SPRITES.slime);
  const last = rows.length - 1;
  const layer = (paint) => v_flex().absolute().children(rows.map((row, y) => {
    let x = 0;
    return h_flex().flex_none().h(px).children(runs(row).map(([c, n]) => {
      const cell = paint(div().flex_none().w(px * n).h(px), c, x * px, y);
      x += n;
      return cell;
    }));
  }));
  const ink = (y) => ({ w: PAPER, x: shade(fill, 0.34 - (0.6 * y) / last), o: "#ffffff", k: "#17181c" });
  return div().relative().flex_none().w(px * rows[0].length + 1).h(px * rows.length + 2)
    .child(layer((cell, c) => (c === "." ? cell : cell.bg("#00000080"))).left(1).top(2))
    .child(layer((cell, c, left, y) => {
      if (c === ".") return cell;
      const inked = cell.bg(ink(y)[c]);
      if (!shine || c === "w") return inked;
      // Each cell clips its own piece of one slanted band, so the glint stays on the sticker.
      return inked.relative().overflow_hidden().child(div().absolute().top(0).h(px).w(px * 3).bg("#ffffffb0")
        .loop("left", { ...GLINT, from: GLINT.from - left - y * px, to: GLINT.to - left - y * px }));
    }).left(0).top(0));
}

// A sprite for each space: kept once picked, new spaces get the least used one.
export function assign(spaces, kept) {
  const out = { ...kept };
  let changed = false;
  for (const s of spaces) {
    if (out[s.id] && NAMES.includes(out[s.id])) continue;
    const uses = (n) => Object.values(out).filter((v) => v === n).length;
    const least = Math.min(...NAMES.map(uses));
    const free = NAMES.filter((n) => uses(n) === least);
    let h = 0;
    for (const ch of s.name ?? s.id) h = (h * 31 + ch.charCodeAt(0)) >>> 0;
    out[s.id] = free[h % free.length];
    changed = true;
  }
  return { out, changed };
}
