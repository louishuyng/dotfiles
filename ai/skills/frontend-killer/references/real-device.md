# Real iPhone testing with a mocked backend

The Simulator shows layout. Only a physical iPhone shows ProMotion smoothness, haptics, the real keyboard and autofill, Face ID, true cutout size, and performance. Sign off on a device. Mock the backend so a missing or broken API never blocks the check.

[V] means checked on 2026-11-09. [U] means unverified.

Sources: [Expo local dev](https://docs.expo.dev/guides/local-app-development/) · [dev builds](https://docs.expo.dev/develop/development-builds/create-a-build/) · [MSW RN](https://mswjs.io/docs/integrations/react-native) · [Expo env vars](https://docs.expo.dev/guides/environment-variables/) · [pymobiledevice3](https://github.com/doronz88/pymobiledevice3)

## Get the build onto the phone

- [ ] Developer Mode is on (Settings → Privacy & Security). The Mac is trusted and the phone is connected by USB. Wi-Fi pairing works after the first USB pairing [U].
- [ ] `xcrun devicectl list devices` lists the phone. devicectl IDs are not the same as xcodebuild UDIDs [U].
- [ ] `npx expo run:ios --device` builds a dev client. Add `--configuration Release` for the motion and performance sign-off.
- [ ] Signing: open `ios/<App>.xcworkspace`, go to Signing & Capabilities, and pick a Team. On a free account the build expires after 7 days [U]. With EAS, use `eas build --profile development --platform ios`.
- [ ] If signing or the device needs the human (Team choice, trust prompt, unlock), stop. Ask for that one action. Don't skip the device check silently.

## Capture evidence (into `.ui-review/device/`)

- [ ] devicectl has no screenshot command [V]. Use one of these:
  - `pymobiledevice3 developer dvt screenshot --tunnel "" out.png` on iOS 17+ [U: check the flags]
  - Xcode → Devices and Simulators → Take Screenshot
- [ ] For motion (swipe-back, sheet drag, large-title collapse), record with QuickTime → New Movie Recording → choose the iPhone as the source.
- [ ] Normalise the status bar on the Simulator: `xcrun simctl status_bar booted override --time 9:41 --batteryLevel 100`.

## What only a real device proves

- [ ] 120Hz smoothness and dropped frames on push, sheet, and scroll, in a release build.
- [ ] Haptics fire, and only where intended.
- [ ] Keyboard: QuickType bar, SMS `oneTimeCode`, password save and strong-password offers, and keyboard height with predictive text.
- [ ] Face ID prompt. This needs `NSFaceIDUsageDescription`.
- [ ] Notch and Dynamic Island at physical size. The home-indicator swipe doesn't clash with bottom gestures.
- [ ] Thumb reach of 44pt targets. Edge swipe-back doesn't clash with horizontal scrollers.
- [ ] Slow network, via Settings → Developer → Network Link Conditioner, shows the loading states.

## Mock the backend

Use the repo's existing mock layer first: MSW handlers, fixtures, a mock API client, or Storybook loaders. Add MSW only when none exists, and propose it first, because it is a new dev dependency.

- [ ] For MSW on React Native, use `@msw/react-native`. The old `msw/native` export has been removed [V].
  - `network.configure({ handlers })`, then `await network.enable()` before the root render.
  - `@msw/react-native` must be imported before anything from `msw` [V].
- [ ] Add a mock-mode switch: `if (__DEV__ && process.env.EXPO_PUBLIC_API_MOCK === '1') await import('./mocks/network')`. `EXPO_PUBLIC_*` values are inlined into the bundle, so never put secrets there [V].
- [ ] Use typed fixtures for each state:
  - default
  - loading (delayed handler)
  - empty
  - error (500 or offline)
  - long text (AX5)
  - one item and many items
- [ ] Deep-link straight to a screen in a given state:
  - Simulator: `npx uri-scheme open "myapp://orders/42?mock=error" --ios` or `xcrun simctl openurl booted …`
  - Device: open the link from Notes or Safari, or use a dev-only jump menu.
  - Read the `mock` parameter only under `__DEV__`.
- [ ] The same fixtures feed the Storybook stories, so the device and Storybook show identical data.

## Keep mocks out of production

- [ ] Load mocks only through a dynamic `import()` behind `__DEV__` and the env flag. MSW and Storybook stay in devDependencies.
- [ ] Run `npx expo export --platform ios`, then grep the bundle for `msw`, handler names, and fixture strings. You should get zero hits.
- [ ] A release build with no flag set hits the real API. Confirm it with one request.
