/// 1 局に手を打った結果。
public enum MoveOutcome: Sendable, Hashable {
    case played(Game)
    case rejected(MoveRejection)
}
