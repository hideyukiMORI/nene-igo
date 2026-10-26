import NeNeIgoCore

/// 1 手で起きたこと（発言のきっかけを選ぶための事実）。
struct MoveFacts: Sendable, Hashable {
    let mover: Stone
    /// その手で取った石の数。
    let captured: Int
    let isPass: Bool

    /// 打つ前と後の局から読む。
    static func between(_ before: Game, _ after: Game) -> MoveFacts {
        let captured =
            (after.capturedByBlack + after.capturedByWhite) - (before.capturedByBlack + before.capturedByWhite)
        return MoveFacts(mover: before.position.toMove, captured: captured, isPass: after.moves.last == .pass)
    }
}
