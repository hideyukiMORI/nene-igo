/// 1 局の経過: いまの局面・打った手・アゲハマ・連続したパスの数・この局で現れた盤の配置（ARC-004）。
///
/// 「合法か」（盤の外・占有・自殺手・局面スーパーコウ）・「終局したか」・「何目差か」を決める経路は、それぞれ
/// `play(_:)`・`status`・`AreaScore.counting` の 1 つだけ（ARC-001）。手を打つと新しい値を返す。
public struct Game: Sendable, Hashable {
    /// いまの局面。
    public let position: Position
    /// 打った手の列（古い順・パスを含む）。
    public let moves: [Move]
    /// コミ。
    public let komi: Komi
    /// 黒が取った白石の数（アゲハマ・FR-10）。
    public let capturedByBlack: Int
    /// 白が取った黒石の数。
    public let capturedByWhite: Int
    /// 直前まで続いたパスの数。
    let consecutivePasses: Int
    /// この局で現れた盤の配置の Zobrist ハッシュ（始めの空の盤を含む・ADR 0005）。
    let seenBoards: Set<UInt64>

    private init(
        position: Position,
        moves: [Move],
        komi: Komi,
        captures: Captures,
        consecutivePasses: Int,
        seenBoards: Set<UInt64>
    ) {
        self.position = position
        self.moves = moves
        self.komi = komi
        self.capturedByBlack = captures.byBlack
        self.capturedByWhite = captures.byWhite
        self.consecutivePasses = consecutivePasses
        self.seenBoards = seenBoards
    }

    /// 空の盤から始まる 1 局（黒が先手・置き石なし）。
    public static func starting(size: BoardSize, komi: Komi) -> Game {
        starting(from: Position.empty(size: size), komi: komi)
    }

    /// 与えた局面から始まる 1 局（テストで手作りの局面から打つため）。
    public static func starting(from position: Position, komi: Komi) -> Game {
        Game(
            position: position,
            moves: [],
            komi: komi,
            captures: Captures(byBlack: 0, byWhite: 0),
            consecutivePasses: 0,
            seenBoards: [position.boardHash]
        )
    }

    /// 局の状態。連続 2 回のパスで終局し、中国ルールの数え方とコミで勝敗を決める。
    public var status: GameStatus {
        consecutivePasses >= 2 ? .finished(GameResult.deciding(AreaScore.counting(position), komi: komi)) : .ongoing
    }

    /// 手を打つ。パスは終局していなければ常に打てる。
    public func play(_ move: Move) -> MoveOutcome {
        guard consecutivePasses < 2 else {
            return .rejected(.gameOver)
        }
        switch position.play(move) {
        case .rejected(let reason):
            return .rejected(.placement(reason))
        case .played(let next, let captured):
            return advance(to: next, by: move, captured: captured)
        }
    }

    private func advance(to next: Position, by move: Move, captured: Int) -> MoveOutcome {
        var captures = Captures(byBlack: capturedByBlack, byWhite: capturedByWhite)
        switch position.toMove {
        case .black:
            captures.byBlack += captured
        case .white:
            captures.byWhite += captured
        }
        switch move {
        case .pass:
            let game = Game(
                position: next, moves: moves + [move], komi: komi, captures: captures,
                consecutivePasses: consecutivePasses + 1, seenBoards: seenBoards)
            return .played(game)
        case .place:
            guard !seenBoards.contains(next.boardHash) else {
                return .rejected(.superko)
            }
            let game = Game(
                position: next, moves: moves + [move], komi: komi, captures: captures,
                consecutivePasses: 0, seenBoards: seenBoards.union([next.boardHash]))
            return .played(game)
        }
    }
}
