import NeNeIgoCore
import Testing

@testable import NeNeIgoEngine

/// MCTS（FR-03・ADR 0010）と、その下で使う ln と平方根。
struct SearchTests {
    static func game(_ text: String) -> Game {
        switch PositionCodec.decode(text) {
        case .decoded(let position):
            return Game.starting(from: position, komi: .standard)
        case .rejected(let reason):
            Issue.record("読めない局面: \(reason)")
            return Game.starting(size: .nineteen, komi: .standard)
        }
    }

    static func profile(_ playouts: Int) -> SearchProfile {
        guard let profile = SearchProfile.make(playouts: playouts, exploration: 1.0, style: .scatter, openingMoves: 0)
        else {
            preconditionFailure("範囲外")
        }
        return profile
    }

    /// 9 路で、100 プレイアウトの MCTS は乱数の打ち手にほとんど勝つ（探索が手を選べていること）。黒白を入れ替えて 10 局。
    @Test func searchBeatsTheRandomPlayerOnNineByNine() throws {
        let size = try #require(BoardSize.make(width: 9, height: 9))
        var generator = SplitMix64(seed: 2026)
        var searchWins = 0
        for round in 0..<10 {
            let searchSide: Stone = round % 2 == 0 ? .black : .white
            var game = Game.starting(size: size, komi: .standard)
            while !game.isOver {
                if game.position.toMove == searchSide {
                    game.apply(MonteCarloSearch.choose(game, profile: Self.profile(100), using: &generator))
                } else {
                    game = RandomPlayer.play(game, using: &generator)
                }
            }
            if case .finished(let result) = game.status, result.winner == searchSide {
                searchWins += 1
            }
        }
        #expect(searchWins >= 9)
    }

    /// 返す手は必ず Core が打てると言う手。同じ乱数の種からは同じ手。
    @Test func searchReturnsALegalMoveDeterministically() {
        var game = Game.starting(size: .nineteen, komi: .standard)
        var generator = SplitMix64(seed: 9)
        for _ in 0..<12 {
            var again = generator
            let move = MonteCarloSearch.choose(game, profile: Self.profile(20), using: &generator)
            #expect(MonteCarloSearch.choose(game, profile: Self.profile(20), using: &again) == move)
            #expect(game.apply(move) == .applied)
        }
    }

    /// 打てる意味のある手（眼でない空点）が無ければパスする。
    @Test func searchPassesWhenOnlyEyesRemain() {
        let game = Self.game(".X.X./XXXXX/XXXXX/OOOOO/.O.O. X")
        var generator = SplitMix64(seed: 4)
        #expect(MonteCarloSearch.choose(game, profile: Self.profile(10), using: &generator) == .pass)
    }

    @Test func naturalLogAndSquareRootAreAccurate() {
        #expect(abs(NaturalLog.ln(1)) < 1e-12)
        #expect(abs(NaturalLog.ln(10) - 2.302_585_092_994_046) < 1e-9)
        #expect(abs(NaturalLog.ln(12_345) - 9.421_006_401_217_131) < 1e-9)
        #expect(abs(SquareRoot.of(2) - 1.414_213_562_373_095) < 1e-12)
        #expect(abs(SquareRoot.of(1e-6) - 1e-3) < 1e-12)
        #expect(SquareRoot.of(0) == 0)
    }

    @Test func castHasFourDistinctNamesAndPlayersAreDistinct() {
        #expect(Set(Persona.cast.map(\.name)).count == 4)
        var generator = SplitMix64(seed: 1)
        for _ in 0..<20 {
            let players = Players.drawn(from: Persona.cast, using: &generator)
            #expect(players.black != players.white)
        }
    }
}
