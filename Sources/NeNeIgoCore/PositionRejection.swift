/// 石の並びから局面を作れない理由。
public enum PositionRejection: Sendable, Hashable {
    /// 点の数が盤の大きさと合わない。
    case wrongPointCount
    /// 呼吸点の無い連がある（実際の対局で現れない並び）。
    case chainWithoutLiberty
}
