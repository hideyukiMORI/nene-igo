import NeNeIgoCore

/// 画面に出す文言。文言のリテラルを持つのはここだけ。
///
/// ASCII の英語の大文字にしてある。1 文字 1 桁の前提（ADR 0007）を全角や幅の曖昧な文字で崩さないため。
/// 移植元: NeNe Reversi `Sources/NeNeReversiRender/Wording.swift`（コミット e4a6f52）。石の数と引き分けを、アゲハマ・コミ・`B+3.5` の結果に替えた。
enum Wording {
    static let title = "NENE//IGO"
    static let match = "MATCH"
    static let score = "SCORE"
    static let log = "LOG"
    static let result = "RESULT"
    static let help = "Q QUIT"

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func game(_ number: Int) -> String {
        "GAME   " + padded(number, width: 3)
    }

    /// その色を受け持つキャストの名前。
    static func player(_ stone: Stone, _ persona: String) -> String {
        name(stone) + "  " + persona
    }

    static func turn(_ side: Stone?) -> String {
        "TURN   " + (side.map(name) ?? "OVER")
    }

    static func moveCount(_ count: Int) -> String {
        "MOVES  " + padded(count, width: 3)
    }

    /// アゲハマ（取った石の数）。
    static func captures(black: Int, white: Int) -> String {
        "CAPS   B " + padded(black, width: 3) + "  W " + padded(white, width: 3)
    }

    static func komi(_ komi: Komi) -> String {
        "KOMI   " + points(halfPoints: komi.halfPoints)
    }

    static func wins(_ stone: Stone, _ count: Int) -> String {
        name(stone) + "  " + padded(count, width: 3)
    }

    static func logEntry(number: Int, mover: Stone, move: String) -> String {
        padded(number, width: 3) + " " + String(name(mover).prefix(1)) + " " + move
    }

    /// 終局の結果（例 `B+3.5`）。
    static func outcome(_ result: GameResult) -> String {
        String(name(result.winner).prefix(1)) + "+" + points(halfPoints: result.marginInHalfPoints)
    }

    /// 数えた石と地。
    static func area(_ score: AreaScore) -> String {
        "AREA   B " + padded(score.black, width: 3) + "  W " + padded(score.white, width: 3)
    }

    static func nextGame(in seconds: Int) -> String {
        "NEXT GAME IN " + String(seconds)
    }

    static func tooSmall(need size: ScreenSize) -> String {
        "TERMINAL TOO SMALL: NEED \(size.columns)x\(size.rows)"
    }

    static func name(_ stone: Stone) -> String {
        switch stone {
        case .black:
            return "BLACK"
        case .white:
            return "WHITE"
        }
    }

    /// 半目の単位の数を目の表記にする（15 → `7.5`・6 → `3`）。
    static func points(halfPoints: Int) -> String {
        String(halfPoints / 2) + (halfPoints % 2 == 1 ? ".5" : "")
    }

    private static func padded(_ number: Int, width: Int) -> String {
        let digits = String(number)
        return String(repeating: "0", count: max(width - digits.count, 0)) + digits
    }
}
