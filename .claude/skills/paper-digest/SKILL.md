---
name: paper-digest
description: 毎朝の論文ダイジェスト担当。PubMed E-utilities（esearch + efetch、APIキーなし）で「皮膚科の新着（過去2日）」「漢方（Kampo 全体・過去2日）」「鍼灸×皮膚（過去30日）」を検索し、日本語3行要約＋「当院の診療でどう使えるか」を付けて papers.html に追記する。「論文ダイジェスト」「今日の論文」「papers.html を更新」と言われたら使う。
---

# 論文ダイジェスト（paper-digest）

やまもと皮膚科・漢方クリニック（姫路・皮膚科＋漢方・鍼灸）の医師が、朝の診療前に iPhone で読む論文ダイジェストを作る手順書。
成果物は `papers.html`（リポジトリ直下・単一 HTML）への **データ追記** だけ。見た目は washi-design に従い、HTML の骨格はいじらない。

## 同梱ファイル

| パス | 用途 |
|---|---|
| `scripts/pubmed.sh` | `pubmed.sh <tag> "<検索式>" <mindate> <maxdate> [retmax] [outdir]` — esearch→efetch を実行し `<tag>.json`（構造化）と `<tag>.txt`（一覧）を出す。`tool=clinic-ai-paper-digest` と `email=`（スクリプト冒頭の変数）を必ず付ける |
| `scripts/dates.sh` | JST の今日・検索範囲を環境変数で出す（`eval "$(scripts/dates.sh)"`） |
| `scripts/parse.py` | efetch XML → JSON。`parse.py <in.xml> <out.json> full` で抄録も表示 |
| `queries/A.txt` | A 皮膚科：疾患・治療キーワード検索式 |
| `queries/A2.txt` | A 皮膚科：主要誌（JAAD / JAMA Derm / BJD / JEADV / J Dermatol / Allergy / JACI / NEJM / Lancet …）の新着 |
| `queries/B.txt` | B 漢方：Kampo / Japanese herbal medicine / 個別方剤名（皮膚に限定しない Kampo 全体） |
| `queries/C.txt` | C 鍼灸×皮膚：acupuncture / moxibustion / acupressure / 耳介 / 刺絡・吸角 × 皮膚疾患・そう痒・帯状疱疹 |

## 絶対に守ること

1. **日付は必ず日本時間（JST）で扱う。** 実行日・検索範囲・`DIGEST` の `date` は全て `TZ=Asia/Tokyo date` で決める。PubMed の日付フィルタは `datetype=edat`（PubMed 登録日）を使う。
2. **APIキーは使わない。** `tool` と `email` パラメータは必ず付ける。連続呼び出しは 1 秒 3 回以内（スクリプト内で sleep 済み）。
3. **医学的内容を自分で足さない。** 要約は抄録に書かれていることだけ。抄録がない論文はタイトルから分かる範囲にとどめ、`note` に「抄録なし（タイトルのみで要約）。原著確認が必要。」と書く。
4. **患者個人情報には一切触れない。**
5. **papers.html の HTML/CSS/JS 本体は変更しない。** 触るのは `DIGEST` 配列（`/* @@DIGEST_TOP@@` の直後）と `DIGEST_UPDATED` だけ。
6. **対話中の git commit / push はユーザーに言われたときだけ。** 例外は毎朝のクラウドルーティン（手順 7 参照）で、そのときは `papers.html` のみをコミットして push する。

## 手順

### 0. 日付を決める（JST）

```bash
eval "$(.claude/skills/paper-digest/scripts/dates.sh)"
echo "$NOW_JST $TODAY $A_MIN $C_MIN"   # NOW_JST=DIGEST_UPDATED 用 / TODAY=maxdate / A_MIN=A・B の mindate（過去2日） / C_MIN=C の mindate（過去30日）
```

（macOS・Linux どちらでも動く。`date -v` や `date -d` は使わない。）
`papers.html` の同じ `date`（`$TODAY_ISO`）の回がすでにあれば、その日は **追記ではなく差し替え**（1 日 1 回分）。

### 1. 既掲載 PMID を集める（C の重複除外用）

```bash
grep -o 'pmid:"[0-9]*"' papers.html | grep -o '[0-9]*' | sort -u > $SCRATCH/seen.txt
```

C は 30 日窓なので、前日までに載せた論文が毎日ヒットする。`seen.txt` にある PMID は **C から除く**。A・B は 2 日窓なので通常重複しないが、同じく除く。

### 2. PubMed を検索する

作業ファイルはスクラッチパッドに置く（リポジトリに残さない）。

```bash
SK=.claude/skills/paper-digest
S=$SK/scripts/pubmed.sh
$S A  "$(cat $SK/queries/A.txt)"  $A_MIN  $TODAY 200 $SCRATCH
$S A2 "$(cat $SK/queries/A2.txt)" $A_MIN  $TODAY 200 $SCRATCH
$S B  "$(cat $SK/queries/B.txt)"  $A_MIN  $TODAY 200 $SCRATCH
$S C  "$(cat $SK/queries/C.txt)"  $C_MIN  $TODAY 200 $SCRATCH
```

各 `<tag>.txt` に「PMID | 登録日 | 誌名 | 年 | 種別 / タイトル」の一覧が出る。抄録は
`python3 $SK/scripts/parse.py $SCRATCH/A.xml $SCRATCH/A.json full` か、`A.json` を Python で読んで PMID 指定で表示する。

**B は皮膚に限定しない Kampo 全体**（過去 2 日で 0〜数本）。0 本の日は items に B を入れない（画面側は空状態を表示する）。無関係にヒットしたもの（"Coix" が食品研究に当たる等）は除く。

