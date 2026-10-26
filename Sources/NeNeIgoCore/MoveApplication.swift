/// 1 局に手を打った結果（`Game.apply` の返り値）。
public enum MoveApplication: Sendable, Hashable {
    case applied
    case rejected(MoveRejection)
}
