#!/bin/bash
# PubMed E-utilities（esearch → efetch）で論文を取得し、<tag>.json と <tag>.txt を作る。
# 使い方: pubmed.sh <tag> "<検索式>" <mindate YYYY/MM/DD> <maxdate YYYY/MM/DD> [retmax=200] [outdir=.]
#   例:  pubmed.sh A "$(cat queries/A.txt)" 2026/09/20 2026/09/22 200 /path/to/scratch
# APIキーなし。tool / email は NCBI のマナーとして必ず付ける（下の変数を変える）。
# 連続呼び出しは 1 秒に 3 回まで。sleep を挟んである。
set -e
TAG="$1"; Q="$2"; MIN="$3"; MAX="$4"; N="${5:-200}"; OUT="${6:-.}"
[ -z "$MAX" ] && { echo "usage: $0 <tag> <query> <mindate> <maxdate> [retmax] [outdir]" >&2; exit 1; }
TOOL="clinic-ai-paper-digest"
EMAIL="y.atsu3@gmail.com"     # クリニックの連絡先メール（NCBI が問い合わせに使う）
BASE="https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUT"

curl -s -G "$BASE/esearch.fcgi" \
  --data-urlencode "db=pubmed" --data-urlencode "term=$Q" \
  --data-urlencode "datetype=edat" --data-urlencode "mindate=$MIN" --data-urlencode "maxdate=$MAX" \
  --data-urlencode "retmax=$N" --data-urlencode "retmode=json" --data-urlencode "sort=date" \
  --data-urlencode "tool=$TOOL" --data-urlencode "email=$EMAIL" > "$OUT/$TAG.search.json"

IDS=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1]))["esearchresult"]; print(",".join(d["idlist"])); sys.stderr.write("%s: count=%s returned=%d\n"%(sys.argv[2],d["count"],len(d["idlist"])))' "$OUT/$TAG.search.json" "$TAG")
if [ -z "$IDS" ]; then echo "[]" > "$OUT/$TAG.json"; : > "$OUT/$TAG.txt"; exit 0; fi
sleep 0.4
curl -s -G "$BASE/efetch.fcgi" \
  --data-urlencode "db=pubmed" --data-urlencode "id=$IDS" --data-urlencode "retmode=xml" \
  --data-urlencode "tool=$TOOL" --data-urlencode "email=$EMAIL" > "$OUT/$TAG.xml"
python3 "$HERE/parse.py" "$OUT/$TAG.xml" "$OUT/$TAG.json" > "$OUT/$TAG.txt"
echo "$OUT/$TAG.txt"