### 3. 選ぶ

| 区分 | 本数 | 優先順位 |
|---|---|---|
| A 皮膚科 | 5〜10 本 | ①アトピー性皮膚炎・痒み・乾癬・蕁麻疹・爪白癬・痤瘡・外用療法・生物学的製剤・JAK阻害薬 ②外来診療で明日から使える（患者説明・安全性・疫学・ガイドライン） ③RCT・メタ解析・大規模コホート・総説 ＞ 症例報告・レター ④抄録あり ＞ 抄録なし |
| B 漢方 | あるだけ（上限 5） | Kampo 全体（領域を問わない）。皮膚・そう痒・冷え・のぼせ・副作用報告を優先し、次に臨床研究 ＞ 動物・in vitro |
| C 鍼灸×皮膚 | あるだけ（上限 5） | そう痒・湿疹・帯状疱疹・痤瘡・蕁麻疹など皮膚科領域。プロトコル論文・動物実験は抄録があり示唆が書けるときだけ |

除外：動物・in vitro のみで臨床示唆が書けないもの、獣医、無関係にヒットしたもの（"TJ" が tight junction に当たる等）、抄録なしのレターが多すぎるとき（A で抄録なしは 2 本まで）。

### 4. 書く（各論文）

`DIGEST[0].items` に次の形で足す。**必ずこの 3 行＋一文**。丁寧語、患者に見せても差し支えない表現。数字（例数・HR・%）は抄録のまま書く。

```js
{ cat:"A",                       // "A" | "B" | "C"
  pmid:"42766442", journal:"Cornea", year:2026,
  type:"後方視コホート",          // 総説 / RCT / メタ解析 / コホート / 後方視 / 症例報告 / 症例集積 / レター / 論考 / 動物実験 …
  tj:"日本語の短い見出し（30字前後・数字を入れると読みやすい）",
  te:"英語原題（PubMed のまま）",
  sum:["何を調べたか（対象・方法・規模）",
       "結果（主要な数値をそのまま）",
       "臨床的示唆（著者の結論の範囲で）"],
  use:"当院の診療でどう使えるか（一文。生活指導・当院製品・外用薬・パッチ・食物アレルギー等の既存タブと結びつける）",
  note:"（任意）抄録なし／皮膚領域外 などの注意"
}
```

- `tj` は Claude の意訳で構わないが、原題にない主張を足さない。
- `use` は「〜の根拠になる」「〜と説明する材料になる」「〜のときに疑う」など、明日の外来での使い道を一つだけ。
- 動物実験は `use` の末尾に「ヒトでの効果は未確認と添える」。

### 5. papers.html に入れる

1. `DIGEST_UPDATED` を手順 0 の JST 時刻にする。
2. `/* @@DIGEST_TOP@@ */` の **直後** に新しい回 `{ date:"YYYY-MM-DD", range:{A:"…", B:"…", C:"…"}, items:[…] },` を挿入する（新しい日が上に積み上がる）。`range` は区分ごとの表示用文字列（例 `"2026-09-20〜09-22"`）。
3. 同じ `date` の回がすでにあるなら、その回を丸ごと置き換える。
4. 挿入は Python で行うと安全（`'/* @@DIGEST_TOP@@' ... */` の行を探し、その次の行に文字列を挿入）。手で編集するときは `sed -n` で該当範囲だけ読む。

### 6. 確認

```bash
grep -c 'pmid:"' papers.html   # 収載本数（挿入前より増えていること）。構文エラーはスクリーンショットでカードが出ないことで分かる（この Mac に node はない）
.claude/skills/washi-design/scripts/iphone-shot.sh papers.html 390 1400   # 撮って Read で目視（Google Chrome がある Mac のみ。クラウド実行では省略）
python3 -c "import re,json,sys;s=open('papers.html',encoding='utf-8').read();m=re.search(r'var DIGEST = (\[.*?\n\]);',s,re.S);assert m and s.count('{')==s.count('}') and s.count('[')==s.count(']');print('brackets OK')"   # 括弧の対応だけ機械チェック
grep -o -E "https?://[^\"' )]+" papers.html | grep -v -E "fonts\.g(oogleapis|static)\.com|w3\.org|pubmed\.ncbi\.nlm\.nih\.gov"   # 何も出なければ OK
```

目視項目：新しい日付が一番上／件数バッジ／カードの横はみ出しなし／PubMed リンクが `https://pubmed.ncbi.nlm.nih.gov/<PMID>/`。

### 7. 報告・コミット

ユーザーに、区分ごとの本数・検索範囲（JST）・「該当なし」の区分・抄録なしで要約した論文を簡潔に伝える。

- 対話で実行したとき：**コミットはしない**（頼まれたら下のメッセージでコミット）。
- 毎朝のクラウドルーティン（自動実行）のとき：`papers.html` だけを `git add` し、`papers.html: YYYY-MM-DD の論文ダイジェスト（A n本 / B n本 / C n本）` でコミットして `main` に push する。他のファイルは触らない。push が拒否されたら `git pull --rebase origin main` して再 push。

## papers.html の仕様（変えないこと）

- タブ：皮膚科（A）／漢方（B）／鍼灸×皮膚（C）／あとで読む。URL ハッシュ `#a #b #c #later`。
- 区分色：A=朱、B=藍、C=松葉（カード左端の `.catband`）。
- localStorage：`papers_read_v1`（既読 pmid→日時）、`papers_later_v1`（あとで読む）、`papers_state_v1`（タブ・フィルタ）。
- 免責：「要約は抄録に基づく Claude の作成で、原著の確認を前提とします。診療方針の最終判断は医師が行います。」
