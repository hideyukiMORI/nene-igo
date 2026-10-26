import NeNeIgoCore
import Testing

/// 乱数で打った多数の手の、1 手ごとの不変条件（ADR 0006）:
/// 石の数の保存（置いた 1 − 取られた数）とアゲハマの合計・Zobrist の差分更新と全計算の一致・文字列表現の往復。
@Suite struct InvariantTests {
    struct Run: Sendable, CustomTestStringConvertible {
        let width: Int
        let height: Int
        let games: Int
        let maximumMoves: Int

        var testDescription: String {
            "\(width)x\(height) \(games) 局"
        }
    }

    static let runs = [
        Run(width: 5, height: 5, games: 40, maximumMoves: 200),
        Run(width: 9, height: 9, games: 10, maximumMoves: 400),
        Run(width: 19, height: 19, games: 2, maximumMoves: 700),
    ]

    @Test(arguments: runs)
    func everyMoveKeepsTheInvariants(_ run: Run) throws {
        let size = try #require(BoardSize.make(width: run.width, height: run.height))
        var generator = SplitMix64(seed: UInt64(run.width * 1_000 + run.games))
        var placements = 0
        for _ in 0..<run.games {
            var game = Game.starting(size: size, komi: .standard)
            for _ in 0..<run.maximumMoves where game.status == .ongoing {
                let next = InvariantTests.randomLegalMove(in: game, using: &generator)
                try InvariantTests.check(game, next)
                placements += next.moves.last == .pass ? 0 : 1
                game = next
            }
        }
        #expect(placements > run.games)
    }

    private static func check(_ before: Game, _ after: Game) throws {
        let mover = before.position.toMove
        let taken =
            mover == .black
            ? after.capturedByBlack - before.capturedByBlack : after.capturedByWhite - before.capturedByWhite
        let placed = after.moves.last == .pass ? 0 : 1
        #expect(after.position.count(of: mover) == before.position.count(of: mover) + placed)
        #expect(after.position.count(of: mover.opponent) == before.position.count(of: mover.opponent) - taken)
        let blackLost = after.capturedByWhite
        let whiteLost = after.capturedByBlack
        let blackPlaced = after.moves.enumerated().filter { $0.offset % 2 == 0 && $0.element != .pass }.count
        let whitePlaced = after.moves.enumerated().filter { $0.offset % 2 == 1 && $0.element != .pass }.count
        #expect(after.position.count(of: .black) == blackPlaced - blackLost)
        #expect(after.position.count(of: .white) == whitePlaced - whiteLost)
        let text = PositionCodec.encode(after.position)
        let reread = try Fixture.position(text)
        #expect(reread.boardHash == after.position.boardHash)
        #expect(PositionCodec.encode(reread) == text)
    }

    /// 空点を乱数の順に試し、最初に打てた手を打つ。どこにも打てないか、10 回に 1 回はパスする。
    private static func randomLegalMove(in game: Game, using generator: inout SplitMix64) -> Game {
        let empty = game.position.size.points.filter { game.position.state(at: $0) == .empty }
        let wantsPass = Int.random(in: 0..<10, using: &generator) == 0
        for point in wantsPass ? [] : empty.shuffled(using: &generator) {
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
            preconditionFailure("終局前のパスは拒まれない: \(reason)")
        }
    }
}
