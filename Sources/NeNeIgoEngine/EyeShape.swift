import NeNeIgoCore

/// プレイアウトが埋めない「眼」の形（ADR 0007）。
///
/// 空点 `p` が色 `c` の眼であるとは: 縦横の盤の中の隣がすべて `c` の石で、斜めの盤の中の点のうち相手の石が、
/// 盤の中ほど（斜めが 4 つ）なら 1 つ以下、盤の端と隅（斜めが 3 つ以下）なら 0 であること。
/// 偽の眼を眼と見ることもあるが、乱数の打ち手が自分の生きている石を自分で取らせないためのもので、ルールの判定ではない。
/// 配列を作らずに数える（プレイアウトの毎手で呼ぶ・ADR 0010）。
enum EyeShape {
    static func isEye(_ point: Point, of stone: Stone, in position: Position) -> Bool {
        let own = PointState.occupied(by: stone)
        let size = position.size
        for k in 0..<4 {
            let dx = k == 0 ? 1 : (k == 1 ? -1 : 0)
            let dy = k == 2 ? 1 : (k == 3 ? -1 : 0)
            if let side = inside(point.x + dx, point.y + dy, size), position.state(at: side) != own {
                return false
            }
        }
        let enemy = PointState.occupied(by: stone.opponent)
        var corners = 0
        var hostile = 0
        for k in 0..<4 {
            if let corner = inside(point.x + (k < 2 ? 1 : -1), point.y + (k % 2 == 0 ? 1 : -1), size) {
                corners += 1
                hostile += position.state(at: corner) == enemy ? 1 : 0
            }
        }
        return corners == 4 ? hostile <= 1 : hostile == 0
    }

    private static func inside(_ x: Int, _ y: Int, _ size: BoardSize) -> Point? {
        Point.at(x: x, y: y).flatMap { size.contains($0) ? $0 : nil }
    }
}
