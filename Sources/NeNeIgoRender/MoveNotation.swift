import NeNeIgoCore

/// 手の表示用の表記。点の名前への変換を持つのは Render のここだけ（PROJECT_LAYOUT 第 3 節）。
///
/// 囲碁の慣習どおり、列は左から `A`〜`T` で `I` を飛ばし、行は下から 1〜19（例: 右上の星は `Q16`）。
public enum MoveNotation {
    private static let columnLetters: [Character] = Array("ABCDEFGHJKLMNOPQRST")

    /// 列の文字。
    public static func column(_ x: Int) -> Character {
        columnLetters[x]
    }

    /// 点の名前。
    public static func name(of point: Point) -> String {
        "\(column(point.x))\(point.y + 1)"
    }

    /// 手の表記。打つ手は点の名前、パスは `PASS`。
    public static func text(of move: Move) -> String {
        switch move {
        case .place(let point):
            return name(of: point)
        case .pass:
            return "PASS"
        }
    }
}
