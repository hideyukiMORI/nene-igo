/// 終局の結果（FR-04）。勝ちの側と、半目の単位の差。表示（`B+3.5` など）は Render が作る。
public struct GameResult: Sendable, Hashable {
    /// 数えた石と地。
    public let score: AreaScore
    /// コミ。
    public let komi: Komi

    private init(score: AreaScore, komi: Komi) {
        self.score = score
        self.komi = komi
    }

    /// 数えた結果とコミから決める。
    public static func deciding(_ score: AreaScore, komi: Komi) -> GameResult {
        GameResult(score: score, komi: komi)
    }

    /// 黒から見た差（半目の単位）。コミは奇数の半目なので 0 にならない。
    private var blackLeadInHalfPoints: Int {
        (score.black - score.white) * 2 - komi.halfPoints
    }

    /// 勝った側。
    public var winner: Stone {
        blackLeadInHalfPoints > 0 ? .black : .white
    }

    /// 勝った側から見た差（半目の単位・正の奇数）。3.5 目なら 7。
    public var marginInHalfPoints: Int {
        abs(blackLeadInHalfPoints)
    }
}
