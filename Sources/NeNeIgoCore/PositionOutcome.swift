/// 石の並びから局面を作った結果。
public enum PositionOutcome: Sendable, Hashable {
    case made(Position)
    case rejected(PositionRejection)
}
