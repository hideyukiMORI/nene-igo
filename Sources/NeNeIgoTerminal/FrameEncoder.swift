import NeNeIgoRender

/// 格子を ANSI のバイト列にする。前の格子と違うセルだけを書く（1 フレーム 1 回の `write` 用）。
///
/// 移植元: NeNe Reversi `Sources/NeNeReversiTerminal/FrameEncoder.swift`（コミット e4a6f52。Reversi は NeNe Gambit の 64b82ec から移植した）。駒記号の幅の扱いは落とした
/// （石は色を塗った空白で、画面の文字は ASCII だけ・ADR 0007）。
public enum FrameEncoder {
    /// `previous` が無いか大きさが違えば、画面を消して全部を書く。
    public static func encode(_ grid: Grid, previous: Grid?, colors: ColorMode) -> [UInt8] {
        var out: [UInt8] = []
        let full = previous?.size != grid.size
        if full {
            out += Array("\u{1B}[0m\u{1B}[2J".utf8)
        }
        var cursor: Int?  // 次に書く位置（row * columns + column）。不明なら nil
        var styled: Cell?  // いま端末に効いている色を持つセル
        for row in 0..<grid.size.rows {
            for column in 0..<grid.size.columns {
                let cell = grid[column, row]
                if !full, previous?[column, row] == cell {
                    continue
                }
                let position = row * grid.size.columns + column
                if cursor != position {
                    out += Array("\u{1B}[\(row + 1);\(column + 1)H".utf8)
                }
                if styled?.foreground != cell.foreground || styled?.background != cell.background
                    || styled?.style != cell.style
                {
                    out += sgr(cell, colors)
                    styled = cell
                }
                out += Array(String(cell.character).utf8)
                cursor = column + 1 >= grid.size.columns ? nil : position + 1
            }
        }
        if !out.isEmpty {
            out += Array("\u{1B}[0m".utf8)
        }
        return out
    }

    /// 色と下線の指定。下線は毎回 4（引く）か 24（引かない）を明示する（前のセルの指定を引き継がない）。
    private static func sgr(_ cell: Cell, _ colors: ColorMode) -> [UInt8] {
        let (foreground, background) = (cell.foreground, cell.background)
        let line = underline(cell.style)
        switch colors {
        case .trueColor:
            let fg = "38;2;\(foreground.red);\(foreground.green);\(foreground.blue)"
            let bg = "48;2;\(background.red);\(background.green);\(background.blue)"
            return Array("\u{1B}[\(line);\(fg);\(bg)m".utf8)
        case .palette256:
            let fg = "38;5;\(Palette256.nearest(foreground))"
            return Array("\u{1B}[\(line);\(fg);48;5;\(Palette256.nearest(background))m".utf8)
        }
    }

    private static func underline(_ style: CellStyle) -> String {
        switch style {
        case .plain:
            return "24"
        case .underlined:
            return "4"
        }
    }
}
