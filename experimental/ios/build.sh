#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ "$(uname -s)" == Darwin ]] || { echo 'Build requires macOS and Xcode.' >&2; exit 1; }
ROOT="$PWD"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
BUILD="$ROOT/build/unsigned-ios"
rm -rf "$BUILD"
APP="$BUILD/Payload/RKAPrintsExperimental.app"
mkdir -p "$APP"
cp Info.plist "$APP/Info.plist"
xcrun --sdk iphoneos swiftc -sdk "$SDK" -target arm64-apple-ios15.0 -module-name RKAPrintsExperimental -parse-as-library -O -whole-module-optimization -framework UIKit -framework WebKit -Xlinker -rpath -Xlinker @executable_path/Frameworks App.swift -o "$APP/RKAPrintsExperimental"
python3 prepare-icons.py
xcrun actool Assets.xcassets --compile "$APP" --platform iphoneos --minimum-deployment-target 15.0 --target-device iphone --target-device ipad --app-icon AppIcon --output-partial-info-plist "$BUILD/asset-info.plist" --output-format human-readable-text
python3 - "$APP/Info.plist" "$BUILD/asset-info.plist" <<'PY'
import plistlib, sys
with open(sys.argv[1], 'rb') as f: info = plistlib.load(f)
with open(sys.argv[2], 'rb') as f: info.update(plistlib.load(f))
with open(sys.argv[1], 'wb') as f: plistlib.dump(info, f)
PY
plutil -lint "$APP/Info.plist"
file "$APP/RKAPrintsExperimental"
# Deliberately no signing or provisioning profile: this is a developer build.
(cd "$BUILD" && /usr/bin/zip -qry "$OUTPUT_DIR/RKA-Prints-iPhone-iPad-UNSIGNED.ipa" Payload)
shasum -a 256 "$OUTPUT_DIR/RKA-Prints-iPhone-iPad-UNSIGNED.ipa"
echo 'Unsigned IPA generated. It cannot be installed normally without Apple signing/provisioning.'
