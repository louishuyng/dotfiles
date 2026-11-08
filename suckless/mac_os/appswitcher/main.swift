import AppKit

// MARK: - Themes

func hex(_ v: UInt32, _ a: CGFloat = 1) -> NSColor {
  NSColor(
    srgbRed: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255,
    blue: CGFloat(v & 0xff) / 255, alpha: a)
}

/// A resolved palette for one appearance.
struct Theme {
  let dark: Bool
  let bg: NSColor
  let text: NSColor
  let muted: NSColor
  let accent: NSColor

  init(dark: Bool, bg: NSColor, text: NSColor, muted: NSColor, accent: NSColor) {
    (self.dark, self.bg, self.text, self.muted, self.accent) = (dark, bg, text, muted, accent)
  }
  init(dark: Bool, _ bg: UInt32, _ text: UInt32, _ muted: UInt32, _ accent: UInt32) {
    self.init(dark: dark, bg: hex(bg), text: hex(text), muted: hex(muted), accent: hex(accent))
  }
}

/// A theme family ships both appearances; which one shows depends on `Appearance`.
struct Family {
  let name: String
  let dark: Theme
  let light: Theme

  // Palettes: bg, text, muted, accent.
  static let all: [Family] = [
    Family(
      name: "System",
      dark: Theme(dark: true, bg: hex(0x1c1c1e), text: hex(0xf2f2f7), muted: hex(0x8e8e93), accent: .controlAccentColor),
      light: Theme(dark: false, bg: hex(0xf6f6f8), text: hex(0x1d1d1f), muted: hex(0x8e8e93), accent: .controlAccentColor)),
    Family(
      name: "Catppuccin", dark: Theme(dark: true, 0x1e1e2e, 0xcdd6f4, 0x6c7086, 0xcba6f7),
      light: Theme(dark: false, 0xeff1f5, 0x4c4f69, 0x9ca0b0, 0x8839ef)),
    Family(
      name: "Tokyo Night", dark: Theme(dark: true, 0x1a1b26, 0xc0caf5, 0x565f89, 0x7aa2f7),
      light: Theme(dark: false, 0xe1e2e7, 0x3760bf, 0x8990b3, 0x2e7de9)),
    Family(
      name: "Gruvbox", dark: Theme(dark: true, 0x282828, 0xebdbb2, 0x928374, 0xfabd2f),
      light: Theme(dark: false, 0xfbf1c7, 0x3c3836, 0x928374, 0xb57614)),
    Family(
      name: "Nord", dark: Theme(dark: true, 0x2e3440, 0xeceff4, 0x616e88, 0x88c0d0),
      light: Theme(dark: false, 0xeceff4, 0x2e3440, 0x7b88a1, 0x5e81ac)),
    Family(
      name: "Dracula", dark: Theme(dark: true, 0x282a36, 0xf8f8f2, 0x6272a4, 0xbd93f9),
      light: Theme(dark: false, 0xfffbeb, 0x1f1f1f, 0x6c664b, 0x644ac9)),
    Family(
      name: "Rosé Pine", dark: Theme(dark: true, 0x191724, 0xe0def4, 0x6e6a86, 0xebbcba),
      light: Theme(dark: false, 0xfaf4ed, 0x575279, 0x9893a5, 0xd7827e)),
    Family(
      name: "Solarized", dark: Theme(dark: true, 0x002b36, 0x93a1a1, 0x586e75, 0xb58900),
      light: Theme(dark: false, 0xfdf6e3, 0x586e75, 0x93a1a1, 0xb58900)),
    Family(
      name: "One", dark: Theme(dark: true, 0x282c34, 0xabb2bf, 0x5c6370, 0x61afef),
      light: Theme(dark: false, 0xfafafa, 0x383a42, 0xa0a1a7, 0x4078f2)),
    Family(
      name: "Everforest", dark: Theme(dark: true, 0x2d353b, 0xd3c6aa, 0x859289, 0xa7c080),
      light: Theme(dark: false, 0xfdf6e3, 0x5c6a72, 0x939f91, 0x8da101)),
    Family(
      name: "Kanagawa", dark: Theme(dark: true, 0x1f1f28, 0xdcd7ba, 0x727169, 0x7e9cd8),
      light: Theme(dark: false, 0xf2ecbc, 0x545464, 0x8a8980, 0x4d699b)),
    Family(
      name: "GitHub", dark: Theme(dark: true, 0x0d1117, 0xe6edf3, 0x7d8590, 0x2f81f7),
      light: Theme(dark: false, 0xffffff, 0x1f2328, 0x656d76, 0x0969da)),
    Family(
      name: "Ayu", dark: Theme(dark: true, 0x0b0e14, 0xbfbdb6, 0x565b66, 0xe6b450),
      light: Theme(dark: false, 0xfcfcfc, 0x5c6166, 0x8a9199, 0xfa8d3e)),
    Family(
      name: "Phosphor", dark: Theme(dark: true, 0x0b0e0d, 0xc6d0f5, 0x696a6d, 0x00ff41),
      light: Theme(dark: false, 0xf2f7f2, 0x1b2a1f, 0x6b7a6e, 0x008f2a)),
  ]

