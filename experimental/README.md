# RKA Prints Apps — experimental test bundle

These apps open **https://rkaprints.web.app** in an app window. They are website wrappers, require internet, and are not an offline or fully native replacement for the website.

This experiment is separate from the working Android v1.2 release. Test it before adding the installers to the public website downloads page. Do not replace stable download links with these files yet.

## What's included

| Folder | Platform | What to expect |
| --- | --- | --- |
| Windows | Windows x64 | Experimental EXE installer; not code-signed with a verified publisher certificate. |
| macOS-Apple-Silicon | Apple Silicon Macs | Experimental DMG; not Apple-notarized. |
| macOS-Intel | Intel Macs | Experimental DMG; not Apple-notarized. |
| Linux | Linux x64 | Experimental AppImage; desktop/runtime requirements vary by distribution. |
| iPhone-iPad | iPhone and iPad | **UNSIGNED IPA for developer signing only. It cannot be installed directly as supplied.** |

An unsigned or unnotarized desktop build may be rejected or flagged by operating-system protections. These builds are for testing; they do not have production distribution certificates. Do not disable system-wide security to install them.

For iPhone/iPad, open the included native source with an appropriate Apple development workflow, select your Apple development team, and sign/provision for your devices. A compiled IPA alone does not provide signing, device provisioning, App Store or TestFlight approval. The website can also be added to the Home Screen using Safari.

## Testing

Build checks confirm compilation and packaging only. Physical-device acceptance remains pending. Test website loading, sign-in, navigation/back, external links, file selection and downloads, sleep/resume, dark mode, narrow windows and updates. Some website authentication flows may reject embedded browsers.

The desktop wrapper isolates website code from Node.js and the operating system. The app does not inject website credentials, add a privileged JavaScript bridge, or bundle the private website source.

Source is in the experimental branch of [RKA-PRINTS/RKA-Prints-Android](https://github.com/RKA-PRINTS/RKA-Prints-Android). The main website source stays private. The repo can be renamed to RKA-Prints-Apps after testing; update build and website download links as part of that change.
