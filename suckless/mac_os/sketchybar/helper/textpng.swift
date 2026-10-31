// One line of text to PNG (2x resolution): textpng "<text>" <0xAARRGGBB> <pt> <out.png> [trim] [sys]
//   trim: crop the blank columns on both sides so image width = ink width (for right-edge alignment) · sys: SF Mono (JetBrains Mono's − looks the same as a hyphen)
// Laid on via background.image when one popup row needs two colors (device name as is, only the 'failed' on the right in red)
import AppKit
let a = CommandLine.arguments; guard a.count >= 5, let v = UInt32(a[2].dropFirst(2), radix: 16), let pt = Double(a[3]) else { exit(1) }
let col = NSColor(srgbRed: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: CGFloat(v >> 24) / 255)
let font = (a.contains("sys") ? nil : NSFont(name: "JetBrains Mono", size: pt * 2)) ?? NSFont.monospacedSystemFont(ofSize: pt * 2, weight: .regular)
let s = NSAttributedString(string: a[1], attributes: [.font: font, .foregroundColor: col])
let sz = s.size(); let pad = a.contains("trim") ? 6 : 0; let w = Int(ceil(sz.width)) + pad, h = Int(ceil(sz.height))
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
s.draw(at: NSPoint(x: pad / 2, y: 0))   // trim: 3 blank columns each side — for glyphs that overhang to the left like ⌘ + room to make the width even
; NSGraphicsContext.restoreGraphicsState()
var out = rep
if a.contains("trim") {   // keep only the columns with alpha
  let cols = (0..<w).filter { x in (0..<h).contains { y in (rep.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0.15 } }
  if let c0 = cols.first, let x1 = cols.last {
    let x0 = (x1 - c0 + 1) % 2 == 1 ? c0 - 1 : c0   // even width (whole pt) — one blank column on the left
    if let cg = rep.cgImage?.cropping(to: CGRect(x: x0, y: 0, width: x1 - x0 + 1, height: h)) { out = NSBitmapImageRep(cgImage: cg) }
  }
}
try? out.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: a[4]))
