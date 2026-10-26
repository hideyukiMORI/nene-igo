/// 盤の交点。手の内部表記の単位（ADR 0005）。
///
/// `x` は左から 0 始まりの列、`y` は下から 0 始まりの行。表示（列 `A`〜`T` で `I` を飛ばす・行 1〜19）への変換は Render だけが持つ。
/// どの盤の中にあるかは盤の大きさが決める（`BoardSize.contains`）。
public struct Point: Sendable, Hashable {
    /// 左から 0 始まりの列。
    public let x: Int
    /// 下から 0 始まりの行。
    public let y: Int

    private init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// 0〜18 の列と行から点を作る。範囲外なら nil。
    public static func at(x: Int, y: Int) -> Point? {
        let range = 0..<BoardSize.maximumSide
        return range.contains(x) && range.contains(y) ? Point(x: x, y: y) : nil
    }
}
