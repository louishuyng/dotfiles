// Run JavaScript in a tab of a specific Chrome process (pid): chromejs <pid> <text the URL contains> <js>
// With two separate Chromes running (different user data dirs), AppleScript 'application id' talks to only one of them, so the other one's tabs are invisible
// → pick the pid with ScriptingBridge and talk to that Chrome directly. Prints the result text as is. Empty output if not found, non-zero exit code on failure
import Foundation
import ScriptingBridge
let a = CommandLine.arguments
guard a.count == 4, let pid = pid_t(a[1]), let app = SBApplication(processIdentifier: pid) else { exit(2) }
app.timeout = 30   // in 1/60 s units → 0.5 s
let windows = (app.value(forKey: "windows") as? SBElementArray) ?? SBElementArray()
for case let w as SBObject in windows {
  let tabs = (w.value(forKey: "tabs") as? SBElementArray) ?? SBElementArray()
  for case let t as SBObject in tabs {
    guard let url = t.value(forKey: "URL") as? String, url.contains(a[2]) else { continue }
    let sel = Selector(("executeJavascript:"))
    guard t.responds(to: sel), let r = t.perform(sel, with: a[3])?.takeUnretainedValue() else { exit(1) }
    if let s = r as? String { print(s) } else if let o = r as? SBObject, let s = o.get() as? String { print(s) }
    exit(0)
  }
}
