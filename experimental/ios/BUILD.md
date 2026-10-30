# Experimental iPhone and iPad wrapper

This is the live RKA Prints website in a native WKWebView. It requires an internet connection and targets iOS/iPadOS 15 or later, on arm64 devices. It has safe-area layout, portrait/landscape support, standard system colours, the original website logo, Back, Forward, Reload and Open in Browser controls.

## What the IPA means

`RKA-Prints-iPhone-iPad-UNSIGNED.ipa` is a real compiled device app packaged as an IPA, **without an Apple signature or provisioning profile**. It is a developer build, not a tap-to-install iPhone installer. Do not promise ordinary installation, TestFlight availability or App Store approval from this file. It was not device-tested.

An authorised Apple development/distribution identity and a matching provisioning profile are needed for the chosen distribution route. A developer should import this Swift source and asset catalogue into an Xcode iOS app target, select their own team and a registered bundle identifier, then build/archive with Xcode's normal signing and export flow. Apple account requirements and eligible devices depend on that route. No signing credentials are included. The project does not bypass iOS installation protections.

## Build the unsigned device archive

On a Mac with Xcode and its iPhoneOS SDK selected:

```sh
bash build.sh
```

The output is `dist/RKA-Prints-iPhone-iPad-UNSIGNED.ipa`. Set `OUTPUT_DIR` to change the output folder. The script uses Apple's Swift compiler and asset compiler directly; no third-party build generator is required. The app's experimental bundle identifier is `app.rkaprints.experimental.ios`.

## Limitations

- Website updates appear online without rebuilding. Native icon or wrapper changes require a new app build.
- Downloads that WKWebView cannot display ask the user to use the regular browser. Blob exports and embedded identity-provider sign-in can require Safari.
- Only the RKA Prints website and its explicit Firebase hosting aliases navigate inside the app. Clicked web, mail and phone links can open external apps. Unrecognised URL schemes are rejected.
- This is an experimental website wrapper, not a full offline native shop. App Store review may require more than a website wrapper.
- On iPhone/iPad today, Safari's Share → Add to Home Screen offers an installable website option without this unsigned developer IPA.

Apple reference: https://developer.apple.com/documentation/webkit/wkwebview
