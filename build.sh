#!/bin/bash
set -e
DECRYPTED_IPA="$1"
OUT_NAME="${2:-TikTok}"
mkdir -p packages

echo "==> Building TikTok tweak dylib"
make clean >/dev/null 2>&1 || true
rm -rf .theos
make package FINALPACKAGE=1
DYLIB=$(find .theos/obj -name 'BHTikTok.dylib' -not -path '*dSYM*' | head -1)
if [ -z "$DYLIB" ]; then echo "ERROR: BHTikTok.dylib not built"; exit 1; fi
echo "dylib: $DYLIB"

echo "==> Fetching CydiaSubstrate framework"
curl -sL "https://github.com/BandarHL/BHInstagram/releases/download/1.2/bhinsta_sideloaded.ipa" -o /tmp/official.ipa
rm -rf /tmp/deps && mkdir -p /tmp/deps
unzip -oq /tmp/official.ipa "Payload/Instagram.app/Frameworks/CydiaSubstrate.framework/*" -d /tmp/deps
DEPS=/tmp/deps/Payload/Instagram.app/Frameworks

echo "==> Injecting into decrypted TikTok IPA via cyan"
cyan -i "$DECRYPTED_IPA" -o "packages/${OUT_NAME}.ipa" --ignore-encrypted -uwf \
  "$DYLIB" "$DEPS/CydiaSubstrate.framework"
echo "Done: packages/${OUT_NAME}.ipa"
