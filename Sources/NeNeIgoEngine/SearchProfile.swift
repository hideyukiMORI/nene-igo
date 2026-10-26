/// 探索の設定（キャストの性格が持つ・FR-06・ADR 0010）。時間ではなくプレイアウトの数で打ち切る。
public struct SearchProfile: Sendable, Hashable {
    /// 1 手あたりのプレイアウトの数。
    public let playouts: Int
    /// UCT の探索の項の係数（大きいほど、まだ試していない手を広く試す）。
    public let exploration: Double
    /// プレイアウトの手の好み。
    public let style: PlayoutStyle
    /// 局の始めのこの手数までは、訪問の多い上位の手から訪問の数に比例した乱数で選ぶ（序盤のばらつき・FR-05）。
    public let openingMoves: Int

    private init(playouts: Int, exploration: Double, style: PlayoutStyle, openingMoves: Int) {
        self.playouts = playouts
        self.exploration = exploration
        self.style = style
        self.openingMoves = openingMoves
    }

    /// 設定を作る。プレイアウトは 1 以上、係数は 0 以上、序盤の手数は 0 以上。
    public static func make(playouts: Int, exploration: Double, style: PlayoutStyle, openingMoves: Int)
        -> SearchProfile?
    {
        guard playouts >= 1, exploration >= 0, openingMoves >= 0 else {
            return nil
        }
        return SearchProfile(playouts: playouts, exploration: exploration, style: style, openingMoves: openingMoves)
    }
}
