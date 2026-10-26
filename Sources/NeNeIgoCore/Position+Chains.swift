/// 連と呼吸点（ADR 0005）。連は持たず、必要なときに縦横の塗りつぶしで求める。
extension Position {
    /// `start` の石を含む連に呼吸点が 1 つでもあるか。見つかった時点で止める。
    static func chainHasLiberty(_ cells: [BoardCell], from start: Int, size: BoardSize) -> Bool {
        var visited = [Bool](repeating: false, count: cells.count)
        return chainHasLiberty(cells, from: start, size: size, visited: &visited)
    }

    /// `start` の石を含む連を盤から取り除き、取り除いた石の数を返す。ハッシュも差分で更新する。
    static func removeChain(_ cells: inout [BoardCell], from start: Int, size: BoardSize, hash: inout UInt64) -> Int {
        let color = cells[start]
        guard let stone = color.stone else {
            preconditionFailure("石の無い位置 \(start) の連は取れない")
        }
        var stack = [start]
        cells[start] = .empty
        var removed = 0
        while let index = stack.popLast() {
            removed += 1
            hash ^= Zobrist.key(at: index, for: stone)
            for neighbor in size.neighbors(of: index) where cells[neighbor] == color {
                cells[neighbor] = .empty
                stack.append(neighbor)
            }
        }
        return removed
    }

    /// 盤のすべての連に呼吸点があるか（合法な局面か）。連ごとに石を全部たどってから呼吸点の有無を見る。
    static func everyChainHasLiberty(_ cells: [BoardCell], size: BoardSize) -> Bool {
        var visited = [Bool](repeating: false, count: cells.count)
        for index in cells.indices where cells[index].stone != nil && !visited[index] {
            if !wholeChainHasLiberty(cells, from: index, size: size, visited: &visited) {
                return false
            }
        }
        return true
    }

    /// 呼吸点が見つかったら止める塗りつぶし。印は呼び出しごとの新しい配列に付ける
    /// （途中で止めた印を他の連の判定と共有すると、同じ連の残りの石から呼吸点にたどり着けなくなる）。
    private static func chainHasLiberty(
        _ cells: [BoardCell],
        from start: Int,
        size: BoardSize,
        visited: inout [Bool]
    ) -> Bool {
        let color = cells[start]
        var stack = [start]
        visited[start] = true
        while let index = stack.popLast() {
            for neighbor in size.neighbors(of: index) {
                if cells[neighbor] == .empty {
                    return true
                }
                if cells[neighbor] == color && !visited[neighbor] {
                    visited[neighbor] = true
                    stack.append(neighbor)
                }
            }
        }
        return false
    }

    /// 連の石を全部たどって印を付け、呼吸点が 1 つでもあったかを返す（印を連どうしで共有してよい）。
    private static func wholeChainHasLiberty(
        _ cells: [BoardCell],
        from start: Int,
        size: BoardSize,
        visited: inout [Bool]
    ) -> Bool {
        let color = cells[start]
        var stack = [start]
        var liberty = false
        visited[start] = true
        while let index = stack.popLast() {
            for neighbor in size.neighbors(of: index) {
                if cells[neighbor] == .empty {
                    liberty = true
                } else if cells[neighbor] == color && !visited[neighbor] {
                    visited[neighbor] = true
                    stack.append(neighbor)
                }
            }
        }
        return liberty
    }
}
