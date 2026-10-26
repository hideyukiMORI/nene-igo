/// 中国ルールの数え方（FR-04）: 盤上の石＋その色の石だけに囲まれた空点。どちらの色にも接する空点（セキの駄目など）は誰のものでもない。
public struct AreaScore: Sendable, Hashable {
    /// 黒の石と地の合計。
    public let black: Int
    /// 白の石と地の合計。
    public let white: Int

    private init(black: Int, white: Int) {
        self.black = black
        self.white = white
    }

    /// 局面を数える。死に石の判定はしない（盤上の石はすべて生きているものとして数える）。
    public static func counting(_ position: Position) -> AreaScore {
        let cells = position.cells
        let size = position.size
        var black = position.count(of: .black)
        var white = position.count(of: .white)
        var visited = [Bool](repeating: false, count: cells.count)
        for start in cells.indices where cells[start] == .empty && !visited[start] {
            let region = emptyRegion(cells, from: start, size: size, visited: &visited)
            switch (region.touchesBlack, region.touchesWhite) {
            case (true, false):
                black += region.points
            case (false, true):
                white += region.points
            case (true, true), (false, false):
                continue
            }
        }
        return AreaScore(black: black, white: white)
    }

    private static func emptyRegion(
        _ cells: [BoardCell],
        from start: Int,
        size: BoardSize,
        visited: inout [Bool]
    ) -> EmptyRegion {
        var region = EmptyRegion(points: 0, touchesBlack: false, touchesWhite: false)
        var stack = [start]
        visited[start] = true
        while let index = stack.popLast() {
            region.points += 1
            for neighbor in size.neighbors(of: index) {
                switch cells[neighbor] {
                case .black:
                    region.touchesBlack = true
                case .white:
                    region.touchesWhite = true
                case .empty where !visited[neighbor]:
                    visited[neighbor] = true
                    stack.append(neighbor)
                case .empty, .offBoard:
                    continue
                }
            }
        }
        return region
    }
}
