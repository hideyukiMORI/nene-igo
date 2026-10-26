/// キャストの 1 名: 名前・探索の性格・顔・セリフ（FR-06・FR-14・REQUIREMENTS の Q7・ADR 0010・0011）。
///
/// 名前は `ファイル名.拡張子` 風（兄弟の作法）で、Gambit・Reversi のキャストとは違う 4 名。セリフは 1 人 50 本（英語）。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 探索の設定。
    public let profile: SearchProfile
    private let faces: Faces
    private let script: [ScriptLine]

    // 格納の faces と script が private なので、合成される memberwise init も private になる（外から作る経路は無い）。

    /// 4 名（ADR 0010 の表）。
    public static let cast: [Persona] = [sente, tenuki, moyo, seki]

    /// 先手を取りたがる常駐デーモン。直前の手に接触して打ち合う。
    static let sente = Persona(
        name: "SENTE.SYS",
        profile: profile(playouts: 550, exploration: 0.9, style: .contact, openingMoves: 4),
        faces: Faces(smug: ">:]", neutral: "o_o", grim: ">:["), script: senteScript)
    /// すぐ手を抜く記録係。好みなく散らかす。序盤が長く荒れる。
    static let tenuki = Persona(
        name: "TENUKI.LOG",
        profile: profile(playouts: 650, exploration: 1.0, style: .scatter, openingMoves: 10),
        faces: Faces(smug: "~_~", neutral: "-.-", grim: "z_z"), script: tenukiScript)
    /// 模様を張りたがる自称アーティスト。中央を好む。
    static let moyo = Persona(
        name: "MOYO.PNG",
        profile: profile(playouts: 600, exploration: 1.1, style: .centerSeeking, openingMoves: 6),
        faces: Faces(smug: "*_*", neutral: "^.^", grim: "T_T"), script: moyoScript)
    /// 動かないロックファイル。よく読み、知っている手に固執する（探索の項が小さい）。
    static let seki = Persona(
        name: "SEKI.LCK",
        profile: profile(playouts: 450, exploration: 0.6, style: .contact, openingMoves: 2),
        faces: Faces(smug: "[=]", neutral: "[-]", grim: "[x]"), script: sekiScript)

    /// 気分ごとの顔（ASCII 3 文字）。
    public func face(_ mood: Mood) -> String {
        faces.face(mood)
    }

    /// その出来事のセリフ。
    public func lines(for cue: Cue) -> [String] {
        script.filter { $0.cue == cue }.map(\.text)
    }

    /// 名前と設定を替え、顔とセリフは `voice` から借りる（`@testable import` のテストが速い設定で回すため）。
    static func make(name: String, profile: SearchProfile, voice: Persona) -> Persona {
        Persona(name: name, profile: profile, faces: voice.faces, script: voice.script)
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
