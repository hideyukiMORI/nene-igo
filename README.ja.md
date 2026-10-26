# NeNe Igo

> *Four snarky AIs play Go in your terminal. Forever. Press `q` to make them stop.*

4 人のキャストが、一から手作りしたモンテカルロ木探索で 19 路の囲碁をひたすら打ち続ける、ターミナル用のスクリーンセーバーです。打ちながら、英語で減らず口を叩き合います。
1 局が終われば、すぐ次の対局が始まります。あなたは何もしなくて大丈夫。石が積み上がるのを眺めて、ときどきニヤッとしてください。

[![release](https://img.shields.io/github/v/release/hideyukiMORI/nene-igo)](https://github.com/hideyukiMORI/nene-igo/releases/latest)
![platform](https://img.shields.io/badge/platform-Linux%20x86__64%20%2F%20WSL2-555)
![license](https://img.shields.io/badge/license-MIT-555)

[English](README.md) · **日本語**

![GLACIER テーマで SENTE.SYS が SEKI.LCK に 21.5 目勝った画面](docs/images/result-glacier.png)

<sub>実機の画面です（合成していません）。WSL2 の Windows Terminal で v0.1.0 の直前のビルドを動かしました（`--seed 21 --theme glacier`・120×30）。
438 手と 2 回のパスで終局し、中国ルール・コミ 7.5 で SENTE.SYS が 21.5 目勝ち。SEKI.LCK は「ロックが古かった」と言い訳しています。</sub>

チェス版の [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit)、[NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi) の兄弟です。

---

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-igo/main/install.sh | bash
```

最新の [Release](https://github.com/hideyukiMORI/nene-igo/releases/latest) をダウンロードし、`SHA256SUMS` でチェックサムを確かめてから `~/.local/bin/nene-igo` にインストールします。
チェックサムが合わなければ、何もインストールしません。スクリプトは [install.sh](install.sh) の 45 行ほどです。

- 動作環境: x86_64 の Linux で glibc 2.35 以上（Ubuntu 22.04 以降）。WSL2 の Ubuntu と Windows Terminal で動作を確認しています
- Swift は要りません。Swift の標準ライブラリを静的にリンクした 1 ファイルで、動的な依存は libc・libm・libstdc++・libgcc_s だけです
- アンインストール: `rm ~/.local/bin/nene-igo`

**PowerShell から**（Windows・WSL が入っていること）:

```powershell
irm https://raw.githubusercontent.com/hideyukiMORI/nene-igo/main/install.ps1 | iex
```

既定の WSL のディストリビューションの中で同じインストーラを流し、`%LOCALAPPDATA%\nene-igo\bin` に小さな `nene-igo.cmd` を置いて、そのフォルダをユーザーの PATH に足します。
これで PowerShell からも cmd からも `nene-igo` で起動できます（中身は `wsl.exe` で WSL の nene-igo を呼ぶだけです）。別のディストリビューションに入れるときは `NENE_IGO_DISTRO` を設定してください。
スクリプトは [install.ps1](install.ps1) です。アンインストール: `%LOCALAPPDATA%\nene-igo` を消して PATH から外し、`wsl rm ~/.local/bin/nene-igo`

<details>
<summary>手で入れる場合</summary>

```bash
v=0.1.0
curl -fsSL -O https://github.com/hideyukiMORI/nene-igo/releases/download/v$v/nene-igo-$v-linux-x86_64.tar.gz \
           -O https://github.com/hideyukiMORI/nene-igo/releases/download/v$v/SHA256SUMS
sha256sum --check SHA256SUMS
tar -xzf nene-igo-$v-linux-x86_64.tar.gz
./nene-igo-$v-linux-x86_64/nene-igo
```
</details>

## 眺め方

```bash
nene-igo
```

| キー | |
| --- | --- |
| `q` | 終了します（Ctrl+C でも構いません。どんな終わり方でも端末は元に戻ります） |
| `t` | 次のカラーテーマにします（全 12 種類） |

| 起動オプション | |
| --- | --- |
| `--theme NAME` | `NEON` `PHOSPHOR` `AMBER` `SYNTHWAVE` `GLACIER` `BLOODMOON` `VAPOR` `MONO` `TOXIC` `GILDED` `ABYSS` `PAPER` |
| `--seed N` | 同じシードなら、同じ対局と**同じ会話**になります |
| `--move-interval SEC` | 1 手の間隔（既定 1.0 秒） |
| `--result-pause SEC` | 終局後に結果を見せる時間（既定 3 秒） |
| `--version` | 版を出して終わります |

端末は **80×24 以上**が要ります。**102×25 以上なら大きな盤**になります（Windows Terminal の既定の 120×30 で足ります）。
小さすぎるときは、必要な大きさを 1 行で知らせます。

1 局は長めです。平均 440 手ほどなので、1 手 1 秒だと **1 局が 7 分半ほど**かかります。
投了はしません。打てる所が自分の眼だけになるまで打ち、両者がパスして終局します。

### 画面の見方

![NEON テーマの中盤](docs/images/midgame-neon.png)

- **盤**: 石は文字ではなく、交点に置いた色のブロックです。直前の手は `[ ]` で囲みます。列は囲碁の慣習どおり `A`〜`T` で `I` を飛ばします
- **MATCH**: 局の番号・黒と白のキャスト・手番と手数・コミ
- **CAPTURES**: それぞれが取った石の数（アゲハマ）の棒
- **SCORE**: 黒勝ち・白勝ちの通算の棒（コミ 7.5 なので引き分けはありません）
- **LOG**: 直近の手。カーソル `▌` は次に打つ側の列にあります
- **RESULT**: 終局したときに出ます。`B+3.5` のような結果・数えた石と地・次の局までの秒読み
- **COMMS**: 盤の下の 2 行で、キャストの最近のひと言です。明るいほうが新しい行です

## キャスト

局の始まりに 4 名から 2 名を乱数で選び、黒と白に座らせます。打ち方も、口の悪さもそれぞれ違います。

| | 打ち方 | 本人いわく |
| --- | --- | --- |
| **SENTE.SYS** `>:]` | 先手に取りつかれた常駐デーモン。プレイアウトで直前の手のすぐ隣に応じたがります | *"I have root on this board. You have guest access."* |
| **TENUKI.LOG** `-.-` | 何でも手を抜いてよそへ打つ記録係。最初の 10 手はゆるく打ちます | *"My strategy is to be elsewhere."* |
| **MOYO.PNG** `^.^` | 中央に模様を張りたがる自称アーティスト。プレイアウトで 1 線を避けます | *"A blank canvas. Three hundred sixty-one chances. All mine."* |
| **SEKI.LCK** `[-]` | 何も変えたくないロックファイル。気に入った手に固執します | *"Lock acquired. Nobody moves unless I approve."* |

1 人 50 本ずつ、取った・取られた・大石を取った・パス・しばらく静か・勝った・負けた、といった出来事ごとにセリフがあります。いくつか紹介します。

> **TENUKI.LOG**（大石を取られて） *"They died doing what they loved. Being ignored."*<br>
> **MOYO.PNG**（取って） *"Negative space, now with your stones in it."*<br>
> **SEKI.LCK**（パスして） *"Mutual life. My favorite kind of stalemate."*<br>
> **SENTE.SYS**（負けて） *"Unhandled exception: losing."*

残りの 196 本は、眺めながら集めてください。

## 12 のテーマ

`t` で巡ります: `NEON`（既定）・`PHOSPHOR`・`AMBER`・`SYNTHWAVE`・`GLACIER`・`BLOODMOON`・`VAPOR`・`MONO`・`TOXIC`・`GILDED`・`ABYSS`、それに唯一の明るいテーマ `PAPER`。

| PAPER | SYNTHWAVE（80×24） |
| --- | --- |
| ![PAPER](docs/images/paper.png) | ![縮小版の SYNTHWAVE](docs/images/compact-synthwave.png) |

どのテーマでも、黒石は暗く白石は明るく、どちらも碁盤に対して 3:1 以上、英字・数字と盤の記号は背景に対して 4.5:1 以上あります。
これは人の目ではなく、実際に描いたセルの色からテストが毎回計算しています。

---

## 中身の話

NeNe Igo は囲碁のスクリーンセーバーの顔をしていますが、**規則を人ではなく機械に守らせる実験**でもあります。
Issue #1 から公開の仕組みまで、2026-10-26 の 1 日で作りました。以下の数字はすべてリポジトリの記録（ADR・テスト・ゲートの証明）にあります。

### 1. ルールは公表値と突き合わせる

囲碁のエンジンもライブラリも使っていません。囲碁にはチェスの perft のような手順数の定番が無いので、ルール（取り・自殺手・局面スーパーコウ・パス・中国ルールの数え方）は、
**John Tromp が公表している小さい盤の合法局面数**と突き合わせます。値は[一次資料](https://tromp.github.io/go/legal.html)から写し、出典をテストのそばに書きました。

- 1×1 から 4×4 までの 19 通りを全部の置き方の数え上げで（4×4 は 3^16 = 4,300 万通り）、16 通りを空の盤からのすべての着手で数え、どちらも公表値とぴったり一致させます。`make check` のたびに回ります
- このテストは、ルールを書いている最中に本物の不具合を見つけました。連どうしで印を共有した塗りつぶしが、19 通り中 17 通りで数え落としていました（[ADR 0006](docs/adr/0006-legal-position-counts-and-rule-tests.md)）

### 2. 合法判定は 1 つのまま、速くする

最初のプレイアウトは 19 路で**毎秒約 47 局**でした。これでは探索になりません。
プレイアウト専用の速い「合法か」を別に書くことは、このリポジトリの規則で禁じています。そこで唯一の経路のほうを速くしました。
手ごとに配列と集合を丸ごと複製するのをやめて手元の写しを書き換え、塗りつぶしをスタックに置いた `InlineArray` にして、**毎秒約 1,560 局**。ルールのテストは 1 つも変えずに全部通りました（[ADR 0010](docs/adr/0010-mcts-playouts-and-cast.md)）。

### 3. 時計を読まない囲碁 AI

MCTS は秒数ではなく、決めた数のプレイアウト（キャストによって 450〜650）で打ち切ります。
盤・AI・描画のコードは、現在時刻・乱数・環境変数を**読めません**。読もうとすると自作の規約検査がビルドを落とします。乱数はシード付きの自前の SplitMix64 から引くので、
`--seed 42` なら毎回同じ対局と同じ悪口になります。36 局を測ると、各キャストは 18 局中 7〜12 局を勝ち、12 局を同時に回しても 1 手は最大 0.87 秒でした。

### 4. 柱に見えた石

盤は 1 線を 1 行で描くので、19 行が 30 行の端末に収まります。最初の実機の画面写真では、上下に並んだ石が接して**1 本の柱に見えました**。
行のあいだに空行を入れる余裕はありません。そこで、石のセルは空白のまま（石を文字で描かない）、**碁盤の色の下線**を引いて、石の下に細い隙間を作りました（[ADR 0009](docs/adr/0009-stones-underlined-in-board-color.md)）。

### 5. 規則は書くのではなく、守らせる

リポジトリには 71 の規則があり、どれにも ID と「機械が守っているか」の状態が付いています。
いま **50 が active**（破ると `make check` が落ちます）で、残りは「まだ機械が見ていない」「機械では塞げない」と正直に書いてあります（[品質ゲート](docs/QUALITY_GATES.md)）。
製品のコードを書く前に Swift 6.4.1 を 77 ケースで測り（[phase0-results.json](docs/quality/phase0-results.json)）、どの検査も落ちるのを見るまで信用しません。
わざと仕込んだ違反 **64 件**が、どれも意図した規則で捕まったことを[ゲートの証明](docs/quality/gate-proofs.md)に残しています。

### 6. 端末は必ず元に戻る

`q`・Ctrl+C・SIGTERM のどれで終わっても、**SIGSEGV で落ちても**、死ぬ前に端末を元に戻します。
これは目で確かめるのではなく、本物の実行ファイルを疑似端末の中で動かして `make check` のたびに確かめています。

---

## 開発

```bash
make bootstrap           # clone 直後に 1 回（コミットフックと静的な SwiftLint）
make check               # 唯一の完了の定義。ローカルと CI で同じ
make release TAG=v<版>   # 配布物を作る（検査に通ったときだけ）
```

- Swift 6.4.1（`.swift-version`）・SwiftPM だけ・製品の外部依存は 0。ソースは約 3,400 行、テストは約 1,200 行です
- 入口は [CLAUDE.md](CLAUDE.md)（日本語）と [AGENTS.md](AGENTS.md)（英語）。設計の判断は 12 本の [ADR](docs/adr/README.md)、要件と施主の決定は [REQUIREMENTS.md](docs/REQUIREMENTS.md) にあります
- 人も AI も、同じ規則と同じゲートの下で書きます。コードは Claude Code が書き、要件と判断は施主が決めました

## ライセンス

MIT（[LICENSE](LICENSE)）
