#!/bin/bash
set -euo pipefail

# Оновлює GeoComply SDK з архіву Skillz iOS SDK (Developer Console → Downloads).
# Skillz через CocoaPods (2026.x) вимагає GeocomplySDKs з того ж релізу, що й zip-архів.
#
# Використання:
#   ./Scripts/update_geocomply_from_skillz_sdk.sh ~/Downloads/skillz_ios_2026071

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path-to-skillz_ios_archive>" >&2
  exit 1
fi

ARCHIVE="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Vendor/Skillz/GeocomplySDKs"
TMP="$(mktemp -d)"

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

if [[ ! -f "$ARCHIVE" ]]; then
  echo "Archive not found: $ARCHIVE" >&2
  exit 1
fi

echo "Extracting GeocomplySDKs from $ARCHIVE ..."
tar -xf "$ARCHIVE" -C "$TMP" ./GeocomplySDKs

if [[ ! -d "$TMP/GeocomplySDKs" ]]; then
  echo "GeocomplySDKs folder missing in archive." >&2
  exit 1
fi

GC_BIN=""
GC_REASON_REQUIRED=0
if strings "$ROOT/Pods/Skillz/Skillz.framework/Skillz" 2>/dev/null | grep -q 'GCReasonCode'; then
  GC_REASON_REQUIRED=1
fi

for candidate in \
  "$TMP/GeocomplySDKs/GeoComplySDK.xcframework/ios-arm64/GeoComplySDK.framework/GeoComplySDK" \
  "$TMP/GeocomplySDKs/GeoComplySDK.xcframework/ios-arm64_x86_64-simulator/GeoComplySDK.framework/GeoComplySDK"
do
  if [[ -f "$candidate" ]]; then
    GC_BIN="$candidate"
    break
  fi
done

if [[ -z "$GC_BIN" ]]; then
  echo "ERROR: GeoComplySDK binary not found in archive." >&2
  exit 1
fi

if [[ "$GC_REASON_REQUIRED" -eq 1 ]] && ! nm -gU "$GC_BIN" 2>/dev/null | grep -q 'OBJC_CLASS_\$_GCReasonCode'; then
  echo "ERROR: Installed Skillz pod requires GCReasonCode, but this archive's GeoComplySDK is too old." >&2
  echo "Download the iOS SDK zip that matches your CocoaPods Skillz version (e.g. 2026.0.71)." >&2
  exit 1
fi

rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"
cp -R "$TMP/GeocomplySDKs" "$DEST"

PBXPROJ="$ROOT/BubbleShooter.xcodeproj/project.pbxproj"
if [[ -d "$DEST/GeoComplySDK280.xcframework" ]]; then
  echo "Updating Xcode project: GeoComplySDK2110 → GeoComplySDK280 ..."
  sed -i '' 's/GeoComplySDK2110/GeoComplySDK280/g' "$PBXPROJ"
elif [[ -d "$DEST/GeoComplySDK2110.xcframework" ]]; then
  echo "Archive contains GeoComplySDK2110 (Skillz 2025.x). Pod should stay on 2025.0.50."
else
  echo "WARNING: Unknown GeoComply companion framework; check Embed Frameworks in Xcode." >&2
fi

echo "Done. Installed frameworks:"
ls -1 "$DEST"
echo ""
echo "Next: set Podfile to matching Skillz version, then run: pod install"
