# いまのタスク — NeNe Igo

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-26（77 ケース・Reversi の 75 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-26（Issue #1・PR #2・ruleset 25844451） |
| Phase 2 negative proof | ✅ 2026-10-26（59 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 盤とルール（Core だけ） | ✅ 2026-10-26（Issue #3・PR #4・合法局面数が Tromp の公表値と 19 通りで一致・ADR 0005・0006） |
| Phase 3-2 ランダムに打つ対局を画面に出す | 🔄 Issue #5（ADR 0007・0008） |
| Phase 3-3 実機の画面写真 | 🔲 施主が戻ってから（ウィンドウが開くため） |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・Core のテスト（release 構成）・コミットの形）
- `nene-igo`: 乱数の 2 者の 19 路の対局を描き続ける（`--seed`・`--move-interval`・`--result-pause`・`q`）
- Core: 盤・取り・自殺手・局面スーパーコウ・パスと終局・中国ルールの数え方とコミ 7.5・局面の文字列表現・Zobrist

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）

- Windows Terminal での見え方（手順 3 の画面写真は未）
- MCTS・キャスト・12 テーマ・`t`・罫線の枠（手順 4・5）

## 次の 1 手

Phase 3-3: 施主に一言断ってから、Windows Terminal の実機の画面写真を撮る（盤の線・星・石・縦に並んだ石の見え方・文字幅・速さ・ADR 0007 の「結果」）。
その後 Phase 3-4（MCTS・プレイアウト数と 1 手の時間の計測・投了の要否を数字で施主に提案）。
