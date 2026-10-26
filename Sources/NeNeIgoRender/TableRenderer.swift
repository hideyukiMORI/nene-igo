/// 画面の状態と端末の大きさから、1 画面分のセルの格子を作る（ARC-011: 値を作るだけで端末を知らない）。
public enum TableRenderer {
    /// 盤と HUD が入る最小の大きさ（これより小さければ 1 行の文言だけ）。
    public static let minimumSize = ScreenLayout.standard.size

    /// 1 画面分の格子。
    public static func render(_ state: ScreenState, size: ScreenSize) -> Grid {
        let theme = state.theme
        var grid = Grid.filled(
            size, with: Cell(character: " ", foreground: theme.text, background: theme.ground, style: .plain))
        if size.columns >= minimumSize.columns && size.rows >= minimumSize.rows {
            ScreenLayout.standard.draw(state, into: &grid)
        } else {
            let message = Wording.tooSmall(need: minimumSize)
            grid.write(message, column: 0, row: 0, colors: CellColors(foreground: theme.text, background: theme.ground))
        }
        return grid
    }
}
