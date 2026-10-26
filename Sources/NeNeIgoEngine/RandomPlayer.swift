import NeNeIgoCore

/// 自分の眼を埋めない乱数の打ち手（ADR 0007）。好みなしのプレイアウトの 1 手と同じ（`Playout`）。
public enum RandomPlayer {
    /// 次の 1 手を打った局。終局した局は渡さない。
    public static func play(_ game: Game, using generator: inout some RandomNumberGenerator) -> Game {
        var next = game
        Playout.move(&next, style: .scatter, using: &generator)
        return next
    }
}
