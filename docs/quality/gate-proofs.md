# ゲート発火の証明 — NeNe Igo

> Status: 記録 / 最終実測 2026-10-26（60 件すべて pass・`python3 eng/prove-gates.py`・結果の正本は [gate-proofs.json](gate-proofs.json)）
> 根拠となる規則: QLT-007（カスタムゲートには negative proof が要る）

**検査は「落ちること」を見るまで信用しない。** 各ゲートについて、最小の違反を仕込んだ状態で
意図した規則 ID によって失敗すること、そして元に戻すと `make check` が緑に戻ることを実測する。
ゲートを変えたら、この記録も同じ変更で更新する。

🔴 **この文書に結果を先に書かない。** 結果の列は実測するまで **未実測** のままにする。
🔴 **NeNe Gambit から移植した検査も、証明はこのリポジトリで取り直す**（ADR 0003）。Gambit の証明の結果は 1 つも写していない。

証明は `eng/prove-gates.py` が行う。作業木（git が追跡するか追跡し得るファイルと `.git`）を一時ディレクトリへ複製し、
依存グラフの正本どおりの 5 target と規則に沿った最小のソース（「足場」）を置いてから違反を **1 か所だけ** 仕込み、
`make check`（いくつかはより狭いタスク）を回す。
**意図した規則 ID（または道具の規則名）が出力に現れて失敗したとき**だけ pass とする。別の理由で落ちたものは証明にならない。
作業木そのものには触れない。足場は証明のための一時物で、リポジトリには入れていない。
`prove-gates.py` は、強制マトリクスで active の規則に証明が 1 つも無いと exit 1 で終わる。

環境: WSL2 Ubuntu（glibc 2.35）/ Swift 6.4.1（swiftly）/ swift-format 6.4.1 / SwiftLint 0.65.1（swiftlint-static）/ Python 3.10.12
CI: GitHub Actions `ubuntu-22.04` / Swift 6.4.1（固定の tarball・`eng/install-swift.sh`）

---

## 1. 実測結果

### 1-a. active の規則（規則 ID ごとの発火と復帰）

🔴 **文書整合検査（CNF-006）は「`| <規則 ID> |` で始まる行」を active の証明として読む。** active に書き換える規則は、
必ずこの表に規則 ID を行頭にして 1 行足す。
表は `python3 eng/prove-gates.py`（測り直す）か `--render`（測らずに作り直す）が gate-proofs.json と QUALITY_GATES.md の active の行から生成する。手で書かない。
規則を active に書き換えたら、**先に `--render` で表を作ってから**測り直す（複製の中で CNF-006 が「証明行が無い」で先に落ち、対照まで落ちる）。

<!-- proofs:active:start -->
| 規則 | 最小の違反 | 検証経路 | 実測 |
| --- | --- | --- | --- |
| ARC-002 |  |  |  |
| ARC-003 |  |  |  |
| ARC-007 |  |  |  |
| SWF-002 |  |  |  |
| SWF-003 |  |  |  |
| SWF-004 |  |  |  |
| SWF-005 |  |  |  |
| SWF-006 |  |  |  |
| SWF-009 |  |  |  |
| SWF-010 |  |  |  |
| SWF-011 |  |  |  |
| SWF-012 |  |  |  |
| SWF-013 |  |  |  |
| SWF-014 |  |  |  |
| SWF-015 |  |  |  |
| SWF-016 |  |  |  |
| QLT-001 |  |  |  |
| QLT-002 |  |  |  |
| QLT-003 |  |  |  |
| QLT-004 |  |  |  |
| QLT-005 |  |  |  |
| QLT-006 |  |  |  |
| QLT-007 |  |  |  |
| QLT-011 |  |  |  |
| QLT-012 | P46: draft の PR に push する（CI のジョブはスキップでなく失敗し、PR はマージできない） | GitHub Actions run 40205748916（PR #2・head 14cd69b・2026-10-25T15:11Z） | P46: step `eng/ci-require-ready.sh true` が `ci: PR が draft なのでフルゲートを回さない。Ready にすると回る（QLT-012）` で exit 1。必須 check `check` は FAILURE・`mergeStateStatus` は `BLOCKED` |
| CNF-001 |  |  |  |
| CNF-002 |  |  |  |
| CNF-003 |  |  |  |
| CNF-004 |  |  |  |
| CNF-005 |  |  |  |
| CNF-006 |  |  |  |
| CNF-007 |  |  |  |
| CNF-008 |  |  |  |
| CNF-009 |  |  |  |
| CNF-010 |  |  |  |
| CNF-011 |  |  |  |
| CNF-012 |  |  |  |
| CNF-013 |  |  |  |
| CNF-014 |  |  |  |
| CNF-015 |  |  |  |
| CNF-016 |  |  |  |
| CNF-017 |  |  |  |
| CNF-018 |  |  |  |
| CNF-019 |  |  |  |
| CNF-020 |  |  |  |
| CNF-021 |  |  |  |
| CNF-022 |  |  |  |
| GIT-003 |  |  |  |
| GIT-004 | P43: ruleset が `main` に効いていることを読み戻し、必須 check の失敗した PR がマージできないことを見る（`main` への直接 push と force push の試行は、作業環境の権限で止められたので行っていない） | `gh api repos/hideyukiMORI/nene-igo/rules/branches/main`・`gh pr view 2`（2026-10-26） | P43: `main` に効く規則は ruleset 25825059 の `deletion`・`non_fast_forward`・`pull_request`（squash のみ）・`required_status_checks`（`check`）の 4 つ。PR #2 の head 14cd69b は必須 check `check` が FAILURE で `mergeStateStatus` が `BLOCKED` |
<!-- proofs:active:end -->

