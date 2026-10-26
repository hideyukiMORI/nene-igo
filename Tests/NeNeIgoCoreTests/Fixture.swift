import NeNeIgoCore
import Testing

/// 手で作った局面の読み込み（テストの中だけで使う）。
enum Fixture {
    /// 局面の文字列表現を読む。読めなければテストを止める。
    static func position(_ text: String) throws -> Position {
        switch PositionCodec.decode(text) {
        case .decoded(let position):
            return position
        case .rejected(let reason):
            Issue.record("読めない局面 \(text): \(reason)")
            throw FixtureFailure.unreadable
        }
    }

    /// 局面から始めた 1 局（コミ 7.5）。
    static func game(_ text: String) throws -> Game {
        Game.starting(from: try position(text), komi: .standard)
    }

    /// 点。
    static func point(_ x: Int, _ y: Int) throws -> Point {
        try #require(Point.at(x: x, y: y))
    }

    /// 石を置く手。
    static func place(_ x: Int, _ y: Int) throws -> Move {
        .place(try point(x, y))
    }

    /// 打てたはずの手を打つ。打てなければテストを止める。
    static func playing(_ moves: [Move], from game: Game) throws -> Game {
        var current = game
        for move in moves {
            switch current.play(move) {
            case .played(let next):
                current = next
            case .rejected(let reason):
                Issue.record("打てるはずの手 \(move) が \(reason) で拒まれた")
                throw FixtureFailure.rejected
            }
        }
        return current
    }

    /// 手を打った結果の拒否理由（打てたら nil）。
    static func rejection(of move: Move, in game: Game) -> MoveRejection? {
        switch game.play(move) {
        case .played:
            return nil
        case .rejected(let reason):
            return reason
        }
    }
}