  static func named(_ name: String) -> Family { all.first { $0.name == name } ?? all[0] }

  /// Left half dark palette, right half light palette.
  var swatch: NSImage {
    NSImage(size: NSSize(width: 28, height: 28), flipped: false) { r in
      let box = NSBezierPath(roundedRect: r.insetBy(dx: 1, dy: 1), xRadius: 6, yRadius: 6)
      NSGraphicsContext.saveGraphicsState()
      box.addClip()
      for (t, x) in [(self.dark, r.minX), (self.light, r.midX)] {
        t.bg.setFill()
        NSRect(x: x, y: r.minY, width: r.width / 2, height: r.height).fill()
        t.accent.setFill()
        NSBezierPath(ovalIn: NSRect(x: x + 3, y: r.midY - 4, width: 8, height: 8)).fill()
      }
      NSGraphicsContext.restoreGraphicsState()
      self.dark.muted.withAlphaComponent(0.6).setStroke()
      box.stroke()
      return true
    }
  }
}

enum Appearance: String, CaseIterable {
  case auto, dark, light

  var next: Appearance { Self.allCases[(Self.allCases.firstIndex(of: self)! + 1) % Self.allCases.count] }

  func pick(_ f: Family) -> Theme {
    switch self {
    case .dark: return f.dark
    case .light: return f.light
    case .auto: return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? f.dark : f.light
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

/// Panel background that drags the panel itself, so the controller can snap and draw guides.
final class DragView: NSView {
  var onBegan: (() -> Void)?
  var onMoved: ((NSPoint) -> Void)?
  var onEnded: (() -> Void)?
  private var start = NSPoint.zero

  override var mouseDownCanMoveWindow: Bool { false }
  override func mouseDown(with event: NSEvent) {
    start = NSEvent.mouseLocation
    onBegan?()
  }
  override func mouseDragged(with event: NSEvent) {
    let m = NSEvent.mouseLocation
    onMoved?(NSPoint(x: m.x - start.x, y: m.y - start.y))
  }
  override func mouseUp(with event: NSEvent) { onEnded?() }
}

/// Dotted lines through the screen centre, shown while dragging; solid accent when snapped.
final class GuideView: NSView {
  var snapX = false
  var snapY = false
  var color = NSColor.gray
  var accent = NSColor.systemBlue

  override func draw(_ dirtyRect: NSRect) {
    for (vertical, snapped) in [(true, snapX), (false, snapY)] {
      let p = NSBezierPath()
      p.move(to: vertical ? NSPoint(x: bounds.midX, y: 0) : NSPoint(x: 0, y: bounds.midY))
      p.line(to: vertical ? NSPoint(x: bounds.midX, y: bounds.maxY) : NSPoint(x: bounds.maxX, y: bounds.midY))
      p.lineWidth = 2.5
      p.lineCapStyle = .round
      p.setLineDash([0, 9], count: 2, phase: 0)  // zero-length dashes + round caps = dots
      (snapped ? accent : color.withAlphaComponent(0.6)).setStroke()
      p.stroke()
    }
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

final class HeaderCell: NSTableCellView {
  let label = NSTextField(labelWithString: "")

  init() {
    super.init(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
    ])
  }
  required init?(coder: NSCoder) { fatalError() }
}

final class ActionRow: NSView {
  var index = 0
}

// MARK: - Controller

final class Switcher: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate,
  NSTextFieldDelegate, NSWindowDelegate
{
  enum Mode { case apps, themes }
  struct Row {
    var title: String
    var hits: [Int] = []
    var app: AppEntry? = nil
    var family: Family? = nil
    var header = false
  }
  struct Action {
    let title: String
    let symbol: String
    let run: () -> Void
  }

  let panel = Panel(
    contentRect: NSRect(x: 0, y: 0, width: 560, height: 520), styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered, defer: false)
  let root = DragView()
  var glassView: NSView?
  let guideView = GuideView()
  let guides = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
  var dragOrigin = NSPoint.zero
  let search = NSTextField()
  let table = NSTableView()
  let noMatch = NSTextField(labelWithString: "No matches")
  let appearanceHint = NSTextField(labelWithString: "")
  let actionsBox = NSView()
  let actionsStack = NSStackView()
  var actions: [Action] = []
  var actionsTitle = ""
  var actionIndex = 0
  var trashArmed = false
  var actionsOpen: Bool { !actionsBox.isHidden }
  var keyMonitor: Any?

  var mode = Mode.apps
  var apps: [AppEntry] = []
  var rows: [Row] = []
  var mru: [String] = []  // bundle paths, most recently activated first
  var icons: [String: NSImage] = [:]

  var savedFamily: String {
    get { UserDefaults.standard.string(forKey: "family") ?? Family.all[0].name }
    set { UserDefaults.standard.set(newValue, forKey: "family") }
  }
  var appearance: Appearance {
    get { Appearance(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "") ?? .auto }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: "appearance") }
  }
  var pins: [String] {
    get { UserDefaults.standard.stringArray(forKey: "pins") ?? [] }
    set { UserDefaults.standard.set(newValue, forKey: "pins") }
  }
  var theme = Family.all[0].dark
  var appearanceObservation: NSKeyValueObservation?
  var savedTheme: Theme { appearance.pick(Family.named(savedFamily)) }

  func applicationDidFinishLaunching(_ note: Notification) {
    buildUI()
    // Follow macOS light/dark switches while the panel is open.
    appearanceObservation = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
      DispatchQueue.main.async { self?.refreshTheme() }
    }
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
    // ⌃j/⌃k and ⌘k never reach the field editor as commands, so catch them before dispatch.
    keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
      guard let self, self.panel.isKeyWindow else { return e }
      let flags = e.modifierFlags.intersection(.deviceIndependentFlagsMask)
      let c = e.charactersIgnoringModifiers ?? ""
      if flags == .control, c == "j" || c == "k" {
        self.move(c == "j" ? 1 : -1)
        return nil
      }
      if flags == .command, c == "k" {
        self.actionsOpen ? self.closeActions() : self.openActions()
        return nil
      }
      return e
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
      let items = self.rows.filter { !$0.header }
      if let i = Int(key), self.mode == .apps, i - 1 < items.count { self.activate(items[i - 1]) }
    }

    root.wantsLayer = true
    root.layer?.cornerRadius = 18
    root.frame = panel.contentLayoutRect
    root.autoresizingMask = [.width, .height]
    if #available(macOS 26, *) {
      let glass = NSGlassEffectView()
      glass.cornerRadius = 18
      glass.style = .clear
      glass.contentView = root
      panel.contentView = glass
      glassView = glass
    } else {
      let blur = NSVisualEffectView()
      blur.material = .hudWindow
      blur.blendingMode = .behindWindow
      blur.state = .active
      blur.wantsLayer = true
      blur.layer?.cornerRadius = 18
      blur.layer?.masksToBounds = true
      blur.addSubview(root)
      panel.contentView = blur
    }
    root.onBegan = { [weak self] in self?.dragBegan() }
    root.onMoved = { [weak self] d in self?.dragMoved(d) }
    root.onEnded = { [weak self] in self?.dragEnded() }

