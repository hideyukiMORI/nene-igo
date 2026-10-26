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
| Phase 3-2 ランダムに打つ対局を画面に出す | ✅ 2026-10-26（Issue #5・PR #6・ADR 0007・0008） |
| Phase 3-3 実機の画面写真 | ✅ 2026-10-26（Issue #7・PR #8・縦に接する石を下線で離した・ADR 0009。施主の見た目の確認は未） |
| Phase 3-4 MCTS とキャスト | ✅ 2026-10-26（Issue #9・PR #10・ADR 0010） |
| Phase 3-5 サイバー HUD・12 テーマ・セリフ | ✅ 2026-10-26（Issue #11・PR #12・ADR 0011） |
| Phase 4 公開 | ✅ 2026-10-26（Issue #13・PR #14・ADR 0012）。v0.1.0 を公開（Issue #15） |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・Core のテスト（release 構成）・コミットの形）
- `nene-igo`: 乱数の 2 者の 19 路の対局を描き続ける（`--seed`・`--move-interval`・`--result-pause`・`q`）
- Core: 盤・取り・自殺手・局面スーパーコウ・パスと終局・中国ルールの数え方とコミ 7.5・局面の文字列表現・Zobrist

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）

- 施主による見た目の確認（写真は撮った・ADR 0009）
- v0.1.0 の Release（未公開。タグも未）

## 次の 1 手

施主に実機の写真で見た目（縦の石を離す下線の細さ・縮小版で横に並ぶ石・12 テーマの碁盤の色・キャスト 4 名）と投了の要否を確かめてもらい、直しは v0.1.1 で出す。公開後の確認: Swift の無い ubuntu:22.04 で `install.sh` の 1 行から入れ、`--version` と疑似端末での起動・`q` での終了を確かめた（2026-10-26）。
