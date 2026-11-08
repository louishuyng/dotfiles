import AppKit

// MARK: - Themes

func hex(_ v: UInt32, _ a: CGFloat = 1) -> NSColor {
  NSColor(
    srgbRed: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255,
    blue: CGFloat(v & 0xff) / 255, alpha: a)
}

struct Theme {
  let name: String
  let dark: Bool
  let bg: NSColor
  let text: NSColor
  let muted: NSColor
  let accent: NSColor

  init(_ name: String, dark: Bool, bg: UInt32, text: UInt32, muted: UInt32, accent: UInt32) {
    self.init(name, dark: dark, bg: hex(bg), text: hex(text), muted: hex(muted), accent: hex(accent))
  }
  init(_ name: String, dark: Bool, bg: NSColor, text: NSColor, muted: NSColor, accent: NSColor) {
    (self.name, self.dark, self.bg, self.text, self.muted, self.accent) = (name, dark, bg, text, muted, accent)
  }

  static let auto = "Auto (System)"
  static let all: [Theme] = [
    Theme("Catppuccin Mocha", dark: true, bg: 0x1e1e2e, text: 0xcdd6f4, muted: 0x6c7086, accent: 0xcba6f7),
    Theme("Catppuccin Latte", dark: false, bg: 0xeff1f5, text: 0x4c4f69, muted: 0x9ca0b0, accent: 0x8839ef),
    Theme("Tokyo Night", dark: true, bg: 0x1a1b26, text: 0xc0caf5, muted: 0x565f89, accent: 0x7aa2f7),
    Theme("Gruvbox Dark", dark: true, bg: 0x282828, text: 0xebdbb2, muted: 0x928374, accent: 0xfabd2f),
    Theme("Nord", dark: true, bg: 0x2e3440, text: 0xeceff4, muted: 0x616e88, accent: 0x88c0d0),
    Theme("Dracula", dark: true, bg: 0x282a36, text: 0xf8f8f2, muted: 0x6272a4, accent: 0xbd93f9),
    Theme("Rosé Pine", dark: true, bg: 0x191724, text: 0xe0def4, muted: 0x6e6a86, accent: 0xebbcba),
    Theme("Solarized Light", dark: false, bg: 0xfdf6e3, text: 0x586e75, muted: 0x93a1a1, accent: 0xb58900),
    Theme("Phosphor", dark: true, bg: 0x0b0e0d, text: 0xc6d0f5, muted: 0x696a6d, accent: 0x00ff41),
  ]

  /// Resolves a saved theme name; "Auto" follows the current system appearance.
  static func named(_ name: String) -> Theme {
    if let t = all.first(where: { $0.name == name }) { return t }
    let dark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    return dark
      ? Theme(auto, dark: true, bg: hex(0x1c1c1e), text: hex(0xf2f2f7), muted: hex(0x8e8e93), accent: .controlAccentColor)
      : Theme(auto, dark: false, bg: hex(0xf6f6f8), text: hex(0x1d1d1f), muted: hex(0x8e8e93), accent: .controlAccentColor)
  }

  var swatch: NSImage {
    NSImage(size: NSSize(width: 28, height: 28), flipped: false) { r in
      self.bg.setFill()
      let box = NSBezierPath(roundedRect: r.insetBy(dx: 1, dy: 1), xRadius: 6, yRadius: 6)
      box.fill()
      self.muted.withAlphaComponent(0.6).setStroke()
      box.stroke()
      self.accent.setFill()
      NSBezierPath(ovalIn: NSRect(x: 5, y: 9, width: 10, height: 10)).fill()
      self.text.setFill()
      NSBezierPath(ovalIn: NSRect(x: 14, y: 9, width: 10, height: 10)).fill()
      return true
    }
  }
}

