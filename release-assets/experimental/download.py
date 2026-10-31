#!/usr/bin/env python3
"""Download the published experimental bundle and verify its integrity."""
import hashlib
import json
from pathlib import Path
import tempfile
import urllib.request

def main():
    root = Path(__file__).resolve().parent
    manifest = json.loads((root / "bundle.json").read_text(encoding="utf-8"))
    destination = root / manifest["filename"]
    if destination.exists():
        raise SystemExit(f"Already exists: {destination}. Move it before downloading again.")
    temporary = None
    try:
        digest = hashlib.sha256()
        size = 0
        request = urllib.request.Request(manifest["url"], headers={"User-Agent": "RKA-Prints-Bundle-Downloader"})
        with tempfile.NamedTemporaryFile(dir=root, suffix=".part", delete=False) as output:
            temporary = Path(output.name)
            with urllib.request.urlopen(request, timeout=60) as response:
                while chunk := response.read(1024 * 1024):
                    output.write(chunk)
                    digest.update(chunk)
                    size += len(chunk)
        if size != manifest["size_bytes"] or digest.hexdigest() != manifest["sha256"]:
            raise SystemExit("Verification failed; the download will be removed.")
        temporary.replace(destination)
        print(f"Verified download: {destination}")
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)

if __name__ == "__main__":
    main()
