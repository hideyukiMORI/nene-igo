import NeNeIgoCore

/// 自分の眼を埋めない乱数の打ち手（Phase 3 の手順 2・ADR 0007）。MCTS のプレイアウトの方針の最初の形でもある。
///
/// 空点のうち手番の側の眼でない点を乱数の順に試し、Core の `Game.play` が打てると言った最初の手を打つ（合法判定は Core の 1 経路だけ・ARC-001）。
/// どこにも打てなければパスする。両者がパスすれば終局する。
public enum RandomPlayer {
    /// 次の 1 手を打った局。終局した局は渡さない。
    public static func play(_ game: Game, using generator: inout some RandomNumberGenerator) -> Game {
        let position = game.position
        let candidates = position.size.points.filter { point in
            position.state(at: point) == .empty && !EyeShape.isEye(point, of: position.toMove, in: position)
        }
        for point in candidates.shuffled(using: &generator) {
            switch game.play(.place(point)) {
            case .played(let next):
                return next
            case .rejected:
                continue
            }
        }
        switch game.play(.pass) {
        case .played(let next):
            return next
        case .rejected(let reason):
            preconditionFailure("終局していない局のパスは拒まれない: \(reason)")
        }
    }
}