**復帰の確認**: 対照 P00（足場だけ・違反なし）と P00b（足場を置かない作業木そのまま）が、どちらも `make check` で exit 0（`make check: 緑`）。
各証明は対照と同じ足場に違反を 1 つ足しただけなので、「仕込みを戻すと緑」は P00 が示す。

**除外側の確認**: P00 の足場では、合成ルート `nene-igo` が `ContinuousClock.now`・`SystemRandomNumberGenerator`・`CommandLine.arguments`・`print` を使い、
`NeNeIgoTerminal`（`unsafe=allowed`）が `withUnsafeMutablePointer` と `ioctl` を使っている。それでも `make check` は緑で、
同じ書き方を Core・Engine・テストに置くと P04・P05・P14・P40 で落ちる。

### 1-b. 証明の一覧

<!-- proofs:list:start -->
| # | 規則 | 仕込んだ違反 | 実行したタスク | 結果 | 判定 |
| --- | --- | --- | --- | --- | --- |
| P43 | GIT-004 | ruleset が `main` に効いていることを読み戻し、必須 check の失敗した PR がマージできないことを見る（`main` への直接 push と force push の試行は、作業環境の権限で止められたので行っていない） | `gh api repos/hideyukiMORI/nene-igo/rules/branches/main`・`gh pr view 2`（2026-10-26） | 第 1-a 節 | pass |
| P46 | QLT-012 | draft の PR に push する（CI のジョブはスキップでなく失敗し、PR はマージできない） | GitHub Actions run 40205748916（PR #2・head 14cd69b・2026-10-25T15:11Z） | 第 1-a 節 | pass |
<!-- proofs:list:end -->

---

## 2. 出力の抜粋（実行結果からの引用）

各証明の出力から、期待した行（`evidence`）と末尾の数行（`tail`）を [gate-proofs.json](gate-proofs.json) に残している。このリポジトリで足した検査の代表例:

```text
P55  CNF-013 Sources/NeNeIgoCore/Side.swift:15: 全捕捉（... 括弧や並びに隠れた _ と束縛）は網羅性検査を殺す      ← case (let other):
P56  CNF-013 Sources/NeNeIgoCore/Side.swift:15: 同上                                                          ← case .none, _:
P57  CNF-013 Sources/NeNeIgoCore/Pair.swift:11: 同上                                                          ← case (_, _):
P58  CNF-021 Sources/NeNeIgoCore/Square+Bypass.swift:3: extension に init を書かない（型の本体の唯一のファクトリを迂回できる）
P59  CNF-022 Sources/NeNeIgoCore/Probe.swift:4: async / await / Task / actor / Thread / Dispatch は使えない
P61  CNF-005 .swift-format:1: swift-format の設定 rules は使えない（規則の無効化はリポジトリ全体の抑制になる・M8-j）
P63  CNF-011 Sources/NeNeIgoTerminal/Screen.swift:2: NeNeIgoTerminal は NeNeIgoCore を import できない   ← SwiftPM は通す推移的な import
P64  CNF-011 Sources/NeNeIgoCore/Probe.swift:1: NeNeIgoCore は FoundationEssentials を import できない
P66  CNF-006 docs/quality/gate-proofs.md:1: active の CNF-015 の証明行に実測が書かれていない（空の行は証明ではない）
P47  swift-strict: SwiftPM かコンパイラが警告を出した（QLT-002）
P37  tools: swift は 6.4.0 が要るが、起動できない: The swift version file `.swift-version` requires toolchain version 6.4.0, which is not installed.
```

