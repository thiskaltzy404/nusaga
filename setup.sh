#!/usr/bin/env bash
set -e
mkdir -p www && cp index.html www/index.html
npm init -y > /dev/null
npm i @capacitor/core@8 @capacitor/cli@8 @capacitor/android@8 @capacitor/geolocation@8 @capacitor/local-notifications@8
echo '{"appId":"id.nusaga.app","appName":"Nusaga","webDir":"www","plugins":{"CapacitorHttp":{"enabled":true},"SystemBars":{"style":"LIGHT"},"LocalNotifications":{"smallIcon":"ic_stat_nusaga"}}}' > capacitor.config.json
npx cap add android
# izin lokasi
M=android/app/src/main/AndroidManifest.xml
sed -i 's#<application#<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />\n    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n    <application#' "$M"
# ikon aplikasi (dibuat sendiri; dilewati kalau gagal)
pip install pillow -q || true
python3 - <<'PY' || echo "ikon dilewati"
from PIL import Image, ImageDraw
import os
ic=Image.open('icon.png').convert('RGBA')
R='android/app/src/main/res'
for d,(l,f) in {'mdpi':(48,108),'hdpi':(72,162),'xhdpi':(96,216),'xxhdpi':(144,324),'xxxhdpi':(192,432)}.items():
    p=f'{R}/mipmap-{d}'
    os.makedirs(p,exist_ok=True)
    ic.resize((l,l),Image.LANCZOS).save(f'{p}/ic_launcher.png')
    k=int(l*.8);g=ic.resize((k,k),Image.LANCZOS)
    bg=Image.new('RGBA',(l,l),(46,125,50,255));bg.paste(g,((l-k)//2,(l-k)//2),g)
    m=Image.new('L',(l,l),0);ImageDraw.Draw(m).ellipse((0,0,l-1,l-1),fill=255)
    r=Image.new('RGBA',(l,l),(0,0,0,0));r.paste(bg,(0,0),m);r.save(f'{p}/ic_launcher_round.png')
    s=int(f*.62);g=ic.resize((s,s),Image.LANCZOS)
    fg=Image.new('RGBA',(f,f),(0,0,0,0));fg.paste(g,((f-s)//2,(f-s)//2),g);fg.save(f'{p}/ic_launcher_foreground.png')
os.makedirs(f'{R}/values',exist_ok=True)
open(f'{R}/values/ic_launcher_background.xml','w').write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#2E7D32</color>\n</resources>\n')
os.makedirs(f'{R}/mipmap-anydpi-v26',exist_ok=True)
x='<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n    <background android:drawable="@color/ic_launcher_background"/>\n    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n</adaptive-icon>\n'
for n in ('ic_launcher','ic_launcher_round'): open(f'{R}/mipmap-anydpi-v26/{n}.xml','w').write(x)
# ikon kecil notifikasi (siluet putih)
for d,z in {'mdpi':24,'hdpi':36,'xhdpi':48,'xxhdpi':72,'xxxhdpi':96}.items():
    q=ic.resize((z,z),Image.LANCZOS);px=q.load();o=Image.new('RGBA',(z,z),(0,0,0,0));op=o.load()
    for x in range(z):
        for y in range(z):
            r,g,b,a=px[x,y]
            if a>40 and min(r,g,b)>185: op[x,y]=(255,255,255,255)
    os.makedirs(f'{R}/drawable-{d}',exist_ok=True);o.save(f'{R}/drawable-{d}/ic_stat_nusaga.png')
print('ikon dibuat')
PY
# kunci tetap supaya APK baru bisa menimpa yang lama
mkdir -p ~/.android && cp debug.keystore ~/.android/debug.keystore
npx cap sync android
