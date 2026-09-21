---
name: washi-design
description: やまもと皮膚科・漢方クリニックの「和紙デザインシステム」（朱・金茶・松葉・藍、Shippori Mincho + Zen Kaku Gothic、マスコット「たんぽぽちゃん」）。院内向け単一HTMLアプリや患者向け印刷物を作る・直すときに必ず読む。配色トークン、フォント、レイアウト、コンポーネントのCSSをそのまま再利用できる形で定義している。
---

# 和紙デザインシステム（washi-design）

姫路・やまもと皮膚科・漢方クリニックのアプリ群に共通する見た目の仕様書。
`index.html` の「パッチテスト」画面と「患者用パンフレット」から逆算して正典化した。
**新規アプリはこの仕様から外れないこと。迷ったら `templates/starter.html` をコピーして始める。**

## 同梱ファイル

| パス | 用途 |
|---|---|
| `templates/starter.html` | 全トークン・全コンポーネントを含む最小アプリ。新規アプリはここから複製する |
| `assets/tampopo.png` | マスコット「たんぽぽちゃん」本体（360×430 PNG, 48KB）。base64で埋め込んで使う |
| `assets/tampopo-icon.svg` | ヘッダー用の線画アイコン（48×48）。インラインSVGで使う |
| `scripts/iphone-shot.sh` | `iphone-shot.sh <html> [幅] [高さ] [出力png]` — Chromeヘッドレスで iPhone 幅の描画を撮る |

## 1. 思想

- **和紙の上に墨で書く**：背景はクリーム色の和紙 `--washi`、文字は墨 `--sumi`。真っ白 `#fff` を大面積に使わない。
- **色は4色の役割分担で使う**：朱＝注意・選択、金茶＝アクセント、松葉＝クリニック・肯定、藍＝操作。装飾で色を増やさない。
- **見出しは明朝、本文はゴシック**：Shippori Mincho（見出し・数字の強調・クリニック名）と Zen Kaku Gothic New（本文・UI）。
- **診察室で片手で使える**：iPhone 幅で1カラム、タップ領域 44px 以上、入力欄は 16px 以上（iOS の自動ズーム防止）。
- **たんぽぽちゃんが必ずどこかにいる**：ヘッダーのアイコンか、フッター／パンフレットの一言メッセージ。

## 2. デザイントークン（`:root` にそのまま貼る）

```css
:root{
  --washi:#FBF5E6;   /* 画面背景（和紙） */
  --washi-d:#F2E9D2; /* 背景の濃い面・押下時の面 */
  --card:#FFFCF4;    /* カード・入力欄の面（背景よりわずかに明るい） */
  --line:#D9CDB3;    /* 罫線・枠線 */
  --sumi:#332C25;    /* 本文（墨） */
  --sumi2:#5B5247;   /* 補足テキスト */
  --usu:#8C8073;     /* 薄墨: キャプション・プレースホルダ・ページ番号 */
  --shu:#C1432E;     /* 朱: 強調・警告・選択中チップ・削除 */
  --shu-d:#9A3A2E;   /* 朱の濃色: ノート内の太字 */
  --kin:#C08A22;     /* 金茶: アクセント・フォーカスリング・数値・二重罫線 */
  --kin-d:#8A6410;   /* 金茶の濃色: 小見出し文字（明るい金茶は文字に使わない） */
  --matsu:#2E5D4B;   /* 松葉: クリニック名・セクション前置き・肯定 */
  --ai:#22376B;      /* 藍: 主要アクション・選択中タブ・リンク・追加ボタン */
  --akane:#8A4A5A;   /* 茜: カテゴリ色の補助（4色で足りないとき） */
  --shadow:0 1px 0 rgba(0,0,0,.04),0 6px 18px -10px rgba(60,45,25,.35);
  --r:12px;          /* 標準角丸。カードは14px、pill/チップは999px */
}
```

### 色の役割（厳守）

| 色 | 使う場面 | 使わない場面 |
|---|---|---|
| 朱 `--shu` | 選択中のフィルタチップ、注意・禁止の破線枠、削除ボタン文字、「戻る条件」、見出し中の1語強調 | 大面積の塗り、本文 |
| 金茶 `--kin` | 入力フォーカス（`box-shadow:0 0 0 3px rgba(192,138,34,.15)`）、ノートの左罫線、濃度・件数などの数値、二重罫線 `3px double` | 本文色（薄くて読めない→ `--kin-d` を使う） |
| 松葉 `--matsu` | クリニック名、`.sectitle`（字間広めの小見出し）、印刷物の前置き（eyebrow）、肯定・成功 | 操作ボタン |
| 藍 `--ai` | `.btn` 主要ボタン、`.tab.on`、`.addbtn`、`.back`、リンク、印刷物の手順番号 | 警告 |
| 墨 `--sumi` | 本文、トースト背景 | — |

カテゴリを色分けするときは 朱→藍→松葉→金茶→茜 の順で割り当て、`.catband`（カード左端 4px）や `.dot`（11px の丸）で示す。ボタンやタブでは使わない。

### 和紙テクスチャ（body の背景。必ず入れる）

