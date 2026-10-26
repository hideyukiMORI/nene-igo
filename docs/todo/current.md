# いまのタスク — NeNe Igo

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-26（77 ケース・Reversi の 75 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-26（Issue #1・PR #2・ruleset 25844451） |
| Phase 2 negative proof | ✅ 2026-10-26（59 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 盤とルール（Core だけ） | 🔄 Issue #3（合法局面数が Tromp の公表値と 19 通りで一致・ADR 0005・0006） |
| Phase 3-2 ランダムに打つ対局を画面に出す | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・Core のテスト（release 構成）・コミットの形）
- Core: 盤・取り・自殺手・局面スーパーコウ・パスと終局・中国ルールの数え方とコミ 7.5・局面の文字列表現・Zobrist

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）

- 画面・探索・端末・合成ルート（Phase 3-2 以降）
- 終局が必ず来ること（プレイアウトの方針が要るので Phase 3-2 で確かめる）

## 次の 1 手

Issue #3 を閉じたあと、Phase 3-2「ランダムに打つ 2 者の対局を画面に出す」の Issue を立てる。
自分の眼を埋めないランダム・終局・次の局へ・`q`・端末の復元・疑似端末での smoke。盤の線・星・座標の描き方を ADR に書く。
