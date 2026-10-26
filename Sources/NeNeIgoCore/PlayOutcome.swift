/// 局面に手を打った結果。
public enum PlayOutcome: Sendable, Hashable {
    /// 打った後の局面と、その手で取った石の数。
    case played(Position, captured: Int)
    case rejected(PlacementRejection)
}
