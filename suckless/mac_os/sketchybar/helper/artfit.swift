// Make album art square: artfit <input> <output.jpg> [side px=476]
// A square image is just scaled to fit. Otherwise (16:9 video thumbnails etc.) the whole image is fitted in and the leftover top/bottom or sides are filled with a blurred, enlarged copy of it
import AppKit
import CoreImage
let a = CommandLine.arguments
guard a.count >= 3, let src = CIImage(contentsOf: URL(fileURLWithPath: a[1])) else { exit(1) }
let S = CGFloat(Double(a.count > 3 ? a[3] : "476") ?? 476)
let e = src.extent; let ctx = CIContext()
let fill = max(S / e.width, S / e.height), fit = min(S / e.width, S / e.height)
var out: CIImage
if abs(e.width - e.height) < 2 {
  out = src.transformed(by: CGAffineTransform(scaleX: fit, y: fit))
} else {
  let bg = src.clampedToExtent().transformed(by: CGAffineTransform(scaleX: fill, y: fill))
  let bgc = bg.transformed(by: CGAffineTransform(translationX: (S - e.width * fill) / 2, y: (S - e.height * fill) / 2))
    .applyingGaussianBlur(sigma: 18)
    .applyingFilter("CIColorControls", parameters: [kCIInputBrightnessKey: -0.12, kCIInputSaturationKey: 0.9])
  let fg = src.transformed(by: CGAffineTransform(scaleX: fit, y: fit))
  let fgc = fg.transformed(by: CGAffineTransform(translationX: (S - e.width * fit) / 2, y: (S - e.height * fit) / 2))
  out = fgc.composited(over: bgc)
}
out = out.cropped(to: CGRect(x: 0, y: 0, width: S, height: S))
guard let cg = ctx.createCGImage(out, from: out.extent) else { exit(1) }
let rep = NSBitmapImageRep(cgImage: cg)
guard let d = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else { exit(1) }
try? d.write(to: URL(fileURLWithPath: a[2]))
