#!/usr/bin/env bash
# Native Android SDK build; no Gradle or third-party Android runtime libraries.
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$PWD"
: "${ANDROID_SDK_ROOT:=${ANDROID_HOME:-}}"
: "${ANDROID_SDK_ROOT:?Set ANDROID_SDK_ROOT or ANDROID_HOME to the Android SDK}"
TOOLS="$ANDROID_SDK_ROOT/build-tools/${BUILD_TOOLS_VERSION:-35.0.0}"
PLATFORM="$ANDROID_SDK_ROOT/platforms/android-35/android.jar"
OUT="${OUTPUT_DIR:-$ROOT/dist}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
for tool in aapt2 d8 zipalign apksigner; do
  [[ -x "$TOOLS/$tool" ]] || { echo "Missing Android build tool: $tool" >&2; exit 1; }
done
[[ -f "$PLATFORM" ]] || { echo 'Install Android SDK platform 35.' >&2; exit 1; }
command -v java >/dev/null
command -v python3 >/dev/null
if [[ -n "${ECJ_JAR:-}" ]]; then
  [[ -f "$ECJ_JAR" ]] || { echo 'ECJ_JAR does not exist.' >&2; exit 1; }
else
  command -v javac >/dev/null || { echo 'Install JDK 17 or set ECJ_JAR.' >&2; exit 1; }
fi
SIGNED=false
if [[ -n "${KEYSTORE_PATH:-}" ]]; then
  [[ -f "$KEYSTORE_PATH" ]] || { echo 'KEYSTORE_PATH does not exist.' >&2; exit 1; }
  : "${KEYSTORE_PASSWORD:?Set KEYSTORE_PASSWORD}"
  : "${KEY_ALIAS:?Set KEY_ALIAS}"
  export KEYSTORE_PASSWORD
  SIGNED=true
fi
VARIANTS=(Samsung Google Generic)
if [[ $# -gt 0 ]]; then VARIANTS=("$1"); fi
for VARIANT in "${VARIANTS[@]}"; do
  case "$VARIANT" in Samsung|Google|Generic) ;; *) echo 'Variant must be Samsung, Google or Generic.' >&2; exit 1;; esac
  FILE_VARIANT="$VARIANT"
  if [[ "$VARIANT" == Generic ]]; then FILE_VARIANT=Android; fi
  BUILD="$ROOT/build/$VARIANT"
  # Remove only this generated variant directory, never an external output folder.
  rm -rf "$BUILD"
  mkdir -p "$BUILD/classes" "$BUILD/dex" "$BUILD/generated"
  cp -R res "$BUILD/res"
  cp -R "variants/$VARIANT/res/." "$BUILD/res/"
  "$TOOLS/aapt2" compile --dir "$BUILD/res" -o "$BUILD/resources.zip"
  "$TOOLS/aapt2" link -o "$BUILD/base.apk" --manifest AndroidManifest.xml -I "$PLATFORM" -A assets --java "$BUILD/generated" "$BUILD/resources.zip"
  SOURCES=(src/app/rkaprints/wrapper/MainActivity.java "$BUILD/generated/app/rkaprints/wrapper/R.java")
  if [[ -n "${ECJ_JAR:-}" ]]; then
    java -jar "$ECJ_JAR" -8 -proc:none -nowarn -bootclasspath "$PLATFORM:$TOOLS/core-lambda-stubs.jar" -d "$BUILD/classes" "${SOURCES[@]}"
  else
    javac -encoding UTF-8 -source 8 -target 8 -bootclasspath "$PLATFORM:$TOOLS/core-lambda-stubs.jar" -d "$BUILD/classes" "${SOURCES[@]}"
  fi
  python3 - "$BUILD" <<'PY'
import pathlib, sys, zipfile
root = pathlib.Path(sys.argv[1])
with zipfile.ZipFile(root / 'classes.jar', 'w') as archive:
    for path in sorted((root / 'classes').rglob('*.class')):
        archive.write(path, path.relative_to(root / 'classes'))
PY
  "$TOOLS/d8" --min-api 23 --lib "$PLATFORM" --output "$BUILD/dex" "$BUILD/classes.jar"
  cp "$BUILD/base.apk" "$BUILD/unsigned.apk"
  python3 - "$BUILD" <<'PY'
import pathlib, sys, zipfile
root = pathlib.Path(sys.argv[1])
with zipfile.ZipFile(root / 'unsigned.apk', 'a') as archive:
    for path in sorted((root / 'dex').glob('*.dex')):
        archive.write(path, path.name)
PY
  "$TOOLS/zipalign" -f -p 4 "$BUILD/unsigned.apk" "$BUILD/aligned.apk"
  if [[ "$SIGNED" == true ]]; then
    SIGN_ARGS=(--ks "$KEYSTORE_PATH" --ks-pass env:KEYSTORE_PASSWORD --ks-key-alias "$KEY_ALIAS")
    if [[ -n "${KEY_PASSWORD:-}" ]]; then
      export KEY_PASSWORD
      SIGN_ARGS+=(--key-pass env:KEY_PASSWORD)
    fi
    APK="$OUT/RKA-Prints-$FILE_VARIANT.apk"
    "$TOOLS/apksigner" sign "${SIGN_ARGS[@]}" --out "$APK" "$BUILD/aligned.apk"
    "$TOOLS/apksigner" verify --verbose "$APK"
  else
    APK="$OUT/RKA-Prints-$FILE_VARIANT-unsigned.apk"
    cp "$BUILD/aligned.apk" "$APK"
  fi
  "$TOOLS/zipalign" -c 4 "$APK"
  echo "Built $APK"
done