func font(_ size: CGFloat, bold: Bool = false) -> NSFont {
  for name in ["JetBrainsMono Nerd Font", "JetBrainsMonoNL Nerd Font", "JetBrains Mono"] {
    if let f = NSFont(name: name, size: size) {
      return bold ? NSFontManager.shared.convert(f, toHaveTrait: .boldFontMask) : f
    }
  }
  return .monospacedSystemFont(ofSize: size, weight: bold ? .semibold : .regular)
}

// MARK: - Model

struct AppEntry {
  let name: String
  let url: URL
}

/// Greedy subsequence match (shortcut: first hit wins, not best alignment; fine for app names).
func fuzzyMatch(_ query: String, _ text: String) -> (score: Int, hits: [Int])? {
  let q = query.lowercased().filter { $0 != " " }.map { String($0) }
  if q.isEmpty { return (0, []) }
  let t = text.map { String($0).lowercased() }
  var qi = 0, score = 0, last = -2
  var hits: [Int] = []
  for i in t.indices where qi < q.count && t[i] == q[qi] {
    score += 1
    if i == last + 1 { score += 5 }
    if i == 0 || [" ", "-", ".", "_"].contains(t[i - 1]) { score += 8 }
    hits.append(i)
    last = i
    qi += 1
  }
  guard qi == q.count else { return nil }
  return (score * 10 - t.count, hits)
}

func scanApplications() -> [AppEntry] {
  let fm = FileManager.default
  let roots = [
    "/Applications", "/System/Applications", "/System/Applications/Utilities",
    NSHomeDirectory() + "/Applications",
  ]
  var seen = Set<String>()
  var out: [AppEntry] = []

  func add(_ url: URL) {
    let path = url.resolvingSymlinksInPath().path
    guard path != Bundle.main.bundleURL.path, seen.insert(path).inserted else { return }
    out.append(AppEntry(name: fm.displayName(atPath: path).replacingOccurrences(of: ".app", with: ""), url: url))
  }

  // Two levels deep catches /Applications/Utilities, Setapp, Home Manager Apps, etc.
  for root in roots {
    guard let items = try? fm.contentsOfDirectory(atPath: root) else { continue }
    for item in items where !item.hasPrefix(".") {
      let url = URL(fileURLWithPath: root).appendingPathComponent(item)
      if item.hasSuffix(".app") { add(url); continue }
      guard let sub = try? fm.contentsOfDirectory(atPath: url.resolvingSymlinksInPath().path) else { continue }
      for s in sub where s.hasSuffix(".app") { add(url.appendingPathComponent(s)) }
    }
  }
  add(URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app"))

  for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
    if let url = app.bundleURL { add(url) }
  }
  return out
}

// MARK: - Views

final class Panel: NSPanel {
  var onKey: ((String) -> Void)?
  override var canBecomeKey: Bool { true }

  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
      let c = event.charactersIgnoringModifiers, c == "," || ("1"..."9").contains(c)
    {
      onKey?(c)
      return true
    }
    return super.performKeyEquivalent(with: event)
  }
}

final class RowView: NSTableRowView {
  override func drawSelection(in dirtyRect: NSRect) {}  // selection is shown by the accent text colour
}

final class Cell: NSTableCellView {
  let icon = NSImageView()
  let name = NSTextField(labelWithString: "")
  let mark = NSTextField(labelWithString: "")

  init() {
    super.init(frame: .zero)
    for v in [icon, name, mark] as [NSView] {
      v.translatesAutoresizingMaskIntoConstraints = false
      addSubview(v)
    }
    imageView = icon
    textField = name
    name.lineBreakMode = .byTruncatingTail
    mark.setContentCompressionResistancePriority(.required, for: .horizontal)
    NSLayoutConstraint.activate([
      icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36),
      icon.centerYAnchor.constraint(equalTo: centerYAnchor),
      icon.widthAnchor.constraint(equalToConstant: 28),
      icon.heightAnchor.constraint(equalToConstant: 28),
      name.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 22),
      name.centerYAnchor.constraint(equalTo: centerYAnchor),
      mark.leadingAnchor.constraint(greaterThanOrEqualTo: name.trailingAnchor, constant: 8),
      mark.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36),
      mark.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }
  required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Controller

