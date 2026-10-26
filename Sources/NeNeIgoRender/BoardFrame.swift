import NeNeIgoCore

/// 碁盤の置き場所と描き方（FR-07・ADR 0007）。
///
/// 1 つの交点は 3 桁 × 1 行。左の 2 桁が交点（空なら `+` と `-`、星なら `*` と `-`、石なら石の色で塗った 2 桁の空白）、
/// 右の 1 桁が次の交点への線 `-`。右端の交点の右には線を引かない。縦の線は引かない（行のあいだに行が無い）。
/// 直前の手の `[` と `]` は、その交点の左右の 1 桁（左隣の線の桁と、自分の線の桁）に書く。
/// 行の番号は左、列の文字は下（`MoveNotation`）。
struct BoardFrame: Sendable, Hashable {
    /// 行の番号を書く桁。
    let column: Int
    /// 盤の最上行。
    let row: Int

    /// 1 つの交点が占める桁。
    static let pointWidth = 3

    /// 19 路の星（天元と 8 つの星）の列と行（0 始まり）。
    static let starLines = [3, 9, 15]

    /// 交点 `x` の左の桁。
    func left(of x: Int) -> Int {
        column + 4 + x * Self.pointWidth
    }

    /// 盤の地を塗る桁の数（左の `[` の桁から、右端の交点の線の桁まで）。
    func width(_ size: BoardSize) -> Int {
        size.width * Self.pointWidth + 1
    }

    /// 盤の上の行（`y`）の画面の行。上が `y` の大きい側。
    func screenRow(of y: Int, _ size: BoardSize) -> Int {
        row + size.height - 1 - y
    }

    func draw(_ position: Position, last: Point?, theme: Theme, into grid: inout Grid) {
        let size = position.size
        for y in 0..<size.height {
            grid.paint(column: column + 3, row: screenRow(of: y, size), width: width(size), color: theme.board)
        }
        for point in size.points {
            drawPoint(point, position: position, theme: theme, into: &grid)
        }
        if let last {
            let marker = CellColors(foreground: theme.marker, background: theme.board)
            grid.write("[", column: left(of: last.x) - 1, row: screenRow(of: last.y, size), colors: marker)
            grid.write("]", column: left(of: last.x) + 2, row: screenRow(of: last.y, size), colors: marker)
        }
        let labels = CellColors(foreground: theme.dim, background: theme.ground)
        for y in 0..<size.height {
            let number = String(y + 1)
            let text = String(repeating: " ", count: max(2 - number.count, 0)) + number
            grid.write(text, column: column, row: screenRow(of: y, size), colors: labels)
        }
        for x in 0..<size.width {
            grid.write(String(MoveNotation.column(x)), column: left(of: x), row: row + size.height, colors: labels)
        }
    }

    private func drawPoint(_ point: Point, position: Position, theme: Theme, into grid: inout Grid) {
        let size = position.size
        let screen = screenRow(of: point.y, size)
        let edge = point.x == size.width - 1
        let lines = CellColors(foreground: theme.line, background: theme.board)
        if !edge {
            grid.write("-", column: left(of: point.x) + 2, row: screen, colors: lines)
        }
        switch position.state(at: point) {
        case .empty:
            let mark = Self.isStar(point, size) ? "*" : "+"
            grid.write(mark + (edge ? " " : "-"), column: left(of: point.x), row: screen, colors: lines)
        case .black:
            grid.paint(column: left(of: point.x), row: screen, width: 2, color: theme.color(of: .black))
        case .white:
            grid.paint(column: left(of: point.x), row: screen, width: 2, color: theme.color(of: .white))
        }
    }

    /// 19 路の星か。19 路でない盤（テストの小さい盤）には星を描かない。
    static func isStar(_ point: Point, _ size: BoardSize) -> Bool {
        size == .nineteen && starLines.contains(point.x) && starLines.contains(point.y)
    }
}
