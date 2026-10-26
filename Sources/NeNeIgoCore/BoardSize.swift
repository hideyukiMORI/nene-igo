/// 盤の大きさ。製品は 19 路だけを使い（REQUIREMENTS の Q4）、テストは小さい盤と長方形の盤を使う。
///
/// 盤は番兵つきの 1 次元配列で持つ（ADR 0005）。行の幅は `width + 1` で、各行の先頭のマスと上下の 1 行が番兵になる。
public struct BoardSize: Sendable, Hashable {
    /// 列の数（横）。
    public let width: Int
    /// 行の数（縦）。
    public let height: Int

    /// 扱える最大の辺。
    public static let maximumSide = 19

    /// 19 路盤。
    public static let nineteen = BoardSize(width: 19, height: 19)

    private init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    /// 1〜19 の辺から盤の大きさを作る。範囲外なら nil。
    public static func make(width: Int, height: Int) -> BoardSize? {
        let range = 1...maximumSide
        return range.contains(width) && range.contains(height) ? BoardSize(width: width, height: height) : nil
    }

    /// 盤の点の数。
    public var pointCount: Int {
        width * height
    }

    /// すべての点（左下から右へ、下の行から上の行へ）。
    public var points: [Point] {
        (0..<height).flatMap { y in (0..<width).compactMap { x in Point.at(x: x, y: y) } }
    }

    /// その点が盤の中にあるか。
    public func contains(_ point: Point) -> Bool {
        point.x < width && point.y < height
    }

    /// 番兵を含む行の幅。
    var stride: Int {
        width + 1
    }

    /// 番兵を含む 1 次元配列の長さ。
    var cellCount: Int {
        (height + 2) * stride
    }

    /// 盤の中の点の、1 次元配列での位置。
    func index(of point: Point) -> Int {
        (point.y + 1) * stride + point.x + 1
    }

    /// 1 次元配列での位置から点を戻す。番兵の位置は渡さない。
    func point(at index: Int) -> Point {
        guard let point = Point.at(x: index % stride - 1, y: index / stride - 1) else {
            preconditionFailure("番兵の位置 \(index) は点ではない")
        }
        return point
    }

    /// 縦横に隣り合う 4 つの位置。
    func neighbors(of index: Int) -> [Int] {
        [index - stride, index - 1, index + 1, index + stride]
    }
}
