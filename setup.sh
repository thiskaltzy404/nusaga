#!/usr/bin/env bash
set -e
mkdir -p www && cp index.html www/index.html
npm init -y > /dev/null
npm i @capacitor/core@8 @capacitor/cli@8 @capacitor/android@8 @capacitor/geolocation@8
echo '{"appId":"id.nusaga.app","appName":"Nusaga","webDir":"www","plugins":{"CapacitorHttp":{"enabled":true},"SystemBars":{"style":"LIGHT"}}}' > capacitor.config.json
npx cap add android
# izin lokasi
M=android/app/src/main/AndroidManifest.xml
sed -i 's#<application#<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />\n    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n    <application#' "$M"
# ikon aplikasi (dilewati kalau gagal)
mkdir -p assets && cp icon.png assets/icon-only.png
npm i -D @capacitor/assets || true
npx capacitor-assets generate --android --iconBackgroundColor '#2E7D32' --iconBackgroundColorDark '#2E7D32' || echo "ikon dilewati"
# kunci tetap supaya APK baru bisa menimpa yang lama
mkdir -p ~/.android && cp debug.keystore ~/.android/debug.keystore
npx cap sync android