```css
body{
  background:var(--washi);
  background-image:
    radial-gradient(circle at 18% 12%,rgba(192,138,34,.05),transparent 40%),
    radial-gradient(circle at 82% 78%,rgba(34,55,107,.05),transparent 42%),
    url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='2'/><feColorMatrix type='matrix' values='0 0 0 0 0.45 0 0 0 0 0.38 0 0 0 0 0.25 0 0 0 0.025 0'/></filter><rect width='120' height='120' filter='url(%23n)'/></svg>");
}
```

## 3. タイポグラフィ

### フォント読み込み（唯一許可された外部リソース）

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Shippori+Mincho:wght@500;700;800&family=Zen+Kaku+Gothic+New:wght@400;500;700;900&display=swap" rel="stylesheet">
```

- オフライン時はフォールバックで表示が成立するよう、必ずシステム書体を後ろに並べる。
- Google Fonts 以外の外部 JS/CSS/画像/API は禁止。

```css
body{font-family:"Zen Kaku Gothic New","Hiragino Sans","Yu Gothic",-apple-system,sans-serif}
h1,h2,h3,.mincho{font-family:"Shippori Mincho","Hiragino Mincho ProN","Yu Mincho",serif;font-weight:700;letter-spacing:.02em}
```

### サイズ体系（画面）

| 要素 | サイズ / 太さ | 備考 |
|---|---|---|
| body | 15px / 400, line-height 1.65 | `-webkit-text-size-adjust:100%` |
| ヘッダー h1 | 18px / 700 明朝 | |
| ヘッダー sub | 11px / `--sumi2`, letter-spacing .04em | |
| シート・詳細 h2/h3 | 19〜21px / 700 明朝 | |
| `.sectitle` | 12px / 700, letter-spacing .16em, `--matsu` | セクション前置き |
| カード見出し `.pn` | 14.5px / 700 | |
| リスト主行 `.an` | 14px / 700 | |
| 補足 `.pc` `.ax` | 11〜11.5px / `--sumi2` | |
| タブ | 13px / 600 | |
| チップ | 12px / 600 | |
| 入力欄 | **16px** | iOS ズーム防止のため 16 未満にしない |
| ボタン `.btn` | 14px / 700 | |
| 免責 `.disc` フッター `.foot` | 11〜11.5px / `--sumi2` | |

数値の強調（濃度、件数、用量、手順番号）は明朝 800 で大きく出す（例: 17〜21pt）。

## 4. レイアウト

- `main{max-width:760px;margin:0 auto;padding:14px 14px 90px}` — 1カラム、下に 90px 余白（ボトムシート・トースト用）。
- ヘッダーは `position:sticky;top:0`、和紙の半透明グラデ＋`backdrop-filter:blur(8px)`、下線 `1px solid var(--line)`。`padding-top:calc(env(safe-area-inset-top) + 10px)`。
- タブはヘッダー内に置き、横スクロール（`overflow-x:auto`、スクロールバー非表示）。ページ本体は `.view.on` で切替、`fade` アニメ .25s。
- カード群は `grid-template-columns:repeat(auto-fill,minmax(150px,1fr))` — 390px 幅で 2 列、SE(375px) でも 2 列。
- 固定要素（トースト・シート）は `env(safe-area-inset-bottom)` を足す。
- ボトムシートは `max-width:560px`、上角 18px、`max-height:84vh`。
- viewport meta は `width=device-width, initial-scale=1.0, viewport-fit=cover`。`user-scalable=no` は付けない。

## 5. コンポーネント

CSS は `templates/starter.html` に全て入っている。ここでは各部品の役割と使い方だけを定める。

| クラス | 役割 | ルール |
|---|---|---|
| `header > .brand` | 34px たんぽぽアイコン + 明朝 h1 + サブタイトル | h1 はアプリ名。クリニック名はフッターへ |
| `.tabs > .tab` | pill 型タブ。選択中 `.on` は藍塗り | 4つ以上なら横スクロールに任せ、折り返さない |
| `.search input` | 40px 左パディングに虫めがね SVG | フォーカスは金茶リング |
| `.filters > .chip` | 絞り込みチップ。選択中 `.on` は朱塗り | 「すべて」を先頭に置く |
| `.grid > .pcard` | 一覧カード。絵文字 + 見出し + 補足 + 右上に金茶の件数 `.cnt` | 左端 `.catband` でカテゴリ色 |
| `.al` | リスト行。主行・補足・右に金茶の数値 `.conc`・藍の `+` `.addbtn` | 高さ 52px 以上 |
| `.group-h` + `.dot` | 色丸付きグループ見出し | |
| `.note` | 金茶左罫線のノート＝「覚えておくこと」 | 太字は `--shu-d` |
| `.caution` | 朱の破線枠＝「してはいけないこと・戻る条件」 | |
| `.btn` / `.btn.ghost` / `.btn.warn` | 主要（藍塗り）/ 副（白地藍字）/ 危険（白地朱字） | 高さ 44px 以上。1画面に主要ボタンは1つ |
| `.back` | 「← 戻る」テキストボタン（藍） | |
| `.pill` | メタ情報の小さなラベル | |
| `details.acc` | アコーディオン。`summary` の右端に件数 `.gn` | マーカーは非表示 |
| `.sheet-bg > .sheet` | 下から出るシート。グラブバー付き | 背景タップで閉じる |
| `.toast` | 墨色の pill トースト。1.6 秒で消える | 保存・追加の確認に使う |
| `.listempty` | 空状態。大きな 🌼 と一言 | |
| `.disc` | 破線上罫の免責文 | 医療アプリは必須：「最終判断は医師が行います」 |
| `.foot.mincho` | `やまもと皮膚科・漢方クリニック　🌼 たんぽぽちゃん` | 全アプリ共通の締め |

### 印刷（`@media print`）
ヘッダー・タブ・検索・ボタン・免責・フッターを隠し、背景を白に、テクスチャを外す。カードは `break-inside:avoid`。

## 6. マスコット「たんぽぽちゃん」

- **姿**：黄色いたんぽぽの綿毛のような頭、黒い目とピンクの頬、黒地に白い「Y」のシャツ、緑地に星柄のズボン、両手を広げて笑っている。クリニックのロゴ的存在。
- **画面での使い方**
  - ヘッダー左に `assets/tampopo-icon.svg` の線画（茎 `#5a6e48`、花芯 `#a87d35`、綿毛 `#c9a24a` / `#fff8e8`）を 34px で置く。
  - 本体 PNG を使うときは `base64 -i assets/tampopo.png` で `data:image/png;base64,...` にして `<img>` に埋め込む（外部ファイル参照はしない）。表示幅は 60〜120px。
  - 空状態やフッターの絵文字は 🌼。
