#!/bin/sh
# Rebuild fonts/GoogleSansFlex-subset.woff2 from an installed Google Sans Flex.
#
#   pip install fonttools brotli
#   sh tools/build-font.sh ~/Library/Fonts/GoogleSansFlex-VariableFont_*.ttf
#
# Pins every axis to the font's own default except weight — opsz included, so
# the browser cannot derive an optical size from a font-size that is really a
# video pixel measurement at a 5.35x zoom. Then subsets to the glyphs used.
set -e
SRC="${1:?usage: build-font.sh <GoogleSansFlex-VariableFont...ttf>}"
OUT="fonts/GoogleSansFlex-subset.woff2"
TMP="$(mktemp -d)"

python3 - "$SRC" "$TMP/pinned.ttf" <<'PY'
import sys
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
f = instantiateVariableFont(TTFont(sys.argv[1]),
        {"wdth": 100, "GRAD": 0, "ROND": 0, "slnt": 0, "opsz": 18},
        inplace=False, updateFontNames=False)
f.save(sys.argv[2])
print("axes left:", [a.axisTag for a in f["fvar"].axes])
PY

printf ' (),.345ABFGIMRSVWabcdefghiklmnopqrstuvwy\342\200\234\342\200\235' > "$TMP/chars.txt"
python3 -m fontTools.subset "$TMP/pinned.ttf" \
  --text-file="$TMP/chars.txt" \
  --layout-features='kern,liga,calt,ccmp,locl,mark,mkmk' \
  --flavor=woff2 --output-file="$OUT"

rm -rf "$TMP"
ls -l "$OUT"
echo "now re-embed it: the base64 of this file lives in index.html's @font-face"
