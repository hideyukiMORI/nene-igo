/// 局面: 盤上の石と手番（ARC-004）。手を打つと新しい値を返す（ADR 0005）。
///
/// 盤は番兵つきの 1 次元配列 `cells` で持ち、盤上の石の配置の Zobrist ハッシュ `boardHash` を差分で更新する。
/// 「打てるか」（盤の外・占有・自殺手）と取りを決める経路は `apply(_:)` だけで、`play(_:)` はその写しに打つ（ADR 0010）。
/// 局面スーパーコウは 1 局の履歴が要るので `Game` が見る。
public struct Position: Sendable, Hashable {
    /// 盤の大きさ。
    public let size: BoardSize
    /// 次に打つ側。
    public private(set) var toMove: Stone
    /// 盤上の石の配置の Zobrist ハッシュ（手番を含まない）。局面スーパーコウの判定に使う。
    public private(set) var boardHash: UInt64
    private(set) var cells: [BoardCell]

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

    /// 空点（`BoardSize.points` の順）。プレイアウトが毎手の候補を作るのに使う。
    public func emptyPoints() -> [Point] {
        var points: [Point] = []
        points.reserveCapacity(size.pointCount)
        for y in 0..<size.height {
            for x in 0..<size.width where cells[(y + 1) * size.stride + x + 1] == .empty {
                if let point = Point.at(x: x, y: y) {
                    points.append(point)
                }
            }
        }
        return points
    }

    /// 盤上のその色の石の数。
    public func count(of stone: Stone) -> Int {
        let target = BoardCell.of(stone)
        return cells.reduce(0) { $1 == target ? $0 + 1 : $0 }
    }

    /// 手を打った新しい局面を返す（元の局面は変えない）。打つ経路は `apply(_:)` の 1 つ。
    public func play(_ move: Move) -> PlayOutcome {
        var next = self
        switch next.apply(move) {
        case .placed(let captured):
            return .played(next, captured: captured)
        case .rejected(let reason):
            return .rejected(reason)
        }
    }

    /// 手をこの局面に打つ（唯一の経路）。パスは手番だけを渡す。石を置く手は、盤の外・占有・自殺手なら打たずに理由を返す。
    /// 相手の連の呼吸点を 0 にしたら取る。拒んだときは局面を変えない。
    mutating func apply(_ move: Move) -> Placement {
        switch move {
        case .pass:
            toMove = toMove.opponent
            return .placed(captured: 0)
        case .place(let point):
            return place(at: point)
        }
    }

    private mutating func place(at point: Point) -> Placement {
        guard size.contains(point) else {
            return .rejected(.outsideBoard)
        }
        let index = size.index(of: point)
        guard cells[index] == .empty else {
            return .rejected(.occupied)
        }
        let key = Zobrist.key(at: index, for: toMove)
        cells[index] = BoardCell.of(toMove)
        boardHash ^= key
        let enemy = BoardCell.of(toMove.opponent)
        var captured = 0
        for k in 0..<4 {
            let neighbor = size.neighbor(of: index, k)
            if cells[neighbor] == enemy && !Position.chainHasLiberty(cells, from: neighbor, size: size) {
                captured += Position.removeChain(&cells, from: neighbor, size: size, hash: &boardHash)
            }
        }
        if captured == 0 && !Position.chainHasLiberty(cells, from: index, size: size) {
            // 何も取っていないので、置いた石を戻せば元の局面になる
            cells[index] = .empty
            boardHash ^= key
            return .rejected(.suicide)
        }
        toMove = toMove.opponent
        return .placed(captured: captured)
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
