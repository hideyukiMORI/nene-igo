# ADR 0003 — ゲートと規約検査は NeNe Reversi から移植し、証明はこのリポジトリで取り直す

- 状態: 受理
- 日付: 2026-10-26
- Issue: #1
- 影響する規則: QLT-001 / QLT-007 / CNF-001〜CNF-022 / GIT-003

## 文脈

NeNe Reversi（https://github.com/hideyukiMORI/nene-reversi）と NeNe Gambit（https://github.com/hideyukiMORI/nene-gambit）は、
同じ施主・同じ MIT ライセンス・同じ厳格規約で作った兄弟のリポジトリである。施主の方針として、兄弟のゲートと規約検査・文書の形・端末と描画の土台・
配布の形は、自分たちのコードとして移植してよい。Reversi は Gambit から移植した最新の形で、Phase 0 で Gambit の検査の穴を 7 つ塞いでいる（Reversi の ADR 0001）。
だから移植元は原則 Reversi にする（Reversi にまだ無い配布とセリフの仕組みは、使う PR で Gambit から持ってくる）。

ただし中身を理解せずに丸ごと写すのではなく、囲碁に要らないもの（リバーシ固有の部分）を落とし、名前を合わせ、検査の証明（negative proof）は
このリポジトリで取り直す。

## 決定

Issue #1 で次のファイルを Reversi から移植した。移植元はすべて Reversi の Issue #1 の squash コミット `b3dac02`（Phase 1 の足場の形）で、
`eng/conformance.py` は Reversi の main の `0ee4526` でも `b3dac02` と同じ中身である。

| このリポジトリのファイル | 変えたこと |
| --- | --- |
| `eng/conformance.py`・`eng/tests/test_conformance.py` | 名前を合わせた。Reversi 固有の商標の検査（Reversi の規則番号で 23 番）とその単体テストを落とした。CNF-001〜CNF-022 の番号と意味は Reversi と同じ |
| `eng/measure-language.py` | 名前を合わせた。64 ビットの桁あふれの 2 ケース（X-g・X-h）を足した（ADR 0001） |
| `eng/prove-gates.py` | 名前を合わせた。足場の型の範囲を 19 路の 361 点にした。商標の証明（P62）を落とした。GitHub 側の証明（P43・P46）はこのリポジトリの ruleset と run で書き直した |
| `eng/swift-strict.sh`・`eng/install-tools.sh`・`eng/install-swift.sh`・`eng/lint.sh`・`eng/swift-sources.sh`・`eng/validate-commit-message.py`・`eng/tests/test_commit_message.py`・`eng/swift.lock`・`eng/swiftlint.lock`・`eng/dependency-allowlist.txt`・`eng/ci-require-ready.sh` | 変えていない（事故の参照先は Reversi の時点で「NeNe Gambit の」と明記済み） |
| `Makefile`・`Package.swift` | 名前を合わせた（target は 0 本。`test`・`smoke` の段はまだ足さない） |
| `.swift-format`・`.swiftlint.yml`・`.swift-version`・`.gitignore`・`.githooks/commit-msg`・`.github/pull_request_template.md`・`.github/workflows/ci.yml` | 変えていない |
| `docs/` の各文書・`CLAUDE.md`・`AGENTS.md`・`README.md` | 形は Reversi のまま、中身は囲碁と施主の決定とこのリポジトリの実測で書き直した。商標の項を落とした |

持ってこなかったもの: リバーシのルール・評価・探索（Core と Engine は囲碁で一から書く）・キャストとセリフ（新しい 4 名で書く）・
`eng/smoke-terminal.py`・端末と描画の土台（どれも Phase 3 の使う PR で移植してこの表に足す）・配布（Phase 4 で Gambit から）。
Reversi の作業木には書き込んでいない（読んだのは git のコミットの中身だけ）。

**証明はすべてこのリポジトリで取り直した**（`python3 eng/prove-gates.py`・[gate-proofs.md](../quality/gate-proofs.md)）。Reversi・Gambit の証明の結果は一つも写していない。
GitHub 側の証明（ruleset・draft の CI）もこのリポジトリの PR と run で取った。

## 強制

- **active**: 移植した検査はすべて、このリポジトリの証明が通ってから強制マトリクスで active にした（CNF-006 が証明行の無い active を拒否する）
- **不能**: 「移植元を理解して写したか」はレビュー事項である。この表は、次に誰かが Reversi の修正を取り込むときの照合元として置く

## 結果

- 4 回分の実測と事故（draft の CI のスキップ・SwiftPM の警告・静的バイナリが黙って規則を飛ばす・Gambit の CNF-013 の穴）から生まれた検査を、最初から持てる
- 失うもの: Reversi の検査器が直されても、このリポジトリには自動では入らない。検査器は製品ごとに別々に保守する

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| Gambit から移植する | Reversi が Gambit の検査の穴（CNF-013 の括弧と並び・extension の init・`@preconcurrency`・`.swift-format` の `rules`）を塞いだ後の形がある。古い方を写すと穴も写る |
| 検査器を共有のパッケージや submodule にする | 依存を足すことになり（CODING_RULES 第 5 節の 3 点が要る）、片方の都合の変更がもう片方のゲートを黙って変える。規約は製品ごとの「守るべきこと」を含む |
| 検査器を一から書き直す | 先に踏んだ地雷を自分で踏み直すことになる。移植してよいと施主が決めている |
| Reversi の gate-proofs の結果を写す | 「設定が在ることは検査が効いている証明ではない」（ポリシー P-09）。このリポジトリの木で落ちるのを見ていない |
| Reversi の main の HEAD の `prove-gates.py` を移植する | 実装済みの target のソースに違反を仕込む形で、target が 0 本の足場では動かない。足場を置いて仕込む `b3dac02` の形を移植した |
| 商標の検査（Reversi の規則番号で 23 番）を残す | 囲碁に登録商標のゲーム名の問題は無い。守るものの無い検査は置かない（番号は欠番にせず、Reversi と同じ番号の CNF-001〜CNF-022 だけを持つ） |
