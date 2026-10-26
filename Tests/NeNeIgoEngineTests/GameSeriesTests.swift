import NeNeIgoCore
import Testing

@testable import NeNeIgoEngine

/// 対局の列（FR-04・FR-05 の決定性）と、自分の眼を埋めない乱数の打ち手（ADR 0007）。
struct GameSeriesTests {
    /// 局が `count` 個終わるまで進めた列の、各局の棋譜。
    static func records(seed: UInt64, count: Int) -> [[Move]] {
        var generator = SplitMix64(seed: seed)
        var series = GameSeries.first
        var finished: [[Move]] = []
        while finished.count < count {
            let next = series.advanced(using: &generator)
            if next.gameNumber != series.gameNumber {
                finished.append(series.game.moves)
            }
            series = next
        }
        return finished
    }

    @Test func sameSeedGivesTheSameGames() {
        #expect(Self.records(seed: 42, count: 2) == Self.records(seed: 42, count: 2))
    }

    @Test func differentSeedsGiveDifferentGames() {
        #expect(Self.records(seed: 1, count: 1) != Self.records(seed: 2, count: 1))
    }

    /// 1 歩ごとに、打った手は前の局から 1 手だけ伸び、Core が打てると言った手である。終局した局は数えて、次の局を空の盤から始める。
    @Test func everyStepIsOneLegalMoveAndFinishedGamesAreCounted() {
        var generator = SplitMix64(seed: 7)
        var series = GameSeries.first
        while series.gameNumber <= 2 {
            let next = series.advanced(using: &generator)
            if next.gameNumber == series.gameNumber {
                #expect(next.game.moves.dropLast() == series.game.moves[...])
                if let move = next.game.moves.last {
                    #expect(series.game.play(move) == .played(next.game))
                }
            } else {
                #expect(series.game.status != .ongoing)
                #expect(next.game == Game.starting(size: .nineteen, komi: .standard))
                #expect(next.tally.finishedGames == series.gameNumber)
            }
            series = next
        }
        #expect(series.tally.finishedGames == 2)
    }

    /// 終局が必ず来る（WORK-ORDER 第 2-2 節）: 多数の乱数の対局が、手数の上限なしに連続 2 回のパスで終わる。
    /// 手数の最大と平均を ADR 0007 に書いた（このテストは上限を置かず、終わらなければ時間切れで気づく）。
    @Test(arguments: [(5, 200), (9, 100), (19, 20)])
    func randomGamesAlwaysEndWithTwoPasses(_ side: Int, _ games: Int) throws {
        let size = try #require(BoardSize.make(width: side, height: side))
        var generator = SplitMix64(seed: UInt64(side))
        for _ in 0..<games {
            var game = Game.starting(size: size, komi: .standard)
            while game.status == .ongoing {
                game = RandomPlayer.play(game, using: &generator)
            }
            #expect(game.moves.suffix(2) == [.pass, .pass])
        }
    }

    @Test func randomPlayerDoesNotFillItsOwnEye() throws {
        // 黒の眼が (0,0) にある。黒は (0,0) 以外のどこかに打つか、打てなければパスする
        let game = Game.starting(from: try GameSeriesTests.position(".X.../XX.../...../...../..... X"), komi: .standard)
        var generator = SplitMix64(seed: 5)
        for _ in 0..<50 {
            let next = RandomPlayer.play(game, using: &generator)
            #expect(next.moves.last != .place(try #require(Point.at(x: 0, y: 4))))
        }
    }

    @Test func eyeShapeFollowsTheDiagonalRule() throws {
        let center = try #require(Point.at(x: 2, y: 2))
        let corner = try #require(Point.at(x: 0, y: 4))
        let open = try GameSeriesTests.position("...../.XXX./.X.X./.XXX./..... X")
        #expect(EyeShape.isEye(center, of: .black, in: open))
        #expect(!EyeShape.isEye(center, of: .white, in: open))
        let oneEnemy = try GameSeriesTests.position("...../.OXX./.X.X./.XXX./..... X")
        #expect(EyeShape.isEye(center, of: .black, in: oneEnemy))
        let twoEnemies = try GameSeriesTests.position("...../.OXO./.X.X./.XXX./..... X")
        #expect(!EyeShape.isEye(center, of: .black, in: twoEnemies))
        let cornerEye = try GameSeriesTests.position(".X.../XX.../...../...../..... X")
        #expect(EyeShape.isEye(corner, of: .black, in: cornerEye))
        let falseCorner = try GameSeriesTests.position(".X.../XO.../...../...../..... X")
        #expect(!EyeShape.isEye(corner, of: .black, in: falseCorner))
    }

    static func position(_ text: String) throws -> Position {
        switch PositionCodec.decode(text) {
        case .decoded(let position):
            return position
        case .rejected(let reason):
            Issue.record("読めない局面: \(reason)")
            return Position.empty(size: .nineteen)
        }
    }
}
