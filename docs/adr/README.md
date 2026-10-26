# アーキテクチャ決定記録（ADR）

トレードオフのある判断を、**理由ごと**残す場所。正本ドキュメントが「いま何が規範か」を書くのに対し、
ADR は「なぜそう決めたか」「何を却下したか」を書く。

## 書き方

- 連番 4 桁 ＋ kebab の題名: `NNNN-short-kebab-title.md`
- `0000-template.md` を複製して書く
- 状態は `提案` / `受理` / `却下` / `置換（→ NNNN）`
- **却下した選択肢を必ず書く。** 再提案は、その理由への反論から始めること
- 受理された ADR を後から書き換えない。変えるときは新しい ADR で置き換える
- 文脈は可能な限り実データ（コード・履歴・計測・コンパイラの出力）で裏を取る

## 一覧

| ADR | 題名 | 状態 |
| --- | --- | --- |
| [0001](0001-strictness-is-mechanically-enforced.md) | 厳格さは機械で強制する | 受理 |
| [0002](0002-swift-testing-only.md) | テスト枠組みは Swift Testing だけにする | 受理 |
| [0003](0003-port-gates-from-reversi.md) | ゲートと規約検査は NeNe Reversi から移植し、証明はこのリポジトリで取り直す | 受理 |
| [0004](0004-target-split-and-dependency-graph.md) | target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、兄弟と同じ向きで依存させる | 受理（Terminal の標準モジュールは 0008 で置換） |
| [0005](0005-board-representation-and-rules.md) | 盤は番兵つきの 1 次元配列、手は「点に打つ／パス」の閉じた enum、局面スーパーコウは盤の配置の Zobrist ハッシュで見る | 受理 |
| [0006](0006-legal-position-counts-and-rule-tests.md) | ルールの正しさは Tromp の合法局面数と、着手でたどり着ける配置の数と、手作りの局面で確かめる | 受理 |
| [0007](0007-board-drawing-and-random-player.md) | 交点は 3 桁 × 1 行（`+` と `-` の ASCII の線・`*` の星・2 桁の石）、乱数の打ち手は自分の眼を埋めない | 受理（石の塗り方は 0009 で補う） |
| [0008](0008-terminal-loop-and-signals.md) | 端末と 1 本のループは NeNe Reversi から移植し、Terminal の標準モジュールに Synchronization を足す | 受理 |
| [0009](0009-stones-underlined-in-board-color.md) | 石のセルに碁盤の地の色の下線を引き、縦に並んだ石を 1 つずつ離して見せる | 受理 |
| [0010](0010-mcts-playouts-and-cast.md) | MCTS（UCT）はプレイアウト数で打ち切り、Core は同じ `apply` の経路のまま速くし、キャスト 4 名は探索の設定で性格を分ける | 受理 |
