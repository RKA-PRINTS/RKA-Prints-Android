# RKA Prints Experimental Desktop

This is **the live RKA Prints website in a desktop app**, not an offline or fully native storefront. It opens https://rkaprints.web.app and requires internet. Website updates appear without reinstalling the wrapper.

Experimental version: **0.1.0**. The desktop app uses a separate identity from the working Android app.

## Build on the matching operating system

Install Node.js 22 or newer, then run `npm ci` and `npm test` from this directory. Exact Electron and electron-builder versions are pinned in `package-lock.json`.

| Host | Command | Output in `dist/` |
| --- | --- | --- |
| Windows x64 | `npm run dist:win` | `RKA-Prints-Experimental-0.1.0-win-x64.exe` (NSIS installer) |
| macOS | `npm run dist:mac` | `RKA-Prints-Experimental-0.1.0-mac-x64.dmg` and `RKA-Prints-Experimental-0.1.0-mac-arm64.dmg` |
| Linux x64 | `npm run dist:linux` | `RKA-Prints-Experimental-0.1.0-linux-x64.AppImage` |

Set `CSC_IDENTITY_AUTO_DISCOVERY=false` on macOS build runners. These experimental builds have no Windows publisher certificate or Apple Developer ID/notarization. OS security tools may warn or block installation. Do not describe them as trusted-store releases. Apple Silicon binaries may receive a packaging-level ad-hoc signature; this does not establish publisher identity.

For Linux, make the AppImage executable (`chmod +x RKA-Prints-Experimental-0.1.0-linux-x64.AppImage`) and run it as a regular desktop user. Depending on the distribution, FUSE support may be required. This app does not disable Chromium's sandbox.

## Behaviour and limits

- Native menu: Back, Forward, Reload, Home, zoom controls and Open website in browser.
- Original website SVG is used to produce the app icon.
- HTTPS website navigation stays inside the app. External web/contact links open their system handler; unsafe schemes are blocked.
- File downloads use Electron's save dialog. Downloaded files are never launched automatically.
- Remote content has no Node.js access, no preload bridge, and runs with context isolation and sandboxing.
- Camera, microphone, location and notification permissions are denied by this wrapper. File selection uses the usual webpage file input.
- Some sign-in providers reject embedded browsers. Use Navigate > Open website in browser when needed. Website styling controls light/dark appearance within the page.
- Installer compilation is not physical-device acceptance testing. Test sign-in, file upload/download, links, printing and quit/reopen behaviour before promoting any platform to stable.

The source includes no credentials, private website source, Android signing key or Apple signing identity.