---

## 3. 事故から生まれた検査・証明の取り直し

Issue #1 の Phase 0〜2 で、測る手順が次を見つけた。

| 見つけたこと | 対処 |
| --- | --- |
| Phase 0 の実測で、Gambit から移植するつもりだった CNF-013 の正規表現が `case (let x):`・`case .a, _:`・`case (_, _):` を通すと分かった（M1-j・M1-k・M1-m。コンパイラも何も言わない） | CNF-013 を `case` の選択肢ごとに「必ず一致するパターン」を探す形に書き換え、P55〜P57 で証明した。壊すと単体テストが落ちることも P65 で見た |
| 🔴 Gambit の流れ（`--render` で表を作ってから測る）では、active にしただけの規則に**中身の空の証明行**ができ、CNF-006 はそれを証明として数えていた | CNF-006 は実測の列が空か「未実測」の行を拒む（P66）。測る前の複製でだけ、測る規則の空の行を `prove-gates.py` が「測定中」で埋める。`prove-gates.py` は証明の無い active の規則があると exit 1 |
| `eng/measure-language.py` に `--swiftlint` を相対パスで渡すと、ケースを一時ディレクトリで回すので見つからず、SwiftLint のケースが落ちていた | 絶対パスに直してから測り直した |
| P23 の初回: 緩めた警告設定と一緒に未使用の定数を置いたら、`eng/swift-strict.sh` がビルド段で先に警告を捕まえ、意図した CNF-009 が出る前に落ちた | 警告の出るコードを外し、設定だけで CNF-009 が落ちることを取り直した |
| Gambit から移植した注記 4 か所が、Gambit の「PR #2」「Issue #3」をこのリポジトリの番号のように書いていた（このリポジトリの PR #2 は別の PR） | 「NeNe Gambit の」と明記した |
| GIT-004 の証明で `main` への直接 push と force push を試そうとしたが、作業環境の権限が止めた | 試していない。ruleset の読み戻しと、必須 check の失敗で PR が `BLOCKED` になることの観測で代えた（P43）。直接 push の拒否は未確認として残す |

---

## 4. リポジトリ設定（ruleset）

| 設定 | 値 | 確認日 |
| --- | --- | --- |
| ruleset | `main`（id 25825059）・enforcement `active`・対象 `~DEFAULT_BRANCH`・bypass なし（`current_user_can_bypass: never`） | 2026-10-26 |
| PR 必須 | `pull_request`（承認 0 件・未解決スレッドで止める） | 2026-10-26 |
| 必須 check | `required_status_checks`: context `check`・integration 15368（GitHub Actions） | 2026-10-26 |
| strict up-to-date | `strict_required_status_checks_policy: true` | 2026-10-26 |
| force push / ブランチ削除の禁止 | `non_fast_forward`・`deletion` | 2026-10-26 |
| squash のみ | ruleset の `allowed_merge_methods: ["squash"]`＋リポジトリ設定（merge commit・rebase は無効、squash の件名は PR タイトル） | 2026-10-26 |

読み戻しは `gh api repos/hideyukiMORI/nene-igo/rulesets/25825059` と `gh api repos/hideyukiMORI/nene-igo/rules/branches/main`（`main` に効く規則が上の 4 つだけであること）。
直接 push・force push・削除が拒まれることは試していない（第 3 節）。

🔴 **設定していないものを「必須になっている」と書かない。** 設定したら `gh api` で読み戻して記録する。

---

## 5. 環境依存の確認（QLT-013）

（まだ無い。端末の表示の確認は Phase 3 の手順 3 で Windows Terminal を使って記録する）
