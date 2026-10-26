import NeNeIgoCore
import NeNeIgoEngine

/// 1 つの配置（大きな盤か縮小版）の各部品の置き場所と描き方（ADR 0011）。
///
/// 上端に題の帯、左に盤（行の番号は左、列の文字は下）、右に罫線の枠の HUD、盤の下に COMMS の 2 行、下端にキーの帯。
/// 形は NeNe Reversi の `ScreenLayout`（コミット 0ee4526。Reversi は NeNe Gambit の B 案）にならった。
struct ScreenLayout: Sendable, Hashable {
    let board: BoardFrame
    let hudColumn: Int
    let hudWidth: Int
    let hudRows: Int
    let commsRow: Int
    let footerRow: Int
    let isCompact: Bool

    /// 大きな盤（1 交点 3 桁）と MATCH / CAPTURES / SCORE / LOG / RESULT の HUD。102 × 25。
    static let large = ScreenLayout(board: BoardFrame(column: 0, row: 2, pointWidth: 3), hudWidth: 37, isCompact: false)
    /// 縮小版（1 交点 2 桁）と詰めた HUD。80 × 24。
    static let compact = ScreenLayout(
        board: BoardFrame(column: 0, row: 1, pointWidth: 2), hudWidth: 35, isCompact: true)

    private init(board: BoardFrame, hudWidth: Int, isCompact: Bool) {
        let size = BoardSize.nineteen
        self.board = board
        hudColumn = board.column + 3 + board.width(size) + (isCompact ? 2 : 3)
        self.hudWidth = hudWidth
        // HUD は盤と列の文字の行の高さ
        hudRows = size.height + 1
        // 盤の下に列の文字が 1 行、その下に COMMS の 2 行、その下にキーの帯
        commsRow = board.row + size.height + 1
        footerRow = commsRow + 2
        self.isCompact = isCompact
    }

    /// この配置がちょうど入る大きさ。
    var size: ScreenSize {
        ScreenSize(columns: hudColumn + hudWidth + 1, rows: footerRow + 1)
    }

    func draw(_ state: ScreenState, into grid: inout Grid) {
        let glyphs = FrameGlyphs.of(state.options.traits.frame)
        let theme = state.options.theme
        let game = state.series.game
        band(row: 0, theme: theme, into: &grid)
        grid.write(ScreenChrome.header(state, glyphs: glyphs), column: 0, row: 0, background: theme.panel)
        board.draw(game.position, last: Self.lastPoint(game), theme: theme, into: &grid)
        for (offset, line) in hudLines(state, glyphs: glyphs).prefix(hudRows).enumerated() {
            grid.write(line, column: hudColumn, row: board.row + offset, background: theme.ground)
        }
        for (offset, line) in ScreenChrome.comms(state, glyphs: glyphs, compact: isCompact).enumerated() {
            grid.write(line, column: 0, row: commsRow + offset, background: theme.ground)
        }
        band(row: footerRow, theme: theme, into: &grid)
        grid.write(
            ScreenChrome.footer(state, glyphs: glyphs, compact: isCompact), column: 0, row: footerRow,
            background: theme.panel)
    }

    private func band(row: Int, theme: Theme, into grid: inout Grid) {
        grid.write(
            String(repeating: " ", count: grid.size.columns), column: 0, row: row,
            colors: CellColors(foreground: theme.text, background: theme.panel))
    }

    private func hudLines(_ state: ScreenState, glyphs: FrameGlyphs) -> [[Segment]] {
        let sections = HudSections(state: state, panel: Panel(width: hudWidth, glyphs: glyphs))
        let result = sections.result()
        let theme = state.options.theme
        let bottom = sections.panel.footer(frame: result.isEmpty ? theme.frame : theme.accentAlt)
        if isCompact {
            let top = sections.compactMatch()
            let middle = result.isEmpty ? sections.log(rows: hudRows - top.count - 2) : result
            return top + middle + [bottom]
        }
        let top = sections.match() + sections.captures() + sections.score()
        let logRows = hudRows - top.count - result.count - 2
        return top + sections.log(rows: logRows) + result + [bottom]
    }

    /// 直前の手の点。まだ打っていないか、直前の手がパスなら nil。
    private static func lastPoint(_ game: Game) -> Point? {
        guard case .place(let point) = game.moves.last else {
            return nil
        }
        return point
    }
}
