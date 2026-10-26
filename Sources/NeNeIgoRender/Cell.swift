/// 端末の文字セル 1 つ。1 つの `Character` が 1 桁を占めると前提する（画面の文字は ASCII だけ・ADR 0007）。
///
/// 移植元: NeNe Reversi `Sources/NeNeReversiRender/`（コミット e4a6f52）の同名の型（Cell・CellColors・ColorMode・Countdown・Grid・Rgb・ScreenSize・HudLine）。
///
/// 石のセルは空白で、背景色だけが石の色になる（FR-07）。
public struct Cell: Sendable, Hashable {
    public let character: Character
    public let foreground: Rgb
    public let background: Rgb
}