final class Switcher: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate,
  NSTextFieldDelegate, NSWindowDelegate
{
  enum Mode { case apps, themes }
  struct Row {
    let title: String
    let hits: [Int]
    let app: AppEntry?
    let theme: Theme?
  }

  let panel = Panel(
    contentRect: NSRect(x: 0, y: 0, width: 560, height: 520), styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered, defer: false)
  let root = NSView()
  let search = NSTextField()
  let table = NSTableView()
  let noMatch = NSTextField(labelWithString: "No matches")

  var mode = Mode.apps
  var apps: [AppEntry] = []
  var rows: [Row] = []
  var mru: [String] = []  // bundle paths, most recently activated first
  var icons: [String: NSImage] = [:]

  var savedTheme: String {
    get { UserDefaults.standard.string(forKey: "theme") ?? Theme.auto }
    set { UserDefaults.standard.set(newValue, forKey: "theme") }
  }
  var theme = Theme.all[0]

  func applicationDidFinishLaunching(_ note: Notification) {
    buildUI()
    if let front = NSWorkspace.shared.frontmostApplication?.bundleURL?.path { mru.append(front) }
    for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
      if let p = app.bundleURL?.path, !mru.contains(p) { mru.append(p) }
    }
    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
    ) { [weak self] note in
      guard let self, let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
        let p = app.bundleURL?.path, p != Bundle.main.bundleURL.path
      else { return }
      self.mru.removeAll { $0 == p }
      self.mru.insert(p, at: 0)
    }
    show()
  }

  // `open -a AppSwitcher` on a running instance lands here — that's the toggle.
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
    panel.isVisible ? hide() : show()
    return false
  }

  func buildUI() {
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.level = .popUpMenu
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    panel.hidesOnDeactivate = false
    panel.delegate = self
    panel.onKey = { [weak self] key in
      guard let self else { return }
      if key == "," { self.setMode(self.mode == .themes ? .apps : .themes); return }
      if let i = Int(key), self.mode == .apps, i - 1 < self.rows.count { self.activate(self.rows[i - 1]) }
    }

    root.wantsLayer = true
    root.layer?.cornerRadius = 4
    root.layer?.borderWidth = 1.5
    panel.contentView = root

    search.isBordered = false
    search.drawsBackground = false
    search.focusRingType = .none
    search.font = font(17)
    search.delegate = self
    search.cell?.isScrollable = true
    search.setAccessibilityLabel("Search")

    table.addTableColumn(NSTableColumn(identifier: .init("main")))
    table.headerView = nil
    table.backgroundColor = .clear
    table.rowHeight = 50
    table.intercellSpacing = .zero
    table.style = .plain
    table.dataSource = self
    table.delegate = self
    table.target = self
    table.action = #selector(clicked)
    table.refusesFirstResponder = true

    let scroll = NSScrollView()
    scroll.documentView = table
    scroll.drawsBackground = false
    scroll.hasVerticalScroller = true
    scroll.scrollerStyle = .overlay

    noMatch.font = font(14)
    for v in [search, scroll, noMatch] as [NSView] {
      v.translatesAutoresizingMaskIntoConstraints = false
      root.addSubview(v)
    }
    NSLayoutConstraint.activate([
      search.topAnchor.constraint(equalTo: root.topAnchor, constant: 30),
      search.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 36),
      search.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -36),
      scroll.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 18),
      scroll.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      scroll.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -14),
      noMatch.leadingAnchor.constraint(equalTo: search.leadingAnchor),
      noMatch.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 14),
    ])
  }

  func applyTheme(_ t: Theme) {
    theme = t
    panel.appearance = NSAppearance(named: t.dark ? .darkAqua : .aqua)
    root.layer?.backgroundColor = t.bg.withAlphaComponent(0.96).cgColor
    root.layer?.borderColor = t.text.withAlphaComponent(0.55).cgColor
    search.textColor = t.text
    noMatch.textColor = t.muted
    (search.currentEditor() as? NSTextView)?.insertionPointColor = t.accent
    let placeholder = mode == .apps ? "Apps…" : "Themes…"
    search.placeholderAttributedString = NSAttributedString(
      string: placeholder, attributes: [.foregroundColor: t.muted, .font: font(17)])
    table.reloadData()
  }

  // MARK: Show / hide

  func show() {
    apps = scanApplications()
    mode = .apps
    search.stringValue = ""
    applyTheme(Theme.named(savedTheme))
    refilter()

    let screen = NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) } ?? NSScreen.main!
    let f = screen.visibleFrame
    let size = panel.frame.size
    let origin = NSPoint(x: f.midX - size.width / 2, y: f.minY + f.height * 0.6 - size.height / 2)
    let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion

    panel.setFrameOrigin(reduceMotion ? origin : NSPoint(x: origin.x, y: origin.y + 8))
    panel.alphaValue = reduceMotion ? 1 : 0
    NSApp.activate(ignoringOtherApps: true)
    panel.makeKeyAndOrderFront(nil)
    panel.makeFirstResponder(search)
    (search.currentEditor() as? NSTextView)?.insertionPointColor = theme.accent
    guard !reduceMotion else { return }
    NSAnimationContext.runAnimationGroup { ctx in
      ctx.duration = 0.12
      ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
      panel.animator().alphaValue = 1
      panel.animator().setFrameOrigin(origin)
    }
  }

  func hide() {
    panel.orderOut(nil)
    // Hand focus back to whatever was frontmost; a launch activates its own target anyway.
    if NSApp.isActive { NSApp.hide(nil) }
  }

  func windowDidResignKey(_ notification: Notification) { hide() }

  func setMode(_ m: Mode) {
    mode = m
    search.stringValue = ""
    applyTheme(Theme.named(savedTheme))
    refilter()
  }

  // MARK: Filtering

  func refilter() {
    let q = search.stringValue
    let empty = q.trimmingCharacters(in: .whitespaces).isEmpty

    if mode == .themes {
      let names = [Theme.auto] + Theme.all.map(\.name)
      rows = names.compactMap { n in
        guard let m = fuzzyMatch(q, n) else { return nil }
        return Row(title: n, hits: m.hits, app: nil, theme: Theme.named(n))
      }
      table.reloadData()
      select(empty ? names.firstIndex(of: savedTheme) ?? 0 : 0)
      return
    }

    let rank = Dictionary(mru.enumerated().map { ($1, $0) }, uniquingKeysWith: { a, _ in a })
    func mruRank(_ a: AppEntry) -> Int { rank[a.url.path] ?? Int.max }

    if empty {
      rows = apps.sorted {
        let (ra, rb) = (mruRank($0), mruRank($1))
        return ra != rb ? ra < rb : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
      }.map { Row(title: $0.name, hits: [], app: $0, theme: nil) }
    } else {
      rows = apps.compactMap { app -> (Row, Int)? in
        guard let m = fuzzyMatch(q, app.name) else { return nil }
        return (Row(title: app.name, hits: m.hits, app: app, theme: nil), m.score + (rank[app.url.path] != nil ? 15 : 0))
      }.sorted { $0.1 > $1.1 }.map(\.0)
    }

    table.reloadData()
    // Empty query starts on the previous app, so ⌘⌘ ↵ flips back like alt-tab.
    let front = NSWorkspace.shared.frontmostApplication?.bundleURL?.path
    select(empty && rows.count > 1 && rows[0].app?.url.path == front ? 1 : 0)
  }

  func select(_ i: Int) {
    noMatch.isHidden = !rows.isEmpty
    guard !rows.isEmpty else { return }
    let i = max(0, min(rows.count - 1, i))
    let old = table.selectedRow
    table.selectRowIndexes([i], byExtendingSelection: false)
    table.scrollRowToVisible(i)
    table.reloadData(forRowIndexes: IndexSet([old, i].filter { $0 >= 0 && $0 < rows.count }), columnIndexes: [0])
    if mode == .themes, let t = rows[i].theme { applyTheme(t) }  // live preview
  }

  func controlTextDidChange(_ obj: Notification) { refilter() }

  func control(_ control: NSControl, textView: NSTextView, doCommandBy sel: Selector) -> Bool {
    switch sel {
    case #selector(NSResponder.moveUp(_:)): select(table.selectedRow - 1)
    case #selector(NSResponder.moveDown(_:)): select(table.selectedRow + 1)
    case #selector(NSResponder.insertNewline(_:)):
      if table.selectedRow >= 0 { activate(rows[table.selectedRow]) }
    case #selector(NSResponder.cancelOperation(_:)):
      mode == .themes ? setMode(.apps) : hide()
    default: return false
    }
    return true
  }

  @objc func clicked() {
    if table.clickedRow >= 0 { activate(rows[table.clickedRow]) }
  }

  func activate(_ row: Row) {
    if row.theme != nil {
      savedTheme = row.title
      setMode(.apps)
      return
    }
    guard let app = row.app else { return }
    hide()
    let cfg = NSWorkspace.OpenConfiguration()
    cfg.activates = true
    NSWorkspace.shared.openApplication(at: app.url, configuration: cfg) { _, err in
      if let err { NSLog("AppSwitcher: failed to open \(app.url.path): \(err)") }
    }
  }

  // MARK: Table

  func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? { RowView() }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cell = tableView.makeView(withIdentifier: .init("cell"), owner: nil) as? Cell ?? Cell()
    cell.identifier = .init("cell")
    let r = rows[row]
    let selected = row == tableView.selectedRow

    if let app = r.app {
      let path = app.url.path
      if icons[path] == nil {
        let img = NSWorkspace.shared.icon(forFile: path)
        img.size = NSSize(width: 28, height: 28)
        icons[path] = img
      }
      cell.icon.image = icons[path]
    } else {
      cell.icon.image = r.theme?.swatch
    }

    let hitSet = Set(r.hits)
    let base = selected ? theme.accent : theme.text
    let title = NSMutableAttributedString()
    for (i, ch) in r.title.enumerated() {
      let hit = hitSet.contains(i)
      title.append(
        NSAttributedString(
          string: String(ch),
          attributes: [.font: font(15, bold: hit), .foregroundColor: hit && !selected ? theme.accent : base]))
    }
    cell.name.attributedStringValue = title
    cell.setAccessibilityLabel(r.title)

    let isCurrentTheme = r.theme != nil && r.title == savedTheme
    cell.mark.attributedStringValue = NSAttributedString(
      string: isCurrentTheme ? "✓" : "",
      attributes: [.font: font(15, bold: true), .foregroundColor: isCurrentTheme ? theme.accent : theme.muted])
    return cell
  }
}

// MARK: - Entry

if CommandLine.arguments.contains("--selftest") {
  assert(fuzzyMatch("", "Safari")?.score == 0)
  assert(fuzzyMatch("sfr", "Safari")?.hits == [0, 2, 4])
  assert(fuzzyMatch("xyz", "Safari") == nil)
  assert(fuzzyMatch("VS", "Visual Studio Code")?.hits == [0, 2])  // greedy, not optimal
  assert(fuzzyMatch("gh", "Ghostty")!.score > fuzzyMatch("gh", "Google Chrome")?.score ?? Int.min)
  assert(Set(Theme.all.map(\.name)).count == Theme.all.count)
  print("selftest ok")
  exit(0)
}

let app = NSApplication.shared
let delegate = Switcher()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
