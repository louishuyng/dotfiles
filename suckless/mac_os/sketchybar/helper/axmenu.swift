// Read and press an app's menus through the Accessibility (AX) API (faster than System Events). Needs Accessibility permission
//   axmenu menus <pid>                 → one line each: "M<TAB>menu name" or "I<TAB>menu index<TAB>item index<TAB>name<TAB>checked 0/1<TAB>shortcut". Apple and app-name menus excluded, separators and sub-submenus excluded
//   axmenu front                      → front app "pid<TAB>name"
//   axmenu settings <pid>              → press Settings…/Preferences… (or its Korean title) in the app-name menu (exit 1 if none)
//   axmenu press <pid> <menu index> <item index>
import AppKit
import ApplicationServices
func attr(_ e: AXUIElement, _ a: String) -> AnyObject? { var v: AnyObject?; return AXUIElementCopyAttributeValue(e, a as CFString, &v) == .success ? v : nil }
func kids(_ e: AXUIElement) -> [AXUIElement] { (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? [] }
func title(_ e: AXUIElement) -> String { (attr(e, kAXTitleAttribute) as? String) ?? "" }
func topMenus(_ pid: pid_t) -> [AXUIElement] {
  guard let bar = attr(AXUIElementCreateApplication(pid), kAXMenuBarAttribute) else { return [] }
  return kids(bar as! AXUIElement)
}
func items(_ menuBarItem: AXUIElement) -> [AXUIElement] { kids(menuBarItem).first.map(kids) ?? [] }
// Keys without a character (arrows, Return etc.) come from the AXMenuItemCmdGlyph number — common ones only
let glyphs: [Int: String] = [2: "⇥", 4: "⌅", 9: "␣", 10: "⌦", 11: "↩", 23: "⌫", 27: "⎋", 100: "←", 101: "→", 104: "↑", 106: "↓", 98: "⇞", 107: "⇟", 102: "↖", 105: "↘"]
func shortcut(_ e: AXUIElement) -> String {
  var c = (attr(e, "AXMenuItemCmdChar") as? String) ?? ""
  if c.isEmpty, let g = attr(e, "AXMenuItemCmdGlyph") as? Int { c = glyphs[g] ?? "" }
  // The 🌐 (fn) key is written as text, "fn E" · other pictographs (🎤 dictation key etc.) can't be turned into text, so left blank (keeps color emoji out of the shortcut column)
  var fn = ""; if c.hasPrefix("🌐") { fn = "fn"; c = String(c.dropFirst()) }
  if c.unicodeScalars.contains(where: { $0.properties.isEmojiPresentation }) { c = "" }
  let m = (attr(e, "AXMenuItemCmdModifiers") as? Int) ?? 0
  if m & 16 != 0 { fn = "fn" }   // 16 = fn (🌐) — Chrome 'Enter Full Screen' 24 = fn F
  var s = ""; if m & 4 != 0 { s += "⌃" }; if m & 2 != 0 { s += "⌥" }; if m & 1 != 0 { s += "⇧" }; if m & 8 == 0 { s += "⌘" }
  guard !c.isEmpty || !fn.isEmpty else { return "" }
  return [fn, c.isEmpty ? "" : s + c.uppercased()].filter { !$0.isEmpty }.joined(separator: " ")
}
let a = CommandLine.arguments
guard a.count >= 2 else { exit(2) }
switch a[1] {
case "menus":
  guard a.count >= 3, let pid = pid_t(a[2]) else { exit(2) }
  let tops = topMenus(pid)
  for (mi, m) in tops.enumerated() where mi >= 2 {   // 0 = Apple, 1 = app-name menu (replaced by the Settings… row)
    print("M\t\(mi)\t\(title(m))")
    for (ii, it) in items(m).enumerated() {
      let t = title(it); if t.isEmpty { continue }   // separator
      let en = (attr(it, kAXEnabledAttribute) as? Bool) ?? true
      print("I\t\(mi)\t\(ii)\t\(t)\t\(en ? 1 : 0)\t\(shortcut(it))")
    }
  }
case "settings":
  guard a.count >= 3, let pid = pid_t(a[2]) else { exit(2) }
  let tops = topMenus(pid); guard tops.count > 1 else { exit(1) }
  for it in items(tops[1]) where ["설정…", "설정...", "Settings…", "Preferences…", "환경설정…"].contains(title(it)) || title(it).hasPrefix("설정") {
    AXUIElementPerformAction(it, kAXPressAction as CFString); exit(0)
  }
  exit(1)
case "press":
  guard a.count >= 5, let pid = pid_t(a[2]), let mi = Int(a[3]), let ii = Int(a[4]) else { exit(2) }
  let tops = topMenus(pid); guard mi < tops.count else { exit(1) }
  let its = items(tops[mi]); guard ii < its.count else { exit(1) }
  exit(AXUIElementPerformAction(its[ii], kAXPressAction as CFString) == .success ? 0 : 1)
case "front":   // front app "pid<TAB>name" — lsappinfo output varies per app (apps without a bundle), so done here
  if let f = NSWorkspace.shared.frontmostApplication { print("\(f.processIdentifier)\t\(f.localizedName ?? "?")") }
default: exit(2)
}
