/// キャストの 1 名: 名前と探索の性格（FR-06・FR-14・REQUIREMENTS の Q7・ADR 0010）。
///
/// 名前は `ファイル名.拡張子` 風（兄弟の作法）で、Gambit・Reversi のキャストとは違う 4 名。顔とセリフは Phase 3 の手順 5 で足す。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 探索の設定。
    public let profile: SearchProfile

    private init(name: String, profile: SearchProfile) {
        self.name = name
        self.profile = profile
    }

    /// 4 名（ADR 0010 の表）。
    public static let cast: [Persona] = [sente, tenuki, moyo, seki]

    /// 先手を取りたがる。直前の手に接触して打ち合う。
    static let sente = make(
        name: "SENTE.SYS", profile: profile(playouts: 550, exploration: 0.9, style: .contact, openingMoves: 4))
    /// すぐ手を抜く。読みが浅く、好みなし。序盤が長く散らかる。
    static let tenuki = make(
        name: "TENUKI.LOG", profile: profile(playouts: 650, exploration: 1.0, style: .scatter, openingMoves: 10))
    /// 模様を張りたがる。中央を好む。
    static let moyo = make(
        name: "MOYO.PNG", profile: profile(playouts: 600, exploration: 1.1, style: .centerSeeking, openingMoves: 6))
    /// 動かない。よく読み、知っている手に固執する（探索の項が小さい）。
    static let seki = make(
        name: "SEKI.LCK", profile: profile(playouts: 450, exploration: 0.6, style: .contact, openingMoves: 2))

    /// 名前と設定から作る（Engine の中と、`@testable import` のテストが速い設定で回すため）。
    static func make(name: String, profile: SearchProfile) -> Persona {
        Persona(name: name, profile: profile)
    }

    private static func profile(playouts: Int, exploration: Double, style: PlayoutStyle, openingMoves: Int)
        -> SearchProfile
    {
        guard
            let profile = SearchProfile.make(
                playouts: playouts, exploration: exploration, style: style, openingMoves: openingMoves)
        else {
            preconditionFailure("キャストの設定が範囲外")
        }
        return profile
    }
}
