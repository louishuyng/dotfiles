// One line of multi-colored text to PNG (2x): textspans <out.png> <pt>  ← stdin, one line each "0xAARRGGBB<TAB>text"
// SketchyBar text has one color per cell, so when cells differ in color, like the calendar's week rows, it is laid on as an image (same JetBrains Mono glyphs and spacing)
import AppKit
let a = CommandLine.arguments; guard a.count == 3, let pt = Double(a[2]) else { exit(1) }
let font = NSFont(name: "JetBrains Mono", size: pt * 2) ?? NSFont.monospacedSystemFont(ofSize: pt * 2, weight: .regular)
let s = NSMutableAttributedString()
while let line = readLine(strippingNewline: true) {
  guard let tab = line.firstIndex(of: "\t"), let v = UInt32(line[line.startIndex..<tab].dropFirst(2), radix: 16) else { continue }
  let col = NSColor(srgbRed: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: CGFloat(v >> 24) / 255)
  s.append(NSAttributedString(string: String(line[line.index(after: tab)...]), attributes: [.font: font, .foregroundColor: col]))
}
let sz = s.size(); let w = max(1, Int(ceil(sz.width))), h = max(1, Int(ceil(sz.height)))
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
s.draw(at: .zero); NSGraphicsContext.restoreGraphicsState()
try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: a[1]))
