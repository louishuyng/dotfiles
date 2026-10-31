// Prints the x of the notch's left and right edges on the bar's display (from that display's left, pt): "790 1010". notch [DirectDisplayID] — default is the main display (menu-bar display, screens[0])
// Without a notch, the display center twice ("960 960") → the media island ends at center − 5. The right island and settings circle stay anchored to the display's right edge as before (by request, 2026-10-01)
import AppKit
let want = CommandLine.arguments.count > 1 ? UInt32(CommandLine.arguments[1]) : nil
let key = NSDeviceDescriptionKey("NSScreenNumber")
if let s = NSScreen.screens.first(where: { want == nil || ($0.deviceDescription[key] as? UInt32) == want }) ?? NSScreen.screens.first {
  if let l = s.auxiliaryTopLeftArea, let r = s.auxiliaryTopRightArea {
    print(Int(l.maxX - s.frame.minX), Int(r.minX - s.frame.minX))
  } else {
    let c = Int(s.frame.width / 2); print(c, c)
  }
}
