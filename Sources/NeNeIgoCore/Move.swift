/// 1 回の着手。パスも手の 1 つとして表す（内部表記は 1 つ・ADR 0005）。
public enum Move: Sendable, Hashable {
    case place(Point)
    case pass
}
