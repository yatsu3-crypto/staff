#!/bin/bash
# iPhone幅で単一HTMLアプリを描画してスクリーンショットを撮る。
# 使い方: iphone-shot.sh <html path> [width=390] [height=844] [out png]
# Chrome はウィンドウ最小幅(約500px)の制約があるため、iframe で幅を固定して描画する。
set -e
HTML="$1"; W="${2:-390}"; H="${3:-844}"
[ -z "$HTML" ] && { echo "usage: $0 <html> [width] [height] [out.png]" >&2; exit 1; }
HTML="$(cd "$(dirname "$HTML")" && pwd)/$(basename "$HTML")"
OUT="${4:-${TMPDIR:-/tmp}/iphone-shot-$(basename "$HTML" .html)-${W}x${H}.png}"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "Google Chrome が見つかりません: $CHROME" >&2; exit 1; }
WRAP="$(mktemp -t washi-frame).html"
cat > "$WRAP" <<HTML
<!DOCTYPE html><meta charset="utf-8"><body style="margin:0;background:#888">
<iframe src="file://$HTML" style="width:${W}px;height:${H}px;border:0;display:block"></iframe>
HTML
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=4000 \
  --window-size="$W,$H" --screenshot="$OUT" "file://$WRAP" >/dev/null 2>&1
rm -f "$WRAP"
echo "$OUT"