    guides.isOpaque = false
    guides.backgroundColor = .clear
    guides.ignoresMouseEvents = true
    guides.level = .statusBar
    guides.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    guides.contentView = guideView

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
    appearanceHint.font = font(12)
    actionsBox.wantsLayer = true
    actionsBox.layer?.cornerRadius = 12
    actionsBox.layer?.borderWidth = 1
    actionsBox.shadow = NSShadow()
    actionsBox.layer?.shadowOpacity = 0.35
    actionsBox.layer?.shadowRadius = 16
    actionsBox.layer?.shadowOffset = CGSize(width: 0, height: -4)
    actionsBox.isHidden = true
    actionsStack.orientation = .vertical
    actionsStack.alignment = .leading
    actionsStack.spacing = 2
    actionsStack.edgeInsets = NSEdgeInsets(top: 10, left: 6, bottom: 6, right: 6)
    actionsStack.translatesAutoresizingMaskIntoConstraints = false
    actionsBox.addSubview(actionsStack)

    for v in [search, scroll, noMatch, appearanceHint, actionsBox] as [NSView] {
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
      appearanceHint.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -36),
      appearanceHint.centerYAnchor.constraint(equalTo: search.centerYAnchor),
      actionsBox.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -20),
      actionsBox.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -20),
      actionsBox.widthAnchor.constraint(equalToConstant: 300),
      actionsStack.topAnchor.constraint(equalTo: actionsBox.topAnchor),
      actionsStack.bottomAnchor.constraint(equalTo: actionsBox.bottomAnchor),
      actionsStack.leadingAnchor.constraint(equalTo: actionsBox.leadingAnchor),
      actionsStack.trailingAnchor.constraint(equalTo: actionsBox.trailingAnchor),
    ])
  }

  func applyTheme(_ t: Theme) {
    theme = t
    panel.appearance = NSAppearance(named: t.dark ? .darkAqua : .aqua)
    // Theme tints the glass instead of painting over it, so the desktop still shows through.
    // 0.7, not lighter: clear glass takes on what is behind it, and over a white page a weak tint left dark-theme labels unreadable.
    if #available(macOS 26, *), let glass = glassView as? NSGlassEffectView {
      glass.tintColor = t.bg.withAlphaComponent(0.7)
      root.layer?.backgroundColor = nil
    } else {
      root.layer?.backgroundColor = t.bg.withAlphaComponent(0.45).cgColor
    }
    search.textColor = t.text
    noMatch.textColor = t.muted
    appearanceHint.isHidden = mode != .themes
    appearanceHint.attributedStringValue = NSAttributedString(
      string: "\(appearance.rawValue)  ⇥",
      attributes: [.font: font(12), .foregroundColor: t.muted])
    (search.currentEditor() as? NSTextView)?.insertionPointColor = t.accent
    let placeholder = mode == .apps ? "Apps…" : "Themes…"
    search.placeholderAttributedString = NSAttributedString(
      string: placeholder, attributes: [.foregroundColor: t.muted, .font: font(17)])
    actionsBox.layer?.backgroundColor = t.bg.withAlphaComponent(0.97).cgColor
    actionsBox.layer?.borderColor = t.muted.withAlphaComponent(0.35).cgColor
    if actionsOpen { renderActions() }
    table.reloadData()
  }

  // MARK: Show / hide

  func show() {
    apps = scanApplications()
    mode = .apps
    search.stringValue = ""
    applyTheme(savedTheme)
    refilter()

    let screen = NSScreen.screens.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) } ?? NSScreen.main!
    let origin = savedOrigin(on: screen)
    let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion

    panel.setFrameOrigin(reduceMotion ? origin : NSPoint(x: origin.x, y: origin.y + 8))
    panel.alphaValue = reduceMotion ? 1 : 0
    NSApp.activate(ignoringOtherApps: true)
    panel.makeKeyAndOrderFront(nil)
    panel.makeFirstResponder(search)
    // Selecting before the first layout scrolls against a zero-height clip view; start from the top instead.
    root.layoutSubtreeIfNeeded()
    table.scroll(.zero)
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
    closeActions()
    guides.orderOut(nil)
    panel.orderOut(nil)
    // Hand focus back to whatever was frontmost; a launch activates its own target anyway.
    if NSApp.isActive { NSApp.hide(nil) }
  }

  func windowDidResignKey(_ notification: Notification) { hide() }

  // MARK: Position

  /// Saved as the panel centre in fractions of the screen, so it carries across displays of any size.
  func savedOrigin(on screen: NSScreen) -> NSPoint {
    let d = UserDefaults.standard
    let fx = d.object(forKey: "centerX") as? Double ?? 0.5
    let fy = d.object(forKey: "centerY") as? Double ?? 0.58
    let f = screen.frame
    let v = screen.visibleFrame
    let size = panel.frame.size
    let x = f.minX + f.width * fx - size.width / 2
    let y = f.minY + f.height * fy - size.height / 2
    return NSPoint(
      x: min(max(x, v.minX), v.maxX - size.width), y: min(max(y, v.minY), v.maxY - size.height))
  }

  func dragBegan() {
    dragOrigin = panel.frame.origin
    guideView.color = theme.muted
    guideView.accent = theme.accent
  }

  func dragMoved(_ delta: NSPoint) {
    guard let screen = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
    else { return }
    let f = screen.frame
    let size = panel.frame.size
    var o = NSPoint(x: dragOrigin.x + delta.x, y: dragOrigin.y + delta.y)
    let dx = o.x + size.width / 2 - f.midX
    let dy = o.y + size.height / 2 - f.midY
    let snap: CGFloat = 14
    guideView.snapX = abs(dx) < snap
    guideView.snapY = abs(dy) < snap
    if guideView.snapX { o.x -= dx }
    if guideView.snapY { o.y -= dy }
    panel.setFrameOrigin(o)

    if guides.frame != f { guides.setFrame(f, display: false) }
    guideView.needsDisplay = true
    if !guides.isVisible { guides.orderFront(nil) }
  }

  func dragEnded() {
    guides.orderOut(nil)
    guard let screen = panel.screen else { return }
    let f = screen.frame
    UserDefaults.standard.set(Double((panel.frame.midX - f.minX) / f.width), forKey: "centerX")
    UserDefaults.standard.set(Double((panel.frame.midY - f.minY) / f.height), forKey: "centerY")
  }

  func refreshTheme() {
    guard panel.isVisible else { return }
    if mode == .themes { select(table.selectedRow) } else { applyTheme(savedTheme) }
  }

  func setMode(_ m: Mode) {
    closeActions()
    mode = m
    search.stringValue = ""
    applyTheme(savedTheme)
    refilter()
  }

  // MARK: Filtering

  func refilter() {
    let q = search.stringValue
    let empty = q.trimmingCharacters(in: .whitespaces).isEmpty

    if mode == .themes {
      rows = Family.all.compactMap { f in
        guard let m = fuzzyMatch(q, f.name) else { return nil }
        return Row(title: f.name, hits: m.hits, app: nil, family: f)
      }
      table.reloadData()
      select(empty ? Family.all.firstIndex { $0.name == savedFamily } ?? 0 : 0)
      return
    }

    let rank = Dictionary(mru.enumerated().map { ($1, $0) }, uniquingKeysWith: { a, _ in a })
    func mruRank(_ a: AppEntry) -> Int { rank[a.url.path] ?? Int.max }

    let pins = self.pins
    if empty {
      let pinned = apps.filter { pins.contains($0.url.path) }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        .map { Row(title: $0.name, app: $0) }
      let rest = apps.filter { !pins.contains($0.url.path) }.sorted {
        let (ra, rb) = (mruRank($0), mruRank($1))
        return ra != rb ? ra < rb : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
      }.map { Row(title: $0.name, app: $0) }
      rows =
        pinned.isEmpty
        ? rest
        : [Row(title: "Top Shelf", header: true)] + pinned + [Row(title: "Apps", header: true)] + rest
    } else {
      rows = apps.compactMap { app -> (Row, Int)? in
        guard let m = fuzzyMatch(q, app.name) else { return nil }
        let bonus = (rank[app.url.path] != nil ? 15 : 0) + (pins.contains(app.url.path) ? 20 : 0)
        return (Row(title: app.name, hits: m.hits, app: app), m.score + bonus)
      }.sorted { $0.1 > $1.1 }.map(\.0)
    }

    table.reloadData()
    // Empty query skips the frontmost app, so ⌘⌘ ↵ flips back like alt-tab.
    let front = NSWorkspace.shared.frontmostApplication?.bundleURL?.path
    let selectable = rows.indices.filter { !rows[$0].header }
    select(selectable.first { !empty || rows[$0].app?.url.path != front } ?? selectable.first ?? 0)
  }

  func step(_ d: Int) {
    var i = table.selectedRow + d
    while rows.indices.contains(i) && rows[i].header { i += d }
    if rows.indices.contains(i) { select(i) }
  }

  func move(_ d: Int) {
    if actionsOpen {
      actionIndex = max(0, min(actions.count - 1, actionIndex + d))
      trashArmed = false
      renderActions()
    } else {
      step(d)
    }
  }

  func select(_ i: Int) {
    noMatch.isHidden = !rows.isEmpty
    guard !rows.isEmpty else { return }
    let i = max(0, min(rows.count - 1, i))
    let old = table.selectedRow
    table.selectRowIndexes([i], byExtendingSelection: false)
    table.scrollRowToVisible(i)
    if i > 0 && rows[i - 1].header { table.scrollRowToVisible(i - 1) }  // keep the section title in view
    table.reloadData(forRowIndexes: IndexSet([old, i].filter { $0 >= 0 && $0 < rows.count }), columnIndexes: [0])
    if mode == .themes, let f = rows[i].family { applyTheme(appearance.pick(f)) }  // live preview
  }

  func controlTextDidChange(_ obj: Notification) {
    closeActions()
    refilter()
  }

  func control(_ control: NSControl, textView: NSTextView, doCommandBy sel: Selector) -> Bool {
    if actionsOpen {
      switch sel {
      case #selector(NSResponder.moveUp(_:)): move(-1)
      case #selector(NSResponder.moveDown(_:)): move(1)
      case #selector(NSResponder.insertNewline(_:)): runAction()
      case #selector(NSResponder.cancelOperation(_:)): closeActions()
      default: return false
      }
      return true
    }
    switch sel {
    case #selector(NSResponder.moveUp(_:)): step(-1)
    case #selector(NSResponder.moveDown(_:)): step(1)
    case #selector(NSResponder.insertNewline(_:)):
      if table.selectedRow >= 0 { activate(rows[table.selectedRow]) }
    case #selector(NSResponder.insertTab(_:)) where mode == .themes:
      appearance = appearance.next
      select(table.selectedRow)
    case #selector(NSResponder.cancelOperation(_:)):
      mode == .themes ? setMode(.apps) : hide()
    default: return false
    }
    return true
  }

  @objc func clicked() {
    closeActions()
    if table.clickedRow >= 0, !rows[table.clickedRow].header { activate(rows[table.clickedRow]) }
  }

  // MARK: Actions (⌘K)

  func openActions() {
    guard mode == .apps, rows.indices.contains(table.selectedRow), let app = rows[table.selectedRow].app else { return }
    let path = app.url.path
    let pinned = pins.contains(path)
    actions = [
      Action(
        title: pinned ? "Take Off the Top Shelf" : "Pin to Top Shelf", symbol: pinned ? "pin.slash" : "pin",
        run: { [weak self] in self?.togglePin(path) })
    ]
    // /System apps are on the sealed system volume and can't be trashed.
    if !path.hasPrefix("/System/") {
      actions.append(Action(title: "Uninstall…", symbol: "trash", run: { [weak self] in self?.uninstall(app) }))
    }
    actionsTitle = app.name
    actionIndex = 0
    trashArmed = false
    actionsBox.isHidden = false
    renderActions()
  }

  func closeActions() {
    actionsBox.isHidden = true
    trashArmed = false
  }

  func renderActions() {
    actionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    let title = NSTextField(labelWithString: actionsTitle)
    title.font = font(11)
    title.textColor = theme.muted
    actionsStack.addArrangedSubview(title)
    actionsStack.setCustomSpacing(8, after: title)
    title.leadingAnchor.constraint(equalTo: actionsStack.leadingAnchor, constant: 16).isActive = true

    for (i, a) in actions.enumerated() {
      let selected = i == actionIndex
      let danger = a.symbol == "trash"
      let color = danger ? NSColor.systemRed : selected ? theme.accent : theme.text
      let label = trashArmed && danger ? "Press ↵ again to trash it" : a.title

      let row = ActionRow()
      row.index = i
      row.wantsLayer = true
      row.layer?.cornerRadius = 8
      row.layer?.backgroundColor = selected ? theme.text.withAlphaComponent(0.08).cgColor : nil
      row.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(actionClicked(_:))))
      row.setAccessibilityRole(.button)
      row.setAccessibilityLabel(label)

      let icon = NSImageView(image: NSImage(systemSymbolName: a.symbol, accessibilityDescription: nil) ?? NSImage())
      icon.contentTintColor = color
      let text = NSTextField(labelWithString: label)
      text.font = font(13, bold: selected)
      text.textColor = color
      for v in [icon, text] as [NSView] {
        v.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(v)
      }
      actionsStack.addArrangedSubview(row)
      NSLayoutConstraint.activate([
        row.heightAnchor.constraint(equalToConstant: 34),
        row.leadingAnchor.constraint(equalTo: actionsStack.leadingAnchor, constant: 6),
        row.trailingAnchor.constraint(equalTo: actionsStack.trailingAnchor, constant: -6),
        icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
        icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        icon.widthAnchor.constraint(equalToConstant: 16),
        text.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
        text.centerYAnchor.constraint(equalTo: row.centerYAnchor),
      ])
    }
  }

  @objc func actionClicked(_ g: NSClickGestureRecognizer) {
    guard let row = g.view as? ActionRow else { return }
    actionIndex = row.index
    runAction()
  }

  func runAction() {
    guard actions.indices.contains(actionIndex) else { return }
    let a = actions[actionIndex]
    // Trashing needs a second ↵ so a stray keypress can't remove an app.
    if a.symbol == "trash" && !trashArmed {
      trashArmed = true
      renderActions()
      return
    }
    closeActions()
    a.run()
  }

  func togglePin(_ path: String) {
    if pins.contains(path) { pins.removeAll { $0 == path } } else { pins.append(path) }
    refilter()
    if let i = rows.firstIndex(where: { $0.app?.url.path == path }) { select(i) }
  }

  func uninstall(_ app: AppEntry) {
    let path = app.url.path
    for r in NSWorkspace.shared.runningApplications where r.bundleURL?.path == path { r.terminate() }
    NSWorkspace.shared.recycle([app.url]) { [weak self] _, err in
      DispatchQueue.main.async {
        guard let self else { return }
        if let err {
          NSLog("AppSwitcher: could not trash \(path): \(err)")
          NSSound.beep()
          return
        }
        self.pins.removeAll { $0 == path }
        self.apps.removeAll { $0.url.path == path }
        self.refilter()
      }
    }
  }

  func activate(_ row: Row) {
    if row.family != nil {
      savedFamily = row.title
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

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { rows[row].header ? 40 : 50 }

  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool { !rows[row].header }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    if rows[row].header {
      let h = tableView.makeView(withIdentifier: .init("header"), owner: nil) as? HeaderCell ?? HeaderCell()
      h.identifier = .init("header")
      h.label.attributedStringValue = NSAttributedString(
        string: rows[row].title, attributes: [.font: font(14, bold: true), .foregroundColor: theme.text.withAlphaComponent(0.7)])
      return h
    }
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
      cell.icon.image = r.family?.swatch
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

    let isCurrentTheme = r.family != nil && r.title == savedFamily
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
  assert(Set(Family.all.map(\.name)).count == Family.all.count)
  assert(Family.all.allSatisfy { $0.dark.dark && !$0.light.dark })
  assert(Appearance.light.next == .auto)
  print("selftest ok")
  exit(0)
}

let app = NSApplication.shared
let delegate = Switcher()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
