#!/bin/bash
# 日本時間（JST）で今日と検索範囲を出す。macOS / Linux 両対応（python3 で計算）。
# 使い方: eval "$(scripts/dates.sh)"  →  NOW_JST / TODAY_ISO / TODAY / A_MIN / C_MIN が入る
python3 - <<'PY'
from datetime import datetime, timedelta, timezone
JST = timezone(timedelta(hours=9))
now = datetime.now(JST)
print('NOW_JST="%s"'   % now.strftime('%Y-%m-%d %H:%M JST'))
print('TODAY_ISO="%s"' % now.strftime('%Y-%m-%d'))
print('TODAY="%s"'     % now.strftime('%Y/%m/%d'))
print('A_MIN="%s"'     % (now - timedelta(days=2)).strftime('%Y/%m/%d'))   # A・B: 過去2日
print('C_MIN="%s"'     % (now - timedelta(days=30)).strftime('%Y/%m/%d'))  # C: 過去30日
print('A_RANGE="%s〜%s"' % ((now - timedelta(days=2)).strftime('%Y-%m-%d'), now.strftime('%m-%d')))
print('C_RANGE="%s〜%s"' % ((now - timedelta(days=30)).strftime('%Y-%m-%d'), now.strftime('%m-%d')))
PY
