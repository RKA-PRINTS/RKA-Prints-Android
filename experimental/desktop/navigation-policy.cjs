'use strict';
const HOME = 'https://rkaprints.web.app/';

function parseSafeUrl(value) {
  if (typeof value !== 'string' || /[\u0000-\u001f\u007f]/.test(value)) return null;
  try {
    const url = new URL(value);
    return url.username || url.password ? null : url;
  } catch { return null; }
}

function isInternalUrl(value) {
  const url = parseSafeUrl(value);
  return !!url && url.origin === new URL(HOME).origin;
}

function isExternalUrl(value) {
  const url = parseSafeUrl(value);
  if (!url) return false;
  if (url.protocol === 'https:' || url.protocol === 'http:') return !!url.hostname;
  if (url.protocol === 'mailto:') return !/%0[ad]/i.test(value) && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(url.pathname);
  if (url.protocol === 'tel:') return /^[+\d(). -]+$/.test(url.pathname) && /\d/.test(url.pathname) && !url.search;
  return false;
}

module.exports = { HOME, isInternalUrl, isExternalUrl };
