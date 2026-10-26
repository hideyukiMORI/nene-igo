import NeNeIgoCore
import NeNeIgoEngine

/// 画面の各部品の置き場所と描き方。上端に題とシード、左に碁盤、右に HUD、下端にキーのヘルプ（ADR 0007）。
///
/// 配置は 1 つだけ（19 路で 99 × 24）。端末の大きさで 2 段に切り替える配置と罫線の枠（FR-16）は手順 5 で入れる。
struct ScreenLayout: Sendable, Hashable {
    let board: BoardFrame
    let hudColumn: Int
    let hudWidth: Int
    let footerRow: Int

    /// 19 路の配置。
    static let standard = ScreenLayout(board: BoardFrame(column: 0, row: 2), boardSize: .nineteen, gap: 3, hudWidth: 34)

    private init(board: BoardFrame, boardSize: BoardSize, gap: Int, hudWidth: Int) {
        self.board = board
        hudColumn = board.left(of: 0) - 1 + board.width(boardSize) + gap
        self.hudWidth = hudWidth
        // 盤の下に列の文字が 1 行、その下を 1 行あけてキーのヘルプ
        footerRow = board.row + boardSize.height + 2
    }

    /// この配置がちょうど入る大きさ。
    var size: ScreenSize {
        ScreenSize(columns: hudColumn + hudWidth + 1, rows: footerRow + 1)
    }

    func draw(_ state: ScreenState, into grid: inout Grid) {
        let theme = state.theme
        let game = state.series.game
        let accent = CellColors(foreground: theme.accent, background: theme.ground)
        let dim = CellColors(foreground: theme.dim, background: theme.ground)
        grid.write(Wording.title, column: board.column, row: 0, colors: accent)
        grid.write(Wording.seed(state.seed), column: hudColumn, row: 0, colors: dim)
        board.draw(game.position, last: Self.lastPoint(game), theme: theme, into: &grid)
        let lines = HudPanel.lines(state, height: footerRow - board.row - 1)
        for (offset, line) in lines.enumerated() {
            let colors = CellColors(foreground: line.heading ? theme.accent : theme.text, background: theme.ground)
            grid.write(String(line.text.prefix(hudWidth)), column: hudColumn, row: board.row + offset, colors: colors)
        }
        grid.write(Wording.help, column: board.column, row: footerRow, colors: dim)
    }

    /// 直前の手の点。まだ打っていないか、直前の手がパスなら nil。
    private static func lastPoint(_ game: Game) -> Point? {
        guard case .place(let point) = game.moves.last else {
            return nil
        }
        return point
    }
}
