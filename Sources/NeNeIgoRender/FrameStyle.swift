/// 枠と棒グラフの字形の組（ADR 0011）。移植元: NeNe Reversi `Sources/NeNeReversiRender/FrameStyle.swift`（コミット 0ee4526。Reversi は NeNe Gambit の 64b82ec から移植した）。
public enum FrameStyle: Sendable, Hashable {
    /// 罫線とブロック（`┌─┤│█░▌`）。施主の選んだ形。端末がこれを 1 桁で描くときだけ使う
    case boxDrawing
    /// ASCII（`+-|#->`）。罫線が 2 桁で描かれる端末へ自動で落とす先
    case ascii
}
