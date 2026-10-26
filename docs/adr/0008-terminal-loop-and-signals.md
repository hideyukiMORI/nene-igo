# ADR 0008 — 端末と 1 本のループは NeNe Reversi から移植し、Terminal の標準モジュールに Synchronization を足す

- 状態: 受理
- 日付: 2026-10-26
- Issue: #5
- 影響する規則: SWF-013 / SWF-009 / ARC-002 / ARC-004 / ARC-005 / ARC-006 / ARC-007 / QLT-001 / FR-08
- 置き換えるもの: ADR 0004 の「Terminal の標準モジュールは Glibc だけ」（`Synchronization` を足す）

## 文脈

SWF-013 は「ループの待ち方（シグナルの受け方とキー入力の待ち方）は Phase 3 の縦切りで決め、ADR に書く」とした。
要件: 異常終了（SIGSEGV を含む）でも端末を必ず復元する・`SIGWINCH` で大きさに追従する・Core と Engine は時計を知らず、
「何秒に 1 手打つか」は合成ルートが決める（FR-08・FR-11）。

兄弟の NeNe Reversi が同じ問題を同じ規約で解いている（Reversi ADR 0008。Reversi は NeNe Gambit ADR 0006 を引き継いだ）。
端末の区画は自分たちのコードとして移植してよい（ADR 0003・WORK-ORDER 第 2-5 節）。

## 決定

Reversi ADR 0008 の決定 1〜8 を、名前を合わせて引き継ぐ。移植元は Reversi のコミット e4a6f52（Reversi の Issue #5）の
`Sources/NeNeReversiTerminal/`（`Console`・`ConsoleOpening`・`ConsoleSignals`・`ConsoleState`・`FrameEncoder`・`KeyIntent`・`Palette256`）・
`Sources/nene-reversi/`（`Screensaver`・`LaunchOptions`・`LaunchParsing`・`main`）・`eng/smoke-terminal.py`・`Tests/NeNeReversiTerminalTests/TerminalTests.swift`。

1. **並行の形は 1 つ: 合成ルートの 1 本のループ**（`Screensaver.run`）。`Console.waitForInput(milliseconds:)`（`poll(2)`）で次の 1 歩の締め切りまで入力を待つ
2. 終了と大きさの変化のシグナル（SIGINT・SIGTERM・SIGHUP・SIGWINCH）のハンドラは `Synchronization.Atomic<UInt32>` の旗を立てるだけ。
   そのために、依存グラフの正本で `NeNeIgoTerminal` の標準モジュールに **`Synchronization` を足す**（Terminal だけ。ADR 0004 の置き換え）
3. 異常終了のシグナル（SIGSEGV・SIGBUS・SIGILL・SIGFPE・SIGABRT・SIGTRAP）のハンドラは、その場で端末を戻してから既定の動作で同じシグナルを送り直す
4. 端末の退避値（termios）は `ConsoleState` の 1 か所だけ（`nonisolated(unsafe)`・`unsafe=allowed` の Terminal の中だけ）
5. Ctrl+C は SIGINT として受ける。キーは `q` だけ（`t` は手順 5）
6. 端末の外へのテキストの出力は `Console` だけ。起動できなかった理由 1 行の文言は合成ルートが決める
7. 状態の持ち主: 対局の列は Engine の値型 `GameSeries` で、合成ルートの `Screensaver` が 1 つだけ持つ。画面の前フレームは `Screensaver.previous`。
   シードは合成ルートが `--seed` かシステムの乱数から決め、`SplitMix64` に渡す
8. 端末の確かめは 2 段: 端末を使わない単体テストと、実行ファイルを疑似端末で動かす `make smoke`
   （`q`・Ctrl+C・SIGTERM・SIGSEGV・大きさの変化で端末が戻ること・間違った起動オプションと端末の外からの起動は理由 1 行）

Reversi から変えたことは名前だけ（コードの中身は同じ。移植元の注記を「NeNe Reversi の e4a6f52・Reversi は NeNe Gambit の 64b82ec から」に直した）。

## 強制

- **active**（QLT-001 の一部・FR-08）: `make smoke` が終わり方ごとの端末の復元を見る。証明は P49（端末を戻す列を壊すと smoke が落ちる）
- **active**（SWF-013）: CNF-022 が `async` / `await` / `Task` / `actor` / スレッド / Dispatch の語を拒む

## 結果

- 時計を読むのは合成ルートのループだけで、Core・Engine・Render・Terminal はどれも時計を知らない（ARC-007）
- 🔴 `kill -9`（SIGKILL）は捕まえられないので、端末は戻らない。これは塞げない
- 🔴 異常終了のハンドラの中で Swift の配列の `withUnsafeBufferPointer` を使っている。Swift の実行時が非同期シグナル安全だという保証は無い（Reversi・Gambit と同じ）
- smoke は疑似端末での振る舞いを見るだけで、Windows Terminal での見え方の代わりにはならない（QLT-013・手順 3）

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| `Task` と `AsyncStream` でキー入力と時計を別々に待つ | 並行の形が 2 つになる（SWF-013）。1 本の `poll` で足りる |
| シグナルを `signalfd` / self-pipe で受ける | 旗 1 つで足りる。ファイル記述子が増え、`poll` の相手が 2 つになる |
| `atexit` で端末を戻す | 異常終了のシグナルでは呼ばれない |
| `Synchronization` を使わず、`nonisolated(unsafe)` の変数を旗にする | Swift 6 のデータ競合の検査を `unsafe` で黙らせることになる |
| Terminal を兄弟と共有のパッケージにして依存する | 外部依存を足すことになる（ADR・許可リスト・規約の表の 3 点が要る）。兄弟でも版の進み方が違う |
