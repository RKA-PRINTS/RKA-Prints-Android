# Experimental app downloads

[Download the experimental apps ZIP](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/download/experimental-apps-5/RKA-Prints-Apps-Experimental-5.zip) (approximately 493 MB).

This folder sits alongside the stable Android APKs in [../v1.2.0/](../v1.2.0/). The ZIP contains the other platforms:

| ZIP folder | App |
| --- | --- |
| Windows | Windows x64 EXE installer |
| macOS-Apple-Silicon | Apple Silicon DMG |
| macOS-Intel | Intel Mac DMG |
| Linux | Linux x64 AppImage |
| iPhone-iPad | Unsigned iPhone/iPad IPA |

Installation notes, source and SHA-256 checksums are included in the ZIP. These apps display the live RKA Prints website and require internet access.

**The IPA cannot be installed directly as supplied.** It requires Apple signing and provisioning. Windows is unsigned; Mac builds use ad-hoc signing and are not notarized. Device testing, including sign-in, remains pending.

## Download with verification

With Python 3 installed, run from the repository root:

```sh
python3 release-assets/experimental/download.py
```

The script saves the ZIP into this folder only after checking its size and SHA-256 digest. It does not install or execute any app. Alternatively, download using the link above and compare the digest recorded in [bundle.json](bundle.json).

The installer ZIP is hosted in GitHub Releases rather than committed to Git. Source and detailed instructions are in [../../experimental/](../../experimental/). See [the release page](https://github.com/RKA-PRINTS/RKA-Prints-Android/releases/tag/experimental-apps-5) for release assets.
