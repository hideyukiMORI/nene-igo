/// 連と呼吸点（ADR 0005・0010）。連は持たず、必要なときに縦横の塗りつぶしで求める。
///
/// 塗りつぶしの印と積み上げは、19 路の番兵つきの配列の長さ（420 = `Zobrist.maximumCellCount`）の `InlineArray` に置き、
/// ヒープを確保しない（プレイアウトの速さ・ADR 0010）。
extension Position {
    /// `start` の石を含む連に呼吸点が 1 つでもあるか。見つかった時点で止める。
    static func chainHasLiberty(_ cells: [BoardCell], from start: Int, size: BoardSize) -> Bool {
        let color = cells[start]
        var visited = InlineArray<420, Bool>(repeating: false)
        var stack = InlineArray<420, Int>(repeating: 0)
        var top = 1
        stack[0] = start
        visited[start] = true
        while top > 0 {
            top -= 1
            let index = stack[top]
            for k in 0..<4 {
                let neighbor = size.neighbor(of: index, k)
                let cell = cells[neighbor]
                if cell == .empty {
                    return true
                }
                if cell == color && !visited[neighbor] {
                    visited[neighbor] = true
                    stack[top] = neighbor
                    top += 1
                }
            }
        }
        return false
    }

    /// `start` の石を含む連を盤から取り除き、取り除いた石の数を返す。ハッシュも差分で更新する。
    static func removeChain(_ cells: inout [BoardCell], from start: Int, size: BoardSize, hash: inout UInt64) -> Int {
        let color = cells[start]
        guard let stone = color.stone else {
            preconditionFailure("石の無い位置 \(start) の連は取れない")
        }
        var stack = InlineArray<420, Int>(repeating: 0)
        var top = 1
        stack[0] = start
        cells[start] = .empty
        var removed = 0
        while top > 0 {
            top -= 1
            let index = stack[top]
            removed += 1
            hash ^= Zobrist.key(at: index, for: stone)
            for k in 0..<4 {
                let neighbor = size.neighbor(of: index, k)
                if cells[neighbor] == color {
                    cells[neighbor] = .empty
                    stack[top] = neighbor
                    top += 1
                }
            }
        }
        return removed
    }

    /// 盤のすべての連に呼吸点があるか（合法な局面か）。連ごとに石を全部たどってから呼吸点の有無を見る。
    static func everyChainHasLiberty(_ cells: [BoardCell], size: BoardSize) -> Bool {
        var visited = InlineArray<420, Bool>(repeating: false)
        for index in cells.indices where cells[index].stone != nil && !visited[index] {
            if !wholeChainHasLiberty(cells, from: index, size: size, visited: &visited) {
                return false
            }
        }
        return true
    }

    /// 連の石を全部たどって印を付け、呼吸点が 1 つでもあったかを返す（印を連どうしで共有してよい）。
    /// 呼吸点で止める塗りつぶしの印を共有すると、同じ連の残りの石から呼吸点にたどり着けなくなる（ADR 0006 の欠陥）。
    private static func wholeChainHasLiberty(
        _ cells: [BoardCell],
        from start: Int,
        size: BoardSize,
        visited: inout InlineArray<420, Bool>
    ) -> Bool {
        let color = cells[start]
        var stack = InlineArray<420, Int>(repeating: 0)
        var top = 1
        stack[0] = start
        visited[start] = true
        var liberty = false
        while top > 0 {
            top -= 1
            let index = stack[top]
            for k in 0..<4 {
                let neighbor = size.neighbor(of: index, k)
                let cell = cells[neighbor]
                if cell == .empty {
                    liberty = true
                } else if cell == color && !visited[neighbor] {
                    visited[neighbor] = true
                    stack[top] = neighbor
                    top += 1
                }
            }
        }
        return liberty
    }
}
