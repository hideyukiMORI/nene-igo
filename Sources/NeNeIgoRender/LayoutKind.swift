/// 端末の大きさで選ぶ配置（2 段・FR-16）。移植元: NeNe Reversi `Sources/NeNeReversiRender/LayoutKind.swift`（コミット 0ee4526）。
enum LayoutKind: Sendable, Hashable {
    /// 大きな盤（1 交点 3 桁）が入る
    case large
    /// 縮小版（1 交点 2 桁）が入る
    case compact
    /// それより小さい: 1 行の文言だけ
    case tooSmall

    static func fitting(_ size: ScreenSize) -> LayoutKind {
        if fits(ScreenLayout.large.size, in: size) {
            return .large
        }
        if fits(ScreenLayout.compact.size, in: size) {
            return .compact
        }
        return .tooSmall
    }

    private static func fits(_ need: ScreenSize, in size: ScreenSize) -> Bool {
        size.columns >= need.columns && size.rows >= need.rows
    }
}
