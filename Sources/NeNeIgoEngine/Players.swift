import NeNeIgoCore

/// 1 局の黒と白のキャスト。
public struct Players: Sendable, Hashable {
    public let black: Persona
    public let white: Persona

    private init(black: Persona, white: Persona) {
        self.black = black
        self.white = white
    }

    /// 顔ぶれから違う 2 名を乱数で選び、乱数で黒白に分ける（局ごとにランダムに組む・FR-14）。
    static func drawn(from roster: [Persona], using generator: inout some RandomNumberGenerator) -> Players {
        let pair = Array(roster.shuffled(using: &generator).prefix(2))
        return Players(black: pair[0], white: pair[1])
    }

    /// 決めた 2 名（計測とテストのため）。
    public static func fixed(black: Persona, white: Persona) -> Players {
        Players(black: black, white: white)
    }

    /// その色を受け持つキャスト。
    public func persona(for stone: Stone) -> Persona {
        switch stone {
        case .black:
            return black
        case .white:
            return white
        }
    }
}
