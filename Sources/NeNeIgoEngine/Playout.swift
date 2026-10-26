import NeNeIgoCore

/// プレイアウト: 自分の眼を埋めない乱数で終局まで打つ（ADR 0007・0010）。手の好み（`PlayoutStyle`）は候補を試す順だけを変える。
///
/// 空点のうち手番の側の眼でない点を乱数で 1 つ選んで `Game.apply` で打ち、打てなければ（自殺手・スーパーコウ）その点を候補から外して選び直す。
/// 合法判定は Core の 1 経路だけ（ARC-001）。候補が尽きればパスする。両者がパスすれば終局する。
enum Playout {
    /// 終局まで打ち切る。
    static func run(_ game: inout Game, style: PlayoutStyle, using generator: inout some RandomNumberGenerator) {
        while !game.isOver {
            move(&game, style: style, using: &generator)
        }
    }

    /// 手元の局に 1 手打つ（写しを作らずに進める）。
    static func move(_ game: inout Game, style: PlayoutStyle, using generator: inout some RandomNumberGenerator) {
        if case .contact = style, Bool.random(using: &generator), tryContact(&game, using: &generator) {
            return
        }
        var candidates = game.position.emptyPoints()
        let mover = game.position.toMove
        while !candidates.isEmpty {
            var pick = Int.random(in: 0..<candidates.count, using: &generator)
            if case .centerSeeking = style, onEdge(candidates[pick], game.position.size), Bool.random(using: &generator)
            {
                pick = Int.random(in: 0..<candidates.count, using: &generator)
            }
            let point = candidates[pick]
            if !EyeShape.isEye(point, of: mover, in: game.position), game.apply(.place(point)) == .applied {
                return
            }
            candidates.swapAt(pick, candidates.count - 1)
            candidates.removeLast()
        }
        guard game.apply(.pass) == .applied else {
            preconditionFailure("終局していない局のパスは拒まれない")
        }
    }

    /// 直前の手の周り 8 点を乱数の順に試す。打てたら true。
    private static func tryContact(_ game: inout Game, using generator: inout some RandomNumberGenerator) -> Bool {
        guard case .place(let last) = game.moves.last else {
            return false
        }
        let size = game.position.size
        let mover = game.position.toMove
        var around: [Point] = []
        for dy in -1...1 {
            for dx in -1...1 where dx != 0 || dy != 0 {
                if let point = Point.at(x: last.x + dx, y: last.y + dy), size.contains(point),
                    game.position.state(at: point) == .empty
                {
                    around.append(point)
                }
            }
        }
        for point in around.shuffled(using: &generator) where !EyeShape.isEye(point, of: mover, in: game.position) {
            if game.apply(.place(point)) == .applied {
                return true
            }
        }
        return false
    }

    private static func onEdge(_ point: Point, _ size: BoardSize) -> Bool {
        point.x == 0 || point.y == 0 || point.x == size.width - 1 || point.y == size.height - 1
    }
}
