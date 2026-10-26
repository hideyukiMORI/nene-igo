import NeNeIgoCore

/// 対局の列: いまの局・黒白のキャスト・何局目か・通算の勝敗（ARC-004）。
///
/// 値型で、1 歩進めると新しい値を返す。時計を知らない（「何秒に 1 歩進めるか」は合成ルートが決める）。
/// 乱数は引数から受け取るので、同じシードの乱数源からは同じ対局の列が出る（FR-05 の決定性）。
/// 手は手番の側のキャストの設定で MCTS が選ぶ（ADR 0010）。
/// 移植元: NeNe Reversi `Sources/NeNeReversiEngine/GameSeries.swift`（コミット e4a6f52）。
public struct GameSeries: Sendable, Hashable {
    public let game: Game
    /// この局の黒と白のキャスト。
    public let players: Players
    /// 何局目か（1 から）。
    public let gameNumber: Int
    /// 終わった局の通算。いまの局が終わった時点で数える。
    public let tally: Tally
    /// 局ごとに 2 名を選ぶ顔ぶれ（製品は `Persona.cast` の 4 名）。
    let roster: [Persona]

    private init(game: Game, players: Players, gameNumber: Int, tally: Tally, roster: [Persona]) {
        self.game = game
        self.players = players
        self.gameNumber = gameNumber
        self.tally = tally
        self.roster = roster
    }

    private static let newGame = Game.starting(size: .nineteen, komi: .standard)

    /// 19 路・コミ 7.5 の第 1 局から始まる列（REQUIREMENTS の Q4・Q5）。キャストは 4 名から局ごとに乱数で組む。
    public static func first(using generator: inout some RandomNumberGenerator) -> GameSeries {
        first(roster: Persona.cast, using: &generator)
    }

    /// 顔ぶれを決めた列（計測と `@testable import` のテストが速い設定で回すため）。2 名以上。
    static func first(roster: [Persona], using generator: inout some RandomNumberGenerator) -> GameSeries {
        precondition(roster.count >= 2, "2 名以上")
        let players = Players.drawn(from: roster, using: &generator)
        return GameSeries(game: newGame, players: players, gameNumber: 1, tally: .zero, roster: roster)
    }

    /// 黒白を決めた列（計測のため）。次の局からはこの 2 名で黒白を乱数で決める。
    public static func first(players: Players) -> GameSeries {
        GameSeries(
            game: newGame, players: players, gameNumber: 1, tally: .zero, roster: [players.black, players.white])
    }

    /// 1 歩進める。いまの局が続いていれば手番の側が 1 手打ち、終わっていれば次の局を空の盤から新しいキャストで始める。
    public func advanced(using generator: inout some RandomNumberGenerator) -> GameSeries {
        guard case .ongoing = game.status else {
            return GameSeries(
                game: Self.newGame, players: .drawn(from: roster, using: &generator), gameNumber: gameNumber + 1,
                tally: tally, roster: roster)
        }
        let profile = players.persona(for: game.position.toMove).profile
        var next = game
        let move = MonteCarloSearch.choose(game, profile: profile, using: &generator)
        guard next.apply(move) == .applied else {
            preconditionFailure("探索は打てる手だけを返す: \(move)")
        }
        switch next.status {
        case .ongoing:
            return GameSeries(game: next, players: players, gameNumber: gameNumber, tally: tally, roster: roster)
        case .finished(let result):
            return GameSeries(
                game: next, players: players, gameNumber: gameNumber, tally: tally.recording(result), roster: roster)
        }
    }
}
