/// 1 局の経過: いまの局面・打った手・アゲハマ・連続したパスの数・この局で現れた盤の配置（ARC-004）。
///
/// 「合法か」（盤の外・占有・自殺手・局面スーパーコウ）・「終局したか」・「何目差か」を決める経路は、それぞれ
/// `apply(_:)`・`status`・`AreaScore.counting` の 1 つだけ（ARC-001）。`play(_:)` は写しに `apply(_:)` で打って新しい値を返す。
/// プレイアウトは同じ `apply(_:)` で手元の写しを進める（第 2 の合法判定を作らない・ADR 0010）。
public struct Game: Sendable, Hashable {
    /// いまの局面。
    public private(set) var position: Position
    /// 打った手の列（古い順・パスを含む）。
    public private(set) var moves: [Move]
    /// コミ。
    public let komi: Komi
    /// 黒が取った白石の数（アゲハマ・FR-10）。
    public private(set) var capturedByBlack: Int
    /// 白が取った黒石の数。
    public private(set) var capturedByWhite: Int
    /// 直前まで続いたパスの数。
    private(set) var consecutivePasses: Int
    /// この局で現れた盤の配置の Zobrist ハッシュ（始めの空の盤を含む・ADR 0005）。
    private(set) var seenBoards: Set<UInt64>

    private init(position: Position, komi: Komi) {
        self.position = position
        self.moves = []
        self.komi = komi
        self.capturedByBlack = 0
        self.capturedByWhite = 0
        self.consecutivePasses = 0
        self.seenBoards = [position.boardHash]
    }

    /// 空の盤から始まる 1 局（黒が先手・置き石なし）。
    public static func starting(size: BoardSize, komi: Komi) -> Game {
        starting(from: Position.empty(size: size), komi: komi)
    }

    /// 与えた局面から始まる 1 局（テストで手作りの局面から打つため）。
    public static func starting(from position: Position, komi: Komi) -> Game {
        Game(position: position, komi: komi)
    }

    /// 局の状態。連続 2 回のパスで終局し、中国ルールの数え方とコミで勝敗を決める。
    public var status: GameStatus {
        isOver ? .finished(GameResult.deciding(AreaScore.counting(position), komi: komi)) : .ongoing
    }

    /// 終局したか（数えずに知るため。プレイアウトの終わりの判定に使う）。
    public var isOver: Bool {
        consecutivePasses >= 2
    }

    /// 手を打った新しい局を返す（元の局は変えない）。
    public func play(_ move: Move) -> MoveOutcome {
        var next = self
        switch next.apply(move) {
        case .applied:
            return .played(next)
        case .rejected(let reason):
            return .rejected(reason)
        }
    }

    /// 手をこの局に打つ（唯一の経路）。パスは終局していなければ常に打てる。拒んだときは局を変えない。
    @discardableResult
    public mutating func apply(_ move: Move) -> MoveApplication {
        guard consecutivePasses < 2 else {
            return .rejected(.gameOver)
        }
        var next = position
        let mover = position.toMove
        let captured: Int
        switch next.apply(move) {
        case .rejected(let reason):
            return .rejected(.placement(reason))
        case .placed(let count):
            captured = count
        }
        switch move {
        case .pass:
            consecutivePasses += 1
        case .place:
            guard seenBoards.insert(next.boardHash).inserted else {
                return .rejected(.superko)
            }
            consecutivePasses = 0
        }
        position = next
        moves.append(move)
        switch mover {
        case .black:
            capturedByBlack += captured
        case .white:
            capturedByWhite += captured
        }
        return .applied
    }
}
