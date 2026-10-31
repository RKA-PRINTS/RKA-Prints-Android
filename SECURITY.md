# Security

These wrappers display remote website content. Security-sensitive changes include navigation validation, native permissions, cookie handling, downloads, dependency updates and signing workflows.

## Reporting a concern

Do not post credentials, customer information or sensitive exploit details in public issues. If GitHub private vulnerability reporting is enabled, use the repository's Security tab to submit a private report. Otherwise, contact a repository maintainer privately to arrange a reporting channel before sharing sensitive details.

For ordinary defects without sensitive information, open an issue with reproducible steps and redacted logs.

## Distribution boundaries

Signing material belongs in private storage or CI secrets. Experimental Windows builds are unsigned; Mac builds use ad-hoc signing without notarization; the iPhone/iPad IPA requires signing and provisioning. Verify release checksums and consult the platform installation guide.
