/// 1 局の状態。
public enum GameStatus: Sendable, Hashable {
    /// まだ打てる。
    case ongoing
    /// 連続 2 回のパスで終局した（FR-04）。
    case finished(GameResult)
}
