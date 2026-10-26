# 用語集 — NeNe Igo

> Status: normative（規範）/ 2026-10-26 初版
> ここに載っている語は、コード・ドキュメント・Issue で**同じ意味**で使う。同義語を発明しない。

| 語 | 意味 | 型／場所 |
| --- | --- | --- |
| 結果（outcome） | 期待される成功・失敗を表す閉じた型 | `*Outcome` |
| 拒否理由（rejection / failure） | 結果に添える閉じた理由の集合 | `*Rejection` / `*Failure` |
| 合成ルート | 依存を結ぶ唯一の場所。時計・乱数・環境を読み、標準入出力と終了コードを持つ | `nene-igo`（executable target） |
| 描画（render） | 局面と HUD の値から文字セルの格子という値を作ること。端末への書き出しは含まない | `NeNeIgoRender` |
| 隔離区画 | 可変性を許した唯一の場所 | ARC-005 の表 |
| 規約検査（conformance） | NeNe Igo 固有の自作ゲート | `eng/conformance.py`（CNF-NNN） |
| waiver | 1 つの規則に対する期限付きの狭い例外 | `docs/waivers/WVR-NNNN-*.md` |
| 機械強制の状態 | active / planned / 不能 / 不採用 | `docs/QUALITY_GATES.md` の強制マトリクス |
| negative proof | ゲートが意図した規則で落ちることの実測 | `docs/quality/gate-proofs.md` |
| 囲碁（Go・igo） | このゲームの名前。製品名は NeNe Igo（「Go」だけだと Go 言語と紛らわしい・REQUIREMENTS の Q1） | — |
| 石（stone） | 盤の交点に置く黒か白の駒。画面では盤とは別の色で塗った偶数桁のブロックで描く（FR-07） | `NeNeIgoCore` |
| 点（point） | 盤の交点。19 路なら 361 個。手の内部表記の単位。表示（列 `A`〜`T` で `I` を飛ばす・行 1〜19）への変換は Render だけ | `NeNeIgoCore` |
| 連（chain） | 縦横に隣り合う同じ色の石のまとまり。取りの単位 | `NeNeIgoCore` |
| 呼吸点（liberty） | 連に縦横で隣り合う空点。0 になった連は盤から取り除かれる | `NeNeIgoCore` |
| 取り（capture） | 打った石で相手の連の呼吸点を 0 にし、その連を盤から取り除くこと。複数の連を同時に取ることがある | `NeNeIgoCore` |
| アゲハマ（prisoners） | 取った石の数。HUD に黒白それぞれを出す（FR-10）。中国ルールの勝敗には使わない | `NeNeIgoCore` |
| 自殺手（suicide） | 何も取らずに、打った石を含む自分の連の呼吸点が 0 になる手。禁止（FR-02） | `NeNeIgoCore` |
| 局面スーパーコウ（positional superko） | 打った後の盤上の石の配置が、その局で以前に現れた配置と同じになる手を禁じる規則。単純なコウを含む（FR-02） | `NeNeIgoCore` |
| 局面（position） | 盤上の石と手番を合わせた値 | `NeNeIgoCore` |
| 手（move） | 局面を次の局面へ進める 1 回の着手。パスも手の 1 つとして表す。内部表記は 1 つ（Phase 3 の ADR で決める） | `NeNeIgoCore` |
| 合法手（legal move） | 空点への着手のうち、自殺手でも局面スーパーコウに当たる手でもないもの。パスは常に合法 | `NeNeIgoCore` |
| パス（pass） | 打たずに手番を渡すこと | `NeNeIgoCore` |
| 終局（game over） | 連続 2 回のパス。中国ルールの数え方とコミで勝敗を決める（FR-04） | `NeNeIgoCore` |
| 中国ルールの数え方（area scoring） | 盤上の石の数＋その色の石だけに囲まれた空点の数。どちらの色にも接する空点（セキの駄目など）は誰のものでもない。死に石の判定はしない | `NeNeIgoCore` |
| コミ（komi） | 後手（白）に足す目数。7.5（REQUIREMENTS の Q5）。半目があるので引き分けは起きない | `NeNeIgoCore` |
| 合法局面数（legal positions） | ある大きさの盤で、すべての連が呼吸点を持つ石の置き方の数。ルールの正しさを公表値（Tromp ら）と突き合わせる。数え方（対称を同一視するか）は出典に合わせ ADR に書く | Core のテスト |
| Zobrist ハッシュ | 点と色ごとの乱数の排他的論理和で盤の配置を表す 64 ビットの値。スーパーコウの判定に使う。差分更新と全計算は常に一致する | `NeNeIgoCore` |
| 局面の文字列表現 | 局面を文字列で表したもの。読み書きは Core の 1 経路だけ（形は Phase 3 の ADR で決める） | `NeNeIgoCore` |
| 局（game） | 空の盤から終局までの 1 回の対局 | 合成ルート |
| MCTS・UCT | モンテカルロ木探索と、その子の選び方（勝率＋探索の項）。プレイアウト数かノード数で打ち切る（FR-03） | `NeNeIgoEngine` |
| プレイアウト（playout） | 局面から終局まで、方針に従って乱数で打ち切ること。Core の合法判定を通る | `NeNeIgoEngine` |
| 眼（eye） | プレイアウトの方針で「自分の眼を埋めない」と言うときの、自分の石だけに縦横を囲まれた空点（正確な定義は Phase 3 の ADR で決める） | `NeNeIgoEngine` |
| キャスト（cast）・性格（persona） | 黒白を受け持つ 4 名のキャラクター。プレイアウト数・探索の定数・プレイアウトの手の好み・セリフの組（FR-06・FR-14） | `NeNeIgoEngine` |
| シード（seed） | 自前の PRNG の初期値。同じシードからは同じ対局の列と同じセリフが出る | 合成ルートが読み、Engine に渡す |
| セル格子 | 端末の 1 画面分の文字セルの 2 次元配列。Render が作り、Terminal が差分で書く | `NeNeIgoRender` |

## 使ってはいけない語

`Manager` / `Helper` / `Util` / `Utils` / `Common` を型名の語尾に使わない（SWF-010）。
役割を語る名前が思いつかないときは、その型が 2 つの責務を持っている可能性が高い。
