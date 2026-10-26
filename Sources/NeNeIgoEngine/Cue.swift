/// 発言のきっかけになる出来事（話す本人から見た向き・ADR 0011）。
public enum Cue: Sendable, Hashable, CaseIterable {
    case start
    /// 石を取った。
    case capture
    /// 石を取られた。
    case lost
    /// 5 子以上を一度に取った。
    case bigCapture
    /// 5 子以上を一度に取られた。
    case bigLoss
    /// 自分がパスした。
    case pass
    /// しばらく取り合いが無い。
    case idle
    case win
    case lose

    /// その出来事を言うときの気分。
    public var mood: Mood {
        switch self {
        case .capture, .bigCapture, .win:
            return .smug
        case .start, .pass, .idle:
            return .neutral
        case .lost, .bigLoss, .lose:
            return .grim
        }
    }
}
