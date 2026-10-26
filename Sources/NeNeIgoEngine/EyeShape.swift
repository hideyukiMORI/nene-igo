import NeNeIgoCore

/// プレイアウトが埋めない「眼」の形（ADR 0007）。
///
/// 空点 `p` が色 `c` の眼であるとは: 縦横の盤の中の隣がすべて `c` の石で、斜めの盤の中の点のうち相手の石が、
/// 盤の中ほど（斜めが 4 つ）なら 1 つ以下、盤の端と隅（斜めが 3 つ以下）なら 0 であること。
/// 偽の眼を眼と見ることもあるが、乱数の打ち手が自分の生きている石を自分で取らせないためのもので、ルールの判定ではない。
enum EyeShape {
    static func isEye(_ point: Point, of stone: Stone, in position: Position) -> Bool {
        let own = PointState.occupied(by: stone)
        let enemy = PointState.occupied(by: stone.opponent)
        let size = position.size
        let sides = around(point, size: size, offsets: [(0, 1), (0, -1), (1, 0), (-1, 0)])
        guard sides.allSatisfy({ position.state(at: $0) == own }) else {
            return false
        }
        let corners = around(point, size: size, offsets: [(1, 1), (1, -1), (-1, 1), (-1, -1)])
        let hostile = corners.filter { position.state(at: $0) == enemy }.count
        return corners.count == 4 ? hostile <= 1 : hostile == 0
    }

    private static func around(_ point: Point, size: BoardSize, offsets: [(Int, Int)]) -> [Point] {
        offsets.compactMap { dx, dy in
            Point.at(x: point.x + dx, y: point.y + dy).flatMap { size.contains($0) ? $0 : nil }
        }
    }
}
