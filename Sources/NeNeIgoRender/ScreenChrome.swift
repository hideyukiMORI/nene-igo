import NeNeIgoCore
import NeNeIgoEngine

/// 上端の題・盤の下の COMMS・下端のキーのヘルプ（FR-15: 常に出す）と直前の手。
///
/// 形は NeNe Reversi の `ScreenChrome`（コミット 0ee4526）と NeNe Gambit の COMMS（`Sources/NeNeGambitRender/ScreenChrome.swift`・コミット 64b82ec）にならった。
enum ScreenChrome {
    /// ` ▌NENE//IGO  │  GAME 012  │  SEED 0x…  │  24BIT`
    static func header(_ state: ScreenState, glyphs: FrameGlyphs) -> [Segment] {
        let theme = state.options.theme
        let divider = Segment("  " + glyphs.vertical + "  ", theme.frame)
        return [
            Segment(" " + glyphs.marker + Wording.title, theme.accent), divider,
            Segment(Wording.headerGame(state.series.gameNumber), theme.text), divider,
            Segment(Wording.seed(state.seed), theme.text), divider,
            Segment(Wording.colors(state.options.traits.colors), theme.dim),
        ]
    }

    /// `[q] QUIT   [t] THEME: NEON   │   LAST Q16`
    static func footer(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [Segment] {
        let theme = state.options.theme
        var segments = [
            Segment(" " + Wording.quitKey, theme.accent), Segment(Wording.quitName, theme.dim),
            Segment(Wording.themeKey, theme.accent), Segment(compact ? " " : Wording.themeName, theme.dim),
            Segment(theme.name, theme.text),
        ]
        let moves = state.series.game.moves
        if let move = moves.last {
            // パスも手なので、手は黒から交互
            let mover: Stone = moves.count % 2 == 1 ? .black : .white
            segments += [
                Segment("   " + glyphs.vertical + "   ", theme.frame), Segment(Wording.lastLabel, theme.dim),
                Segment(MoveNotation.text(of: move), theme.side(mover)),
            ]
        }
        return segments
    }

    /// COMMS の 2 行（古い方は控えめな色、新しい方は話し手の側の色）。
    static func comms(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [[Segment]] {
        let theme = state.options.theme
        let lines = state.series.banter.lines
        return lines.enumerated().map { index, remark in
            let newest = index == lines.count - 1
            let tag = remark.side == .white ? "W" : "B"
            let name = compact ? remark.persona.name + " " : pad(remark.persona.name, to: 11)
            let lead = compact ? glyphs.marker + tag + " " : " " + glyphs.marker + " " + tag + "  "
            let face = remark.face + (compact ? " " : "  ")
            guard newest else {
                return [Segment(lead + name + face + remark.text, theme.dim)]
            }
            return [
                Segment(lead + name, theme.side(remark.side)), Segment(face, theme.accentAlt),
                Segment(remark.text, theme.text),
            ]
        }
    }

    /// 右を空白で埋めて `width` 桁にする（長ければそのまま）。
    private static func pad(_ text: String, to width: Int) -> String {
        text + String(repeating: " ", count: max(width - text.count, 0))
    }
}
