import NeNeIgoCore
import Testing

/// 着手の経路（取り・自殺手の禁止）で空の盤からたどり着ける盤の配置が、合法局面とちょうど同じ数になること（ADR 0006）。
///
/// Tromp の公表ページ（TrompCount の出典）は「取りの規則により、対局に現れうる局面はちょうど合法局面である」と書く。
/// パスがあるのでどちらの色も続けて打てるものとし、局面スーパーコウは 1 局の履歴の規則なので、ここでは見ない。
@Suite struct ReachablePositionTests {
    /// 着手で数える大きさ。全部の置き方の数え上げ（LegalPositionCountTests）とは別の経路で同じ数になることを見る。
    static let sizes: [TrompCount] = TrompCount.enumerated.filter { $0.width * $0.height <= 14 }

    @Test(arguments: sizes)
    func playFromEmptyBoardReachesExactlyTheLegalPositions(_ expected: TrompCount) throws {
        let size = try #require(BoardSize.make(width: expected.width, height: expected.height))
        let start = Position.empty(size: size)
        var seen: Set<Position> = [start]
        var frontier = [start]
        while let position = frontier.popLast() {
            for next in ReachablePositionTests.successors(of: position) where seen.insert(next).inserted {
                frontier.append(next)
            }
        }
        #expect(seen.count == expected.legalPositions)
    }

    /// 黒と白のどちらかが 1 手打った後の盤（手番は黒にそろえる）。
    private static func successors(of position: Position) -> [Position] {
        let asWhite = blackToMove(position.play(.pass))
        return [position, asWhite].flatMap { mover in
            mover.size.points.compactMap { point -> Position? in
                switch mover.play(.place(point)) {
                case .played(let next, _):
                    return blackToMove(next.toMove == .black ? .played(next, captured: 0) : next.play(.pass))
                case .rejected:
                    return nil
                }
            }
        }
    }

    private static func blackToMove(_ outcome: PlayOutcome) -> Position {
        switch outcome {
        case .played(let position, _):
            return position
        case .rejected(let reason):
            preconditionFailure("パスは拒まれない: \(reason)")
        }
    }
}
