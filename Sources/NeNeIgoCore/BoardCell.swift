/// 番兵つきの 1 次元配列の 1 マス（ADR 0005）。盤の外の番兵を含むので Core の外へは出さない。
enum BoardCell: UInt8, Sendable, Hashable {
    case empty
    case black
    case white
    case offBoard

    /// その色の石のマス。
    static func of(_ stone: Stone) -> BoardCell {
        switch stone {
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    /// このマスの石の色。石が無ければ nil。
    var stone: Stone? {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        case .empty, .offBoard:
            return nil
        }
    }

    /// 外へ見せる点の状態。番兵は盤の点ではないので、呼び出し側は盤の中の点だけを渡す。
    var pointState: PointState {
        switch self {
        case .empty:
            return .empty
        case .black:
            return .black
        case .white:
            return .white
        case .offBoard:
            preconditionFailure("番兵は盤の点ではない")
        }
    }
}
