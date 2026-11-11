# iPhone native-feel checklist

Run this before declaring an iOS screen done. It targets React Native / Expo first, with SwiftUI notes.

Legend:

- **[A]** Apple HIG figure, not re-verified. developer.apple.com renders client-side, so it could not be quoted.
- **[U]** Unverified or inferred. Check it against the installed library version before relying on it.
- Unmarked items are from the React Native, React Navigation, or Expo docs.

Where the Figma file disagrees with a platform default, Figma wins. Report the conflict so the designer knows.

Sources: [HIG](https://developer.apple.com/design/human-interface-guidelines) · [native-stack](https://reactnavigation.org/docs/native-stack-navigator) · [Expo safe areas](https://docs.expo.dev/develop/user-interface/safe-areas/) · [RN docs](https://reactnative.dev/docs/)

## 1. Safe areas, status bar, devices

- [ ] Insets come from `react-native-safe-area-context` (`useSafeAreaInsets`). Never hard-code 44, 47, 59, or 34.
- [ ] Backgrounds, images, and gradients run edge to edge. Text, controls, and tap targets stay inside the safe area.
- [ ] Nothing interactive sits under the Dynamic Island or the home indicator. The bottom inset is about 34pt on Face ID phones and 0 on SE [A].
- [ ] A bottom-pinned CTA adds `insets.bottom`. When the keyboard is open, the CTA rides on the keyboard.
- [ ] The status bar is readable in light and dark mode. Use `expo-status-bar` `style="auto"`, or `statusBarStyle` per screen.
- [ ] If the app is portrait-locked, `orientation` in app.json says so. If it rotates, the side insets clear the notch.
- [ ] Device sizes in points, portrait [A/U]:
  - 375×667: SE 2/3, no notch
  - 390×844
  - 393×852
  - 402×874: 16 Pro / 17
  - 430×932
  - 440×956: 16/17 Pro Max
- [ ] Minimum matrix: SE, the Figma frame's width, and one Pro Max.

## 2. Touch targets and spacing

- [ ] Every tappable element has a hit area of at least **44×44pt** [A]. A small glyph reaches it with `hitSlop` or padding. Neighbouring hit slops do not overlap.
- [ ] Nav bar height (about 44pt) and tab bar height (about 49pt plus the inset) are left to the native components. Do not fake them with fixed heights [U].

## 3. Typography

- [ ] The system font is SF Pro: omit `fontFamily`. Dynamic Type at the default "Large" size [A]:

| Style       | Weight   | Size/Leading |
| ----------- | -------- | ------------ |
| Large Title | Regular  | 34/41        |
| Title 1     | Regular  | 28/34        |
| Title 2     | Regular  | 22/28        |
| Title 3     | Regular  | 20/25        |
| Headline    | Semibold | 17/22        |
| Body        | Regular  | 17/22        |
| Callout     | Regular  | 16/21        |
| Subhead     | Regular  | 15/20        |
| Footnote    | Regular  | 13/18        |
| Caption 1   | Regular  | 12/16        |
| Caption 2   | Regular  | 11/13        |

- [ ] No text is smaller than 11pt.
- [ ] `allowFontScaling` stays true. Use `maxFontSizeMultiplier` only on space-critical chrome such as tab labels and badges.
- [ ] Test at accessibility size AX5 (fontScale about 3.1 [U]). Text wraps or stacks and never clips. Text containers have no fixed `height`.
- [ ] `lineHeight` is absolute in RN. Check that descenders don't clip at large scales.
- [ ] Truncation is intentional: `numberOfLines` plus `ellipsizeMode`. Titles don't truncate at default size on the SE.
- [ ] **Custom fonts on iOS:** load one file per weight and select the weight through `fontFamily`, e.g. `Inter-SemiBold`. `fontWeight` on a single custom family can fall back silently to Regular or System. Verify every weight on a real iOS build.
- [ ] **Letter spacing:** convert a Figma `%` to RN points as `fontSize × % / 100`. Example: −2% at 17pt is −0.34. Don't stack Figma tracking on SF, which already tracks per size.
- [ ] With Bold Text on (`AccessibilityInfo.isBoldTextEnabled()`), custom fonts step up one weight.
- [ ] SwiftUI: use `.custom(name, size:, relativeTo:)` and `@ScaledMetric` for spacing and icon size.

## 4. Navigation and transitions

- [ ] Use `@react-navigation/native-stack` or the Expo Router Stack, never the JS `@react-navigation/stack`. A push slides in from the right with a parallax effect. Keep `animation: 'default'`.
- [ ] Edge swipe-back works on every pushed screen. `gestureEnabled: false` is allowed only for blocking flows, together with `usePreventRemove` and a confirm dialog.
- [ ] `fullScreenGestureEnabled` is off by default. It fights horizontal carousels.
- [ ] The back button shows the previous title, or uses `headerBackButtonDisplayMode`. No custom back arrow: it loses the long-press back menu [U].
- [ ] **Modals:**
  - `presentation: 'modal'` gives a page sheet with card stack and swipe-down.
  - `formSheet` takes `sheetAllowedDetents` (`'fitToContents'` or `[0.5, 1]`), `sheetGrabberVisible`, and `sheetCornerRadius`.
  - Use `fullScreenModal` only for takeovers. It needs an explicit Close button.
- [ ] Sheets put Cancel/Done in the header. Swipe-dismiss with unsaved edits prompts first.
- [ ] **Large title:** set `headerLargeTitleEnabled` (`headerLargeTitle` in older majors). The first child is a full-height scroll view with `contentInsetAdjustmentBehavior="automatic"`. Check that the title collapses on scroll.
- [ ] A translucent header uses `headerTransparent` plus `headerBlurEffect`. Content then needs its own top inset.
- [ ] **Tab bar:**
  - Tapping the active tab pops its stack to root. A second tap scrolls to top (`useScrollToTop`).
  - At most 5 tabs, each an SF Symbol with a short label.
  - Consider native tabs for iOS 26 Liquid Glass [U].

## 5. Scrolling

- [ ] `bounces` stays true. Rubber-banding and momentum stay enabled on content lists.
- [ ] Pull-to-refresh is `RefreshControl`, not a custom spinner.
- [ ] Forms and chats use `keyboardDismissMode="interactive"` and `keyboardShouldPersistTaps="handled"`.
- [ ] Scroll indicators and bottom padding clear headers, the tab bar, and the home indicator.
- [ ] `decelerationRate` stays `normal`, except paging carousels (`'fast'` plus `snapToInterval`).
- [ ] Long lists use `FlatList` or FlashList, with no blank flashes in a release build.
- [ ] Only one ScrollView per screen has `scrollsToTop`, so a status-bar tap scrolls it to top.

## 6. Keyboard and input

- [ ] `keyboardType` matches the field: `email-address`, `number-pad`, `decimal-pad`, `phone-pad`, or `url`.
- [ ] Autofill uses `textContentType` (`oneTimeCode`, `username`, `password`, `newPassword`, `emailAddress`, `telephoneNumber`) or `autoComplete`. Check that the SMS code reaches the QuickType bar on a real device.
- [ ] `returnKeyType` is `next` on intermediate fields, with focus moving to the next ref. The last field uses `go`, `done`, `send`, or `search`.
- [ ] `autoCapitalize`:
  - `none` for email, username, URL
  - `words` for names
  - `sentences` for prose
- [ ] Codes and identifiers set `autoCorrect={false}`.
- [ ] Keyboard avoidance uses `KeyboardAvoidingView behavior="padding"`, `automaticallyAdjustKeyboardInsets`, or `react-native-keyboard-controller`. The focused field and the CTA stay visible on the SE.

## 7. Haptics, press feedback, menus

- [ ] Haptics are sparse and match the event:
  - `selectionAsync` for picker, segment, or toggle changes
  - `impactAsync` for detent snaps and drops
  - `notificationAsync(Success|Warning|Error)` for outcomes
  - Never haptics on every ordinary button tap.
- [ ] Press feedback is an iOS opacity dim or a row highlight. No `android_ripple` or Material ripple.
- [ ] Highlight is delayed in scrolling lists, so a scroll doesn't flash rows.
- [ ] Long-press shows a native context menu (zeego, `@react-native-menu/menu`, or similar), not a JS popover. Destructive items are red and come last.
- [ ] Destructive confirmations use `ActionSheetIOS` or an Alert with `style: 'destructive'`, plus Cancel.

## 8. Motion

- [ ] Animations run on the UI thread, through Reanimated worklets or `useNativeDriver: true`. No JS-thread loops.
- [ ] Interactive motion uses critically damped springs. SwiftUI's default is about response 0.55 / damping 0.825 [U]. Avoid wobbly overshoot unless Figma's prototype specifies it.
- [ ] Gestures hand their release velocity to `withSpring` or `withDecay`.
- [ ] ProMotion: set `CADisableMinimumFrameDurationOnPhone = true` in Info.plist (`ios.infoPlist`), or the app stays capped at 60Hz [U]. No dropped frames on push, sheet, or scroll in a release build.
- [ ] Reduce Motion (`useReducedMotion()`) swaps slide, zoom, and parallax for crossfades and stops looping animations.
- [ ] Skeletons stop once content arrives. Nothing re-animates on every mount.
- [ ] If the Figma prototype defines a transition (Smart Animate, duration, easing), match it and note the values you used.

## 9. Accessibility

- [ ] Every interactive element has an `accessibilityLabel`. Icon buttons are named with a verb.
- [ ] Set `accessibilityRole` (`button`, `header`, `link`, `switch`, `tab`, …) and `accessibilityState`.
- [ ] Section titles have role `header`. Composite rows are `accessible` as one element.
- [ ] VoiceOver order follows reading order. After navigation, focus lands on the new title.
- [ ] Custom gestures have `accessibilityActions` equivalents. Modals set `accessibilityViewIsModal`.
- [ ] Contrast is at least 4.5:1 for small text and at least 3:1 for large text and glyphs. Check light, dark, and Increase Contrast.
- [ ] Reduce Transparency swaps blur for solid fills. Information never relies on colour alone.

## 10. Dark mode, colour, materials

- [ ] `userInterfaceStyle: "automatic"`. A live switch from Control Center updates every screen.
- [ ] Use the project's tokens first. Use `PlatformColor` or `DynamicColorIOS` only where the design system maps to system colours.
- [ ] Dark mode is not inverted light mode: elevated surfaces get lighter. Separators are hairlines.
- [ ] Translucent chrome is a native `BlurView` (`systemMaterial` and similar), not a semi-transparent solid fill.

## 11. Final sweep: things that make RN feel non-native

- [ ] No JS stack. No leftover `gestureEnabled: false`. No `animation: 'none'` on pushes.
- [ ] No full-screen `<View>` overlay pretending to be a sheet.
- [ ] No Android-isms:
  - ripples, FABs, snackbars
  - a hamburger drawer as primary navigation
  - uppercase buttons
  - top tabs as primary navigation
- [ ] Shadows use the iOS `shadow*` props or `boxShadow`. `elevation` does nothing on iOS. A shadowed view has a solid background.
- [ ] Copyable content uses `<Text selectable>`.
- [ ] Use native controls for `Switch`, date picker, segmented control, `ActionSheetIOS`, `Alert`, and `Share.share`.
- [ ] Header buttons are text verbs or SF Symbols in the native header.

## Done gate

- [ ] Sections 1–11 pass on the device matrix, in light and dark, at default type size and AX5.
- [ ] VoiceOver and Reduce Motion passes are done.
- [ ] Sign-off runs on a **release build on a physical iPhone**. See `real-device.md`.
- [ ] Recordings of swipe-back, sheet dismiss, and large-title collapse go in `.ui-review/`, never in git.
- [ ] Every skipped check is listed with its reason.
