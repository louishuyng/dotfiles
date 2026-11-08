// SketchyBar Wi-Fi Scan.app — writes nearby Wi-Fi names (SSID) and signal to ~/.cache/sketchybar/wifiscan.txt as "name<TAB>RSSI" and exits
// macOS gives SSIDs only to apps with Location permission → this tiny app holds that permission (allow once on first run). The location itself is never used
// First line is the status: ok | denied | undetermined. Run: open -g -W -a <this app> (only when the popup opens)
// With the argument `ssid` it prints the connected network name instead (wifi.sh, on network change)
import AppKit
import CoreLocation
import CoreWLAN
// SSIDs are chosen by whoever runs the network: drop control characters so a tab or newline cannot shift wifi.sh's tab-separated popup columns (one of them is a click command)
func clean(_ s: String) -> String { String(String.UnicodeScalarView(s.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) })) }
let out = URL(fileURLWithPath: NSHomeDirectory() + "/.cache/sketchybar/wifiscan.txt")
func write(_ s: String) { try? s.write(to: out, atomically: true, encoding: .utf8) }
final class D: NSObject, CLLocationManagerDelegate {
  let m = CLLocationManager()
  func start() { m.delegate = self; check() }
  func check() {
    switch m.authorizationStatus {
    case .authorizedAlways, .authorized: CommandLine.arguments.dropFirst().first == "ssid" ? current() : scan()
    case .notDetermined: m.requestWhenInUseAuthorization()
    default: write("denied\n"); exit(0)
    }
  }
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { if m.authorizationStatus != .notDetermined { check() } }
  func current() {   // `WifiScan ssid`: print the connected network name only (no scan, instant)
    print(clean(CWWiFiClient.shared().interface()?.ssid() ?? "")); exit(0)
  }
  func scan() {
    var lines = ["ok"]
    if let i = CWWiFiClient.shared().interface(), let ns = try? i.scanForNetworks(withSSID: nil) {
      var best: [String: Int] = [:]
      for n in ns { if let s = n.ssid.map(clean), !s.isEmpty { best[s] = max(best[s] ?? -999, n.rssiValue) } }
      for (s, r) in best.sorted(by: { $0.value > $1.value }) { lines.append("\(s)\t\(r)") }
    }
    write(lines.joined(separator: "\n") + "\n"); exit(0)
  }
}
let d = D()
DispatchQueue.main.async { d.start() }
DispatchQueue.main.asyncAfter(deadline: .now() + 60) { write("undetermined\n"); exit(0) }   // exit after 1 minute if the permission prompt goes unanswered
NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.run()
