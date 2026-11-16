# Android native-feel checklist

Run this before declaring an Android screen done. It targets React Native / Expo. `ios-native.md` is the iOS counterpart; a cross-platform screen runs both.

Legend:

- **[U]** Unverified on this machine (no `adb` was available when this was written). Check the command or the prop against the installed tools and library versions before relying on it.
- Unmarked items are from the React Native docs, the Android developer docs, or Material guidance.

Where the Figma file disagrees with a platform default, Figma wins. Report the conflict so the designer knows. If the design has one frame for both platforms, the layout values come from the frame and the system behaviour (back, bars, ripple, fonts) comes from the platform.

Sources: [RN 0.81 Android 16 changes](https://github.com/react-native-community/discussions-and-proposals/discussions/921) · [gesture navigation](https://developer.android.com/training/gestures/gesturenav) · [predictive back in react-native-screens](https://github.com/software-mansion/react-native-screens/discussions/2540) · [react-native-edge-to-edge](https://www.npmjs.com/package/react-native-edge-to-edge) · [RN accessibility](https://reactnative.dev/docs/accessibility)

## 1. Edge-to-edge, system bars, devices

- [ ] The app draws behind the status bar and the navigation bar. Apps that target Android 15 are edge-to-edge by default, and Android 16 removes the opt-out. Do not rely on an opaque status bar or a `StatusBar` background colour.
- [ ] Insets come from `react-native-safe-area-context`. The core `SafeAreaView` is deprecated. Never hard-code a status bar or navigation bar height.
- [ ] Backgrounds run edge to edge. Text, controls, and tap targets stay inside the insets.
- [ ] Test both navigation modes. Gesture navigation has a thin bottom inset; three-button navigation has a tall one. A bottom-pinned CTA adds `insets.bottom` in both.
- [ ] Modals and sheets are edge-to-edge too. A modal needs its status bar and navigation bar translucency props set, or it draws a band the screen behind it does not have [U].
- [ ] Status bar icons are readable on the screen's background, in light and dark.
- [ ] Device sizes in dp, portrait [U]:
  - 360 × 640: small phones
  - 360 × 800: common mid-range
  - 412 × 915: large phones
  - 600 and wider: tablets and unfolded foldables, if the app supports them
- [ ] Minimum matrix: the smallest supported width, the Figma frame's width, and one large phone.

## 2. Touch targets and spacing

- [ ] Every tappable element has a hit area of at least **48 × 48dp**, with `hitSlop` or padding when the glyph is smaller. Neighbouring hit areas do not overlap.
- [ ] Controls near the left and right screen edges do not sit in the system back gesture zone. A horizontal carousel or slider that starts at the edge is tested for conflict with back.

## 3. Typography

- [ ] **Font padding.** Android `Text` adds extra space above and below the glyphs by default. A label then sits lower, and a container grows taller, than the Figma frame. Set `includeFontPadding: false` in the text style (in the design system's Text component, not per screen) and check vertical centring in buttons, chips, and rows. This is the most common cause of a padding or alignment difference that appears on Android only.
- [ ] `lineHeight` is honoured differently from iOS. Check each text style on a render against the spec sheet; do not assume the iOS result carries over.
- [ ] The system font is Roboto: omit `fontFamily` to get it. A design drawn in SF Pro will not match glyph for glyph on Android; compare size, weight, line height, and colour, and report the family difference as a platform one.
- [ ] Custom fonts: one file per weight, selected through `fontFamily`. `fontWeight` on a custom family can fall back to Regular. Verify every weight on a real Android build.
- [ ] Letter spacing converts from a Figma `%` as `fontSize × % / 100`, the same as on iOS.
- [ ] `allowFontScaling` stays true. Test at the largest font size setting (200% on Android 14 and later). Text wraps or stacks and never clips. Text containers have no fixed `height`.
- [ ] Truncation is intentional: `numberOfLines` plus `ellipsizeMode`.

## 4. Back and navigation

- [ ] System back works on every screen, by gesture and by button. It closes, in this order: an open keyboard, a menu or dialog, a sheet or modal, then the screen.
- [ ] Back on the root screen leaves the app. It never exits from a deeper screen.
- [ ] A blocking flow intercepts back with `BackHandler` or `usePreventRemove` and asks for confirmation. Remove the handler on unmount.
- [ ] Apps that target Android 16 get predictive back by default. Legacy native back callbacks are no longer called, while `BackHandler` still works. A common symptom of a broken setup is the app closing on back. Test back on every pushed screen after an SDK upgrade.
- [ ] Use the native stack (`@react-navigation/native-stack` or the Expo Router Stack). Keep the platform's default push transition unless the Figma prototype specifies one.
- [ ] After a deep link into a nested screen, back goes to the logical parent, not out of the app.

## 5. Keyboard and input

- [ ] The focused field and the primary action stay visible with the keyboard open, on the smallest device. Under edge-to-edge, `adjustResize` no longer resizes the window for you. Use `react-native-keyboard-controller`, or handle the keyboard inset explicitly, and test it; do not assume the iOS solution works [U].
- [ ] `keyboardType`, `autoComplete`, `returnKeyType`, and `autoCapitalize` match the field, as in `ios-native.md` §6. Check that SMS code autofill and the password manager offer appear on a real device.
- [ ] Back closes the keyboard first and does not also navigate.

## 6. Press feedback, elevation, and platform components

- [ ] Press feedback follows the design system. If it does not specify one, `Pressable` with `android_ripple` is the native default. The ripple is clipped to the control's radius (`overflow: 'hidden'` on a rounded wrapper, or `borderless: false`).
- [ ] Shadows: the iOS `shadow*` props do nothing on Android. Use `elevation`, or `boxShadow` where the React Native version supports it [U]. Compare the shadow against the Figma frame on a render, because `elevation` cannot express every blur and offset. Report a shadow the platform cannot draw as a design finding.
- [ ] A view with `elevation` has a solid background, or the shadow does not draw.
- [ ] Use native pickers, switches, alerts, and the share sheet. Destructive confirmations use `Alert` with a destructive-styled action and a cancel action.
- [ ] Do not copy iOS-only chrome to Android: no iOS-style large-title collapse, back chevron with the previous title, or swipe-from-edge sheet unless the design specifies it for Android.

## 7. Motion and performance

- [ ] Animations run on the UI thread, through Reanimated worklets or `useNativeDriver: true`.
- [ ] Test on a mid-range device in a release build. A debug build on an emulator says nothing about dropped frames.
- [ ] With "Remove animations" on (`useReducedMotion()`), slides and zooms become crossfades and loops stop.
- [ ] Long lists use `FlatList` or FlashList, with no blank flashes while scrolling fast.

## 8. Accessibility

- [ ] Every interactive element has an `accessibilityLabel`, an `accessibilityRole`, and an `accessibilityState`. Icon buttons are named with a verb.
- [ ] TalkBack order follows reading order. Composite rows are one focusable element. After navigation, focus lands on the new screen's title.
- [ ] Toggles announce their name and state. Progress and loading states are announced or take focus.
- [ ] Custom gestures have `accessibilityActions` equivalents.
- [ ] Contrast is at least 4.5:1 for small text and 3:1 for large text and glyphs, in light and dark. Measure it with `scripts/contrast.sh`.

## 9. Dark mode and colour

- [ ] The app follows the system theme, and a live switch updates every screen.
- [ ] Colours come from the project's tokens. Elevated surfaces get lighter in dark mode.

## 10. Commands for capture and checks [U]

All of these need `adb` and a connected device or emulator. Reset every setting you change when you finish.

| Purpose | Command |
| --- | --- |
| Screenshot | `adb exec-out screencap -p > .ui-review/impl/<frame>.png` |
| Recording | `adb shell screenrecord /sdcard/clip.mp4`, then `adb pull /sdcard/clip.mp4` |
| Density and size | `adb shell wm density` and `adb shell wm size` |
| View hierarchy with bounds | `adb shell uiautomator dump /sdcard/ui.xml`, then `adb pull /sdcard/ui.xml` |
| Dark mode | `adb shell cmd uimode night yes` (or `no`) |
| Font scale | `adb shell settings put system font_scale 2.0` (reset with `1.0`) |
| Animations off | `adb shell settings put global window_animation_scale 0`, and the same for `transition_animation_scale` and `animator_duration_scale` |
| Clean status bar | `adb shell settings put global sysui_demo_allowed 1`, then `adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941` |
| Tap, swipe, type | `adb shell input tap X Y`, `adb shell input swipe X1 Y1 X2 Y2 300`, `adb shell input text "..."` |
| Back | `adb shell input keyevent KEYCODE_BACK` |
| Home, then return | `adb shell input keyevent KEYCODE_HOME`, then relaunch the app |
| Deep link | `adb shell am start -a android.intent.action.VIEW -d "myapp://orders/42"` |
| Offline | `adb shell svc wifi disable` and `adb shell svc data disable` (re-enable after) |
| Destroy activities in background | `adb shell settings put global always_finish_activities 1` (reset with `0`) |

Two notes for the compare gate:

- **Scale.** Android densities are often not whole numbers (2.625, for example), so a screenshot's pixel width does not equal the Figma frame width times 2 or 3. Read the device width in pixels, and export the Figma frame at exactly that pixel width. `compare.sh` rejects images of different widths.
- **Measured padding.** The `uiautomator dump` output gives each element's bounds in pixels. Divide by the density (`wm density` / 160) to get dp, and compare with the spec sheet. This measures padding and position without estimating from a screenshot.

## Done gate

- [ ] Sections 1–9 pass on the device matrix, in light and dark, at the default and the largest font size, with gesture and three-button navigation.
- [ ] TalkBack and "Remove animations" passes are done.
- [ ] Sign-off runs on a release build on a physical Android phone.
- [ ] Every skipped check is listed with its reason.
