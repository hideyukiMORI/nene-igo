/// 発言のときの気分。移植元: NeNe Gambit `Sources/NeNeGambitEngine/Mood.swift`（コミット 64b82ec）。
public enum Mood: Sendable, Hashable, CaseIterable {
    /// 得意げ（取った・勝った）。
    case smug
    /// ふつう（始まり・パス・静かな局面）。
    case neutral
    /// 沈んでいる（取られた・負けた）。
    case grim
}
