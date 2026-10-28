#!/bin/bash
set -euo pipefail

# Builds a unique App Store IPA for Skillz + TestFlight.
# Run on the signing Mac (Alena): ./Scripts/export_appstore_ipa.sh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ARCHIVE_PATH="${ROOT}/build/BubbleShooter.xcarchive"
EXPORT_DIR="${ROOT}/build/ipa-export"
EXPORT_OPTIONS="${ROOT}/build/ExportOptions-AppStore.plist"

mkdir -p "${ROOT}/build"
rm -rf "$ARCHIVE_PATH" "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

cat > "$EXPORT_OPTIONS" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>destination</key>
	<string>export</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>manageAppVersionAndBuildNumber</key>
	<false/>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>QC9K654M6G</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
EOF

echo "==> pod install"
pod install

echo "==> archive"
xcodebuild \
  -workspace BubbleShooter.xcworkspace \
  -scheme BubbleShooter \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  manageAppVersionAndBuildNumber=NO \
  archive | xcpretty || xcodebuild \
  -workspace BubbleShooter.xcworkspace \
  -scheme BubbleShooter \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  archive

echo "==> export IPA"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

IPA="$(ls -1 "$EXPORT_DIR"/*.ipa | head -1)"
echo "==> verifying $IPA"

TMP="$(mktemp -d)"
unzip -q "$IPA" -d "$TMP"
echo "Bundle: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$TMP/Payload/BubbleShooter.app/Info.plist")"
echo "Version: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$TMP/Payload/BubbleShooter.app/Info.plist")"
echo "Build: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$TMP/Payload/BubbleShooter.app/Info.plist")"

if ! unzip -l "$IPA" | grep -q 'GCSDKDomain.framework/GCSDKDomain'; then
  echo "ERROR: GCSDKDomain missing from IPA" >&2
  exit 1
fi
echo "GCSDKDomain: OK"

if codesign -dv "$TMP/Payload/BubbleShooter.app/Frameworks/Skillz.framework" 2>&1 | grep -q 'not signed'; then
  echo "ERROR: Skillz.framework is unsigned" >&2
  exit 1
fi
echo "Skillz codesign: OK"
echo "SHA256: $(shasum -a 256 "$IPA" | awk '{print $1}')"
echo ""
echo "DONE. IPA ready: $IPA"
echo "Upload to https://developers.skillz.com (WITH s) as version 1.0.5"
echo "Then upload same IPA to TestFlight."
rm -rf "$TMP"
