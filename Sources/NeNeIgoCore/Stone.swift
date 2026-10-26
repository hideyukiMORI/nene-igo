/// 石の色。黒が先手（FR-01）。
public enum Stone: Sendable, Hashable, CaseIterable {
    case black
    case white

    /// 相手の色。
    public var opponent: Stone {
        switch self {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
}
