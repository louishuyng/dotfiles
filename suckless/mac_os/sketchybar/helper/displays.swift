// UUIDs of connected displays, one per line (same values as Display Identifier in com.apple.spaces; the main display is written as "Main" in the settings) — spaces.sh counts only the spaces of connected displays
import CoreGraphics
import ColorSync
var ids = [CGDirectDisplayID](repeating: 0, count: 16); var n: UInt32 = 0
CGGetActiveDisplayList(16, &ids, &n)
for i in 0..<Int(n) { if let u = CGDisplayCreateUUIDFromDisplayID(ids[i])?.takeRetainedValue() { print(CFUUIDCreateString(nil, u)!) } }
