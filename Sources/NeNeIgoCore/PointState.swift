/// 盤の点の状態（閉じた選択肢・ARC-010）。
public enum PointState: Sendable, Hashable, CaseIterable {
    case empty
    case black
    case white

    /// その色の石がある状態。
    public static func occupied(by stone: Stone) -> PointState {
        switch stone {
        case .black:
            return .black
        case .white:
            return .white
        }
    }
}
