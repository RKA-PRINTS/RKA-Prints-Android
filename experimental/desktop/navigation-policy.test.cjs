const test = require('node:test');
const assert = require('node:assert/strict');
const { HOME, isInternalUrl, isExternalUrl } = require('./navigation-policy.cjs');

test('website routes remain inside the wrapper', () => {
  for (const url of [HOME, HOME + 'shop#store', HOME + 'downloads', HOME + 'shop?item=42']) assert.equal(isInternalUrl(url), true);
});
test('lookalikes, different ports, credentials and insecure origins cannot become internal', () => {
  for (const url of ['http://rkaprints.web.app', 'https://rkaprints.web.app.evil.test', 'https://rkaprints.web.app:8443', 'https://evil.test@rkaprints.web.app', 'https://rkaprints.web.app@evil.test', '//rkaprints.web.app', 'https://rkaprints.web.app\n.evil.test']) assert.equal(isInternalUrl(url), false, url);
});
test('ordinary browser and contact links are supported externally', () => {
  for (const url of ['https://github.com/RKA-PRINTS/RKA-Prints-Android/releases', 'http://example.com', 'mailto:hello@example.com?subject=Print', 'tel:+971501234567']) assert.equal(isExternalUrl(url), true, url);
});
test('dangerous OS schemes and malformed links never reach the shell', () => {
  for (const url of ['javascript:alert(1)', 'file:///etc/passwd', 'data:text/html,hello', 'intent://app', 'ms-excel:ofe|u|https://example.com', 'https://name:pass@example.com', 'mailto:user@example.com?subject=%0aInjected', 'tel:hello', 'not a URL', '', null]) assert.equal(isExternalUrl(url), false, String(url));
});
