import NeNeIgoCore
import Testing

/// パスと、連続 2 回のパスによる終局（FR-02・FR-04）。
@Suite struct PassTests {
    @Test func passHandsTheTurnOverWithoutChangingTheBoard() throws {
        let game = try Fixture.game("X../.../... X")
        let after = try Fixture.playing([.pass], from: game)
        #expect(after.position.toMove == .white)
        #expect(after.position.boardHash == game.position.boardHash)
        #expect(after.status == .ongoing)
        #expect(after.moves == [.pass])
    }

    @Test func twoConsecutivePassesEndTheGame() throws {
        let game = try Fixture.playing([.pass, .pass], from: try Fixture.game("X../.../... X"))
        switch game.status {
        case .finished(let result):
            #expect(result.score.black == 9)
            #expect(result.winner == .black)
        case .ongoing:
            Issue.record("連続 2 回のパスで終局していない")
        }
        #expect(Fixture.rejection(of: .pass, in: game) == .gameOver)
        #expect(Fixture.rejection(of: try Fixture.place(1, 1), in: game) == .gameOver)
    }

    @Test func aStoneBetweenPassesResetsTheCount() throws {
        let game = try Fixture.playing(
            [.pass, try Fixture.place(1, 1), .pass], from: try Fixture.game(".../.../... X"))
        #expect(game.status == .ongoing)
    }

    @Test func gameStartsOnAnEmptyBoardWithBlackToMove() throws {
        let size = try #require(BoardSize.make(width: 19, height: 19))
        let game = Game.starting(size: size, komi: .standard)
        #expect(size == BoardSize.nineteen)
        #expect(game.position.toMove == .black)
        #expect(game.position.count(of: .black) + game.position.count(of: .white) == 0)
        #expect(game.position.boardHash == 0)
        #expect(game.komi.halfPoints == 15)
    }
}
