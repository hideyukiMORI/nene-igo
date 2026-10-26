import NeNeIgoCore

/// 画面に出す文言。文言のリテラルを持つのはここだけ（キャラクターの名前とセリフは Engine の性格が持つ）。
///
/// 英語の大文字の ASCII にしてある。罫線とブロックは `FrameGlyphs` が持ち、幅を測ってから使う（ADR 0011）。
/// 移植元: NeNe Reversi `Sources/NeNeReversiRender/Wording.swift`（コミット 0ee4526）。石の数と引き分けを、アゲハマ・コミ・`B+3.5` の結果に替えた。
enum Wording {
    static let title = "NENE//IGO"
    static let match = "MATCH"
    static let captures = "CAPTURES"
    static let capsShort = "CAPS   "
    static let score = "SCORE"
    static let log = "LOG"
    static let result = "RESULT"
    static let nextGame = "NEXT GAME  "
    static let gameLabel = "GAME      "
    static let blackLabel = "BLACK     "
    static let whiteLabel = "WHITE     "
    static let turnLabel = "TURN      "
    static let komiLabel = "KOMI      "
    static let lastLabel = "LAST "
    static let noTurn = "--"
    static let quitKey = "[q]"
    static let quitName = " QUIT   "
    static let themeKey = "[t]"
    static let themeName = " THEME: "

    static func gameNumber(_ number: Int) -> String {
        padded(number, width: 3)
    }

    static func headerGame(_ number: Int) -> String {
        "GAME " + padded(number, width: 3)
    }

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func colors(_ mode: ColorMode) -> String {
        switch mode {
        case .trueColor:
            return "24BIT"
        case .palette256:
            return "256C"
        }
    }

    static func side(_ stone: Stone) -> String {
        switch stone {
        case .black:
            return "BLACK"
        case .white:
            return "WHITE"
        }
    }

    static func tag(_ stone: Stone) -> String {
        String(side(stone).prefix(1)) + "  "
    }

    static func moveNumber(_ number: Int) -> String {
        " :: MOVE " + padded(number, width: 3)
    }

    /// 終局の結果（例 `>> W+12.5`）。
    static func headline(_ result: GameResult) -> String {
        ">> " + outcome(result)
    }

    /// 勝った側と差（例 `B+3.5`）。
    static func outcome(_ result: GameResult) -> String {
        String(side(result.winner).prefix(1)) + "+" + points(halfPoints: result.marginInHalfPoints)
    }

    /// 数えた石と地。
    static func area(_ score: AreaScore) -> String {
        "AREA  B " + padded(score.black, width: 3) + "  W " + padded(score.white, width: 3)
    }

    /// 半目の単位の数を目の表記にする（15 → `7.5`・6 → `3`）。
    static func points(halfPoints: Int) -> String {
        String(halfPoints / 2) + (halfPoints % 2 == 1 ? ".5" : "")
    }

    static func seconds(_ value: Int) -> String {
        "\(value)s"
    }

    static func tooSmall(need size: ScreenSize) -> String {
        "TERMINAL TOO SMALL (NEED \(size.columns)x\(size.rows))"
    }

    static func padded(_ number: Int, width: Int) -> String {
        let digits = String(number)
        return String(repeating: "0", count: max(width - digits.count, 0)) + digits
    }
}
