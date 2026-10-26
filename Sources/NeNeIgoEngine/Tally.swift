import NeNeIgoCore

/// 通算の勝敗（FR-10）。中国ルールとコミ 7.5 なので引き分けは無い（FR-04）。
public struct Tally: Sendable, Hashable {
    public let blackWins: Int
    public let whiteWins: Int

    private init(blackWins: Int, whiteWins: Int) {
        self.blackWins = blackWins
        self.whiteWins = whiteWins
    }

    /// 1 局も終わっていない。
    public static let zero = Tally(blackWins: 0, whiteWins: 0)

    /// 終わった局の数。
    public var finishedGames: Int {
        blackWins + whiteWins
    }

    /// 1 局の結果を足した通算。
    func recording(_ result: GameResult) -> Tally {
        switch result.winner {
        case .black:
            return Tally(blackWins: blackWins + 1, whiteWins: whiteWins)
        case .white:
            return Tally(blackWins: blackWins, whiteWins: whiteWins + 1)
        }
    }
}
