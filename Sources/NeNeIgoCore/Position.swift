/// 局面: 盤上の石と手番（ARC-004）。手を打つと新しい値を返す（ADR 0005）。
///
/// 盤は番兵つきの 1 次元配列 `cells` で持ち、盤上の石の配置の Zobrist ハッシュ `boardHash` を差分で更新する。
/// 「打てるか」（盤の外・占有・自殺手）と取りを決める経路は `play(_:)` だけ。局面スーパーコウは 1 局の履歴が要るので `Game` が見る。
public struct Position: Sendable, Hashable {
    /// 盤の大きさ。
    public let size: BoardSize
    /// 次に打つ側。
    public let toMove: Stone
    /// 盤上の石の配置の Zobrist ハッシュ（手番を含まない）。局面スーパーコウの判定に使う。
    public let boardHash: UInt64
    let cells: [BoardCell]

    private init(size: BoardSize, cells: [BoardCell], toMove: Stone, boardHash: UInt64) {
        self.size = size
        self.cells = cells
        self.toMove = toMove
        self.boardHash = boardHash
    }

    /// 石の無い盤で、黒の手番の局面。
    public static func empty(size: BoardSize) -> Position {
        Position(size: size, cells: blankCells(size: size), toMove: .black, boardHash: 0)
    }

    /// 点ごとの状態（`BoardSize.points` の順）と手番から局面を作る唯一のファクトリ。呼吸点の無い連があれば作らない。
    public static func make(size: BoardSize, states: [PointState], toMove: Stone) -> PositionOutcome {
        guard states.count == size.pointCount else {
            return .rejected(.wrongPointCount)
        }
        var cells = [BoardCell](repeating: .offBoard, count: size.cellCount)
        for y in 0..<size.height {
            for x in 0..<size.width {
                cells[(y + 1) * size.stride + x + 1] = cell(of: states[y * size.width + x])
            }
        }
        guard everyChainHasLiberty(cells, size: size) else {
            return .rejected(.chainWithoutLiberty)
        }
        return .made(Position(size: size, cells: cells, toMove: toMove, boardHash: Zobrist.hash(of: cells)))
    }

    /// 盤の中の点の状態。盤の外の点は渡さない。
    public func state(at point: Point) -> PointState {
        precondition(size.contains(point), "盤の外の点 \(point)")
        return cells[size.index(of: point)].pointState
    }

    /// 盤上のその色の石の数。
    public func count(of stone: Stone) -> Int {
        let target = BoardCell.of(stone)
        return cells.reduce(0) { $1 == target ? $0 + 1 : $0 }
    }

    /// 手を打つ。パスは手番だけを渡す。石を置く手は、盤の外・占有・自殺手なら打てない。相手の連の呼吸点を 0 にしたら取る。
    public func play(_ move: Move) -> PlayOutcome {
        switch move {
        case .pass:
            return .played(
                Position(size: size, cells: cells, toMove: toMove.opponent, boardHash: boardHash), captured: 0)
        case .place(let point):
            return place(at: point)
        }
    }

    private func place(at point: Point) -> PlayOutcome {
        guard size.contains(point) else {
            return .rejected(.outsideBoard)
        }
        let index = size.index(of: point)
        guard cells[index] == .empty else {
            return .rejected(.occupied)
        }
        var next = cells
        var hash = boardHash ^ Zobrist.key(at: index, for: toMove)
        next[index] = BoardCell.of(toMove)
        let enemy = BoardCell.of(toMove.opponent)
        var captured = 0
        for neighbor in size.neighbors(of: index) where next[neighbor] == enemy {
            if !Position.chainHasLiberty(next, from: neighbor, size: size) {
                captured += Position.removeChain(&next, from: neighbor, size: size, hash: &hash)
            }
        }
        if captured == 0 && !Position.chainHasLiberty(next, from: index, size: size) {
            return .rejected(.suicide)
        }
        return .played(Position(size: size, cells: next, toMove: toMove.opponent, boardHash: hash), captured: captured)
    }

    private static func blankCells(size: BoardSize) -> [BoardCell] {
        var cells = [BoardCell](repeating: .offBoard, count: size.cellCount)
        for y in 0..<size.height {
            for x in 0..<size.width {
                cells[(y + 1) * size.stride + x + 1] = .empty
            }
        }
        return cells
    }

    private static func cell(of state: PointState) -> BoardCell {
        switch state {
        case .empty:
            return .empty
        case .black:
            return .black
        case .white:
            return .white
        }
    }
}