- **印刷物での使い方**：最終ページ下部の `.mascot-line`（金茶の二重罫線の上）に PNG と明朝の一言メッセージ（例：「出てから塗る」から、「出さないために塗る」へ。）を並べる。
- **禁止**：色替え、変形、切り抜き、別キャラとの併用、患者を怖がらせる文脈での使用。

## 7. 印刷物（A4パンフレット）バリアント

患者に渡す紙は同じトークンで、以下だけ変える。

```css
body{background:#6d6459}  /* 画面上ではページの外を暗く */
.page{width:210mm;height:297mm;margin:0 auto 16px;padding:13mm 12mm 10mm;
  background:linear-gradient(180deg,#FDF9EE 0%,var(--washi) 45%,var(--washi-d) 100%);
  box-shadow:0 6px 24px rgba(0,0,0,.35);display:flex;flex-direction:column;overflow:hidden}
.head{border-bottom:3px double var(--kin)}          /* 見出しは金茶の二重罫線 */
.eyebrow{font-size:10.5pt;letter-spacing:.32em;color:var(--matsu);font-weight:700}
h1{font-size:23pt;font-weight:800} h1 .shu{color:var(--shu)}  /* 1語だけ朱 */
.lead b{background:linear-gradient(transparent 62%,#F6DFA6 62%)}  /* 蛍光ペン風 */
footer{border-top:1px solid rgba(51,44,37,.2);font-size:9pt;color:var(--usu)}
footer .cl{font-family:"Shippori Mincho",serif;color:var(--matsu);font-weight:700}
```

- 単位は pt/mm。本文 10pt、補足 9.5pt、手順番号は明朝 800 で 17〜21pt。
- 角丸は 3〜4px（画面より角ばらせる）。面は `rgba(255,255,255,.6)` の半透明白。
- 手順は「階段」：段ごとに `margin-right` を 26mm ずつ増やし、左タブを 朱→金茶→松葉 の順に塗る。
- 手順ステップは藍の左罫線 4px。
- フッターは左に明朝のクリニック名、`兵庫県姫路市`、右にページ番号。

## 8. Do / Don't

- Do: 1画面の主要ボタンは藍1つ。選択状態はタブ=藍、チップ=朱で統一する。
- Do: 数値は明朝で目立たせる。件数・濃度・用量は金茶。
- Do: 医療情報のアプリには `.disc` の免責を入れる。
- Don't: 真っ白の背景、青系リンク色 `#2b6cb0`、緑単色ヘッダー（旧デザイン）、Material/Bootstrap 風の影。
- Don't: 4色以外の彩度の高い色を新設する。足りなければ `--akane`、それでも足りなければ既存色の透明度で調整する。
- Don't: `user-scalable=no`、16px 未満の入力欄、44px 未満のボタン。
- Don't: 外部 CDN、フレームワーク、ビルド工程。Google Fonts の `<link>` 1本だけが例外。

## 9. 作業手順（この skill を使うとき）

1. `templates/starter.html` を新しいファイル名で複製する。
2. `<title>`、`h1`、`.sub`、タブ名、`LS_KEY`（`<app>_<item>_v1`）を書き換える。
3. 不要なコンポーネントの HTML は削るが、CSS ブロックは残してよい（1ファイル 20KB 程度は許容）。
4. 実装後 `scripts/iphone-shot.sh <file> 390 1200` で描画し、横はみ出し・文字切れ・フォント適用を目視で確認する。
