# Agent guide

## Scope and purpose

This is the public RKA Prints app-wrapper repository. Every app opens https://rkaprints.web.app. It is not the website source repository and must not contain private website code or customer data.

Android is the stable distribution. Desktop and iPhone/iPad wrappers under experimental/ are experimental. Preserve that distinction in documentation, release labels and download links. Read README.md, CONTRIBUTING.md and the platform guide before editing.

## Repository map

- Android: AndroidManifest.xml, src/, res/, variants/, build.sh.
- Branding: assets/rka-app-icon.svg and scripts/generate-icons.py.
- Desktop: experimental/desktop/; Electron with pinned dependencies.
- iPhone/iPad: experimental/ios/; Swift, UIKit and WKWebView.
- Releases: .github/workflows/ and docs/RELEASING.md.

## Public-repository requirements

Never commit signing keys, passwords, tokens, provisioning profiles, private source archives, customer records or unredacted account logs. Use CI secrets for signing. Do not copy files from the private website repository to provide context.

Use factual public documentation. Distinguish compilation, package verification and device testing. Do not claim universal theme support, successful authentication, App Store approval or production signing without evidence.

## Implementation rules

Preserve package identifiers and signing continuity for updates. Keep Android editions on the same implementation; use resources for icon differences. Preserve adaptive and monochrome icon support and use the existing logo.

Keep remote website content isolated from native privileges. Desktop code must retain sandboxing, context isolation and disabled Node integration. Validate navigation destinations and external URL schemes. Do not bypass identity-provider restrictions, TLS checks or OS installation protections.

Keep changes focused and readable. Do not reformat generated lockfiles, modify installer binaries or regenerate artwork solely for cosmetic consistency. Update affected documentation when behavior or build commands change.

## Validation

- Android changes: run bash build.sh with the documented SDK; verify release signatures only with authorized signing material.
- Desktop changes: run npm ci and npm test in experimental/desktop; package on the relevant OS when packaging changes.
- iOS changes: run bash experimental/ios/build.sh on a Mac with Xcode.
- Documentation/workflow changes: check paths, commands, YAML and archive contents as applicable.
- Never describe unavailable device tests as completed. Record what was tested and what remains pending.

## Releases and pull requests

Follow docs/RELEASING.md. Publishing is a deliberate maintainer action. Experimental releases must remain prereleases and must not replace the stable Android latest release. Keep existing download filenames and website links compatible.

Write PR descriptions around the final changes, validation and material limitations. Do not merge, rename or archive the repository unless that action is included in the user's request. Repository guidance does not override the user's explicit authorization.
