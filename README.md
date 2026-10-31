# RKA Prints Apps

Lightweight apps for the live [RKA Prints website](https://rkaprints.web.app/). These apps require an internet connection. Website content updates independently of the installed wrapper.

## Downloads

Browse the [Android APK files](release-assets/v1.2.0/) or the [experimental apps folder](release-assets/experimental/) for Windows, macOS, Linux and iPhone/iPad. [Download the experimental ZIP directly](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/download/experimental-apps-5/RKA-Prints-Apps-Experimental-5.zip).

| Platform | Status | Download and documentation |
| --- | --- | --- |
| Android | Stable | [Latest APK release](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/latest) · [Android guide](docs/ANDROID.md) |
| Windows x64 | Experimental | [Experimental bundle](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/tag/experimental-apps-5) |
| macOS, Intel and Apple Silicon | Experimental | [Experimental bundle](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/tag/experimental-apps-5) |
| Linux x64 | Experimental | [Experimental bundle](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/tag/experimental-apps-5) |
| iPhone and iPad | Developer preview | Unsigned IPA in the experimental bundle; Apple signing and provisioning are required before installation. |

Android editions are available for generic Android, Samsung and Google/Pixel launchers. Install one edition at a time. Samsung theme support has been reported working; Pixel device testing remains pending.

Experimental desktop installers have no verified publisher identity. Mac builds use ad-hoc signing and are not notarized. Successful compilation does not establish device compatibility or successful sign-in. Read the [experimental installation guide](experimental/README.md) before testing.

## Project structure

| Location | Purpose |
| --- | --- |
| `src/`, `res/`, `variants/` | Android wrapper and launcher resources |
| `assets/`, `scripts/` | Shared branding source and icon generation |
| `experimental/desktop/` | Electron desktop wrapper |
| `experimental/ios/` | Swift and WKWebView wrapper |
| `docs/` | Build and release documentation |
| `.github/workflows/` | Build checks and release automation |

## Development

- [Android build guide](docs/ANDROID.md#build)
- [Desktop build guide](experimental/desktop/README.md)
- [iPhone/iPad build guide](experimental/ios/BUILD.md)
- [Contributing](CONTRIBUTING.md)
- [Release process](docs/RELEASING.md)
- [Agent instructions](AGENTS.md)

The public repository contains app wrappers, branding and distribution tooling. The website source is maintained separately in a private repository. Never include website source, customer information or signing credentials in public contributions.

## Known limitations

Embedded browsers may not support every identity provider, download or website feature. Use the [website in your browser](https://rkaprints.web.app/) when a feature is unavailable. Physical-device testing of experimental platforms is still pending.

Report reproducible app issues with the platform, OS version, app version and steps to reproduce. Remove personal information from screenshots and logs. See [security reporting](SECURITY.md) for sensitive issues.
