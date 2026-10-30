# RKA Prints Android app

**This is the RKA Prints website in an Android app.** It opens the live [rkaprints.web.app](https://rkaprints.web.app/) website in an Android WebView, with its own launcher icon and Android navigation. An internet connection is required. Website updates appear without reinstalling this app.

## Download

Download a signed APK from [GitHub Releases](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/latest). Install only one edition: all three use the same app identity and can update one another.

| Edition | Download | Icon and theme support |
| --- | --- | --- |
| Samsung | [RKA-Prints-Samsung.apk](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/latest/download/RKA-Prints-Samsung.apk) | Works with Samsung themes: the owner confirmed Samsung theming works in version 1.1. This edition preserves that icon geometry and monochrome support. |
| Google / Pixel | [RKA-Prints-Google.apk](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/latest/download/RKA-Prints-Google.apk) | Fits Google's circular app icons, with a circular legacy fallback and an adaptive, monochrome icon for supported themed launchers. Designed for Pixel; physical Pixel testing is pending. |
| Generic Android | [RKA-Prints-Android.apk](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/latest/download/RKA-Prints-Android.apk) | Recommended if unsure. Uses adaptive and monochrome icons so Samsung, Google and other compatible Android launchers choose their own shapes and colours. |

All editions run on Android 6.0 or later. Adaptive shapes require Android 8.0+, dynamic native colours Android 12+, and the supplied monochrome icon requires Android 13+ plus a supporting launcher. Device settings and individual icon packs determine which styling is applied.

The launcher already knows the device's icon mask and theme, so manufacturer detection is unnecessary. The app provides the appropriate icon layers instead of switching launcher entries after installation. The editions share one app implementation; their legacy icon shapes differ.

To install, download on your Android device, open the APK, and allow your browser or file manager to install apps if Android asks. Version 1.2 updates the earlier RKA Prints wrapper using the same package and signing certificate. To switch editions, install the other APK over the existing app.

## Website and source repositories

- Live website: [rkaprints.web.app](https://rkaprints.web.app/)
- Public app source and APK releases: [RKA-PRINTS/RKA-Prints-Android](https://github.com/RKA-PRINTS/RKA-Prints-Android)
- Main website source: [RKA-PRINTS/RKA_PRINTS_website_files](https://github.com/RKA-PRINTS/RKA_PRINTS_website_files) — private; only authorised collaborators can view it.

This public repository contains only the Android wrapper and its icon assets. The website itself remains hosted by RKA Prints. Public APK downloads are served by this repository's Releases page, so visitors do not need access to the private website repository. GitHub Packages is not required.

## Features and limits

- Live website, Android Back navigation and persistent website cookies.
- File uploads, HTTPS downloads, external links and a connection-error retry screen.
- Native light/dark mode, system palette accents, adaptive launcher icons and an Android 12+ splash screen.
- The website controls its own page styling. Native dark mode does not force a website that declares a light colour scheme to become dark.
- Some embedded Google sign-in flows and browser-generated blob downloads require using the website in a regular browser.

Samsung theme behaviour was confirmed by the owner on the previous build. Version 1.2 APK signatures, archive integrity, version metadata, round/adaptive/monochrome resources, and matching signing certificates have been checked. No physical Pixel or broad Android device test has been performed.

## Build

Install JDK 17, Python 3, Android SDK Platform 35 and Build Tools 35.0.0. Linux, macOS or Windows with WSL can run:

```sh
export ANDROID_SDK_ROOT=/path/to/android-sdk
bash build.sh
```

This creates unsigned build-check APKs in `dist/`; they cannot be installed until signed. Pass `Samsung`, `Google` or `Generic` as the first argument to build one edition. `Generic` produces the `RKA-Prints-Android` filename.

For release builds, set `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, and `KEY_ALIAS` privately before running the same script. Set `KEY_PASSWORD` only if the key has a different password. `OUTPUT_DIR` can select an external output folder. `ECJ_JAR` optionally selects the Eclipse Java compiler when `javac` is unavailable.

**Signing keys and passwords are never included in this repository or its source download.** Keep the original signing key private to produce compatible updates. A different key cannot update an already installed app signed with the original key.

The normal CI workflow compiles unsigned APKs without signing secrets, including on pull requests. The separate manual release workflow requires repository signing secrets and publishes only when a maintainer explicitly runs it. See [Release setup](docs/RELEASING.md).

Icon PNGs are checked in. To regenerate their legacy shapes from `assets/rka-app-icon.svg`, install `cairosvg` and run `python3 scripts/generate-icons.py`. Adaptive and monochrome vectors preserve the site's logo paths.
