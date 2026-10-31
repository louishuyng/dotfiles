// Spinning vinyl frames: discpng <0xAARRGGBB label color> <pt> <frames> <outdir>
// Draws a record (grooves, two sheen wedges, center label in the given color) at 2x, rotated by 360/frames per frame,
// to <outdir>/disc-<i>.png. SketchyBar cannot rotate an image itself; the sheen is what makes the rotation visible.
import AppKit
let a = CommandLine.arguments
guard a.count >= 5, let v = UInt32(a[1].dropFirst(2), radix: 16), let pt = Double(a[2]), let n = Int(a[3]), n > 0 else { exit(1) }
let label = NSColor(srgbRed: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: CGFloat(v >> 24) / 255)
let px = Int(pt * 2), r = CGFloat(px) / 2 - 1
for i in 0..<n {
  guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
  NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  let c = NSGraphicsContext.current!.cgContext
  c.translateBy(x: CGFloat(px) / 2, y: CGFloat(px) / 2)
  c.rotate(by: -CGFloat(i) * 2 * .pi / CGFloat(n))   // clockwise
  c.setFillColor(NSColor(srgbRed: 0.16, green: 0.18, blue: 0.17, alpha: 1).cgColor)
  c.fillEllipse(in: CGRect(x: -r, y: -r, width: 2 * r, height: 2 * r))
  c.setStrokeColor(NSColor(white: 0, alpha: 0.6).cgColor); c.setLineWidth(1)
  for k in stride(from: r * 0.88, to: r * 0.45, by: -2.5) { c.strokeEllipse(in: CGRect(x: -k, y: -k, width: 2 * k, height: 2 * k)) }
  c.setFillColor(NSColor(white: 1, alpha: 0.22).cgColor)
  for base in [CGFloat.pi * 0.15, CGFloat.pi * 1.15] {
    c.move(to: .zero); c.addArc(center: .zero, radius: r * 0.95, startAngle: base, endAngle: base + .pi * 0.22, clockwise: false); c.closePath(); c.fillPath()
  }
  let l = r * 0.36
  c.setFillColor(label.cgColor); c.fillEllipse(in: CGRect(x: -l, y: -l, width: 2 * l, height: 2 * l))
  c.setBlendMode(.clear); c.fillEllipse(in: CGRect(x: -2, y: -2, width: 4, height: 4))   // spindle hole
  NSGraphicsContext.restoreGraphicsState()
  try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(a[4])/disc-\(i).png"))
}
