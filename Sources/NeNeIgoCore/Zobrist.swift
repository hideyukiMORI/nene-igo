/// Zobrist ハッシュの鍵（ADR 0005）。番兵つきの 1 次元配列の位置と色ごとに 64 ビットの値を 1 つ持つ。
///
/// 鍵は固定の種からの SplitMix64 で作る定数で、乱数源ではない（同じ版なら同じ値）。桁あふれは `&+` / `&*` で 2^64 の余りにする（ADR 0001 の X-g・X-h）。
enum Zobrist {
    /// 19 路の番兵つきの配列の長さ。どの盤の位置もこれより小さい。
    static let maximumCellCount = (BoardSize.maximumSide + 2) * (BoardSize.maximumSide + 1)

    /// 位置 `index` の黒の鍵は `keys[index * 2]`、白は `keys[index * 2 + 1]`。
    static let keys: [UInt64] = {
        var state: UInt64 = 0x4E65_4E65_4967_6F21
        return (0..<(maximumCellCount * 2)).map { _ in
            state = state &+ 0x9E37_79B9_7F4A_7C15
            var mixed = state
            mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
            mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
            return mixed ^ (mixed >> 31)
        }
    }()

    /// 位置 `index` にある `stone` の鍵。
    static func key(at index: Int, for stone: Stone) -> UInt64 {
        switch stone {
        case .black:
            return keys[index * 2]
        case .white:
            return keys[index * 2 + 1]
        }
    }

    /// 盤全体から計算し直したハッシュ（差分更新と一致しなければならない）。
    static func hash(of cells: [BoardCell]) -> UInt64 {
        var value: UInt64 = 0
        for (index, cell) in cells.enumerated() {
            switch cell {
            case .black:
                value ^= key(at: index, for: .black)
            case .white:
                value ^= key(at: index, for: .white)
            case .empty, .offBoard:
                continue
            }
        }
        return value
    }
}
