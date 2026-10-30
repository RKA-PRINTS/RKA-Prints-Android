# Release setup

Publish APK files in this **public app repository's GitHub Releases**. Keep the linked website source repository private. A public web page cannot offer anonymous downloads from private GitHub Releases.

## Upload an existing release

1. In `RKA-PRINTS/RKA-Prints-Android`, choose **Releases → Draft a new release**.
2. Create tag `v1.2.0`, title `RKA Prints Android 1.2`, and use `RELEASE_NOTES.md` for the description.
3. Attach `RKA-Prints-Samsung.apk`, `RKA-Prints-Google.apk`, `RKA-Prints-Android.apk` and `SHA256SUMS.txt`.
4. Publish it as the latest release. Do not mark it as a prerelease if using the `/releases/latest/download/` URLs.

The website should link to the stable URLs in the README. Future releases retain the same APK filenames, so the links continue to work.

## Build and publish manually from GitHub Actions

In repository **Settings → Secrets and variables → Actions**, add:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64 of the original private signing keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Signing key alias |
| `ANDROID_KEY_PASSWORD` | Optional separate key password |

Keep signing keys outside the repository. Public source archives must exclude all keystores, passwords and other signing material.

Update the version code and version name in `AndroidManifest.xml` and the release notes before a new version. Push the reviewed change, then choose **Actions → Publish signed APKs → Run workflow** and enter an unused release tag. This manual workflow builds all three editions, verifies signatures, writes checksums and publishes a release. It never runs on pull requests or automatically on a push.

After publishing, open each stable download URL in a browser that is not signed into GitHub. Confirm that it downloads an APK and that the website's download buttons use the same URLs.
