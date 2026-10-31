# Contributing

RKA Prints Apps provides small wrappers around the hosted RKA Prints website. Keep contributions focused on navigation, platform integration, accessibility, packaging and documentation.

## Before making a change

Read the relevant platform guide and check existing issues and pull requests. Report website-content problems separately from wrapper defects. Include the operating system, app version, expected behavior and reproducible steps.

## Development workflow

1. Create a branch from the current target branch.
2. Make a focused change using the existing style and architecture.
3. Run the relevant checks described in AGENTS.md and the platform guide.
4. Update documentation for changed behavior or installation steps.
5. Open a pull request describing the change, validation and remaining limitations.

Use the checked-in dependency lockfile. Avoid unrelated dependency upgrades or generated asset changes. Public contributions must not contain private website source, personal data or signing material.

## Testing experimental apps

Check website loading, sign-in, back/forward navigation, external links, file selection, downloads, window resizing, appearance and restart behavior. Record device and OS details. Build success alone is not device acceptance.

## Distribution

Maintainers publish releases through the documented release process. Experimental downloads remain prereleases until platform testing and distribution requirements are satisfied. Do not promise store approval or trusted publisher status for unsigned builds.
