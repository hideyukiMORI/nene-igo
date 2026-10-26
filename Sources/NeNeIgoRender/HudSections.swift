import NeNeIgoCore
import NeNeIgoEngine

/// HUD のパネルの各段（MATCH・CAPTURES・SCORE・LOG・RESULT）の行を作る（FR-10）。
///
/// 段の形は NeNe Reversi の `HudSections`（コミット 0ee4526。Reversi は NeNe Gambit の形）にならい、石の数の段をアゲハマの段に、
/// 結果を中国ルールの差（`W+12.5`）と石と地の数に替えた。
struct HudSections: Sendable {
    let state: ScreenState
    let panel: Panel

    private var theme: Theme {
        state.options.theme
    }

    private var game: Game {
        state.series.game
    }

    /// MATCH: 局の番号・黒白の性格・手番と手数・コミ。
    func match() -> [[Segment]] {
        let series = state.series
        return [
            panel.header(Wording.match, title: theme.accent, frame: theme.frame, first: true),
            row([Segment(Wording.gameLabel, theme.dim), Segment(Wording.gameNumber(series.gameNumber), theme.text)]),
            row([Segment(Wording.blackLabel, theme.dim), Segment(series.players.black.name, theme.side(.black))]),
            row([Segment(Wording.whiteLabel, theme.dim), Segment(series.players.white.name, theme.side(.white))]),
            row([Segment(Wording.turnLabel, theme.dim)] + turn()),
            row([
                Segment(Wording.komiLabel, theme.dim),
                Segment(Wording.points(halfPoints: game.komi.halfPoints), theme.text),
            ]),
        ]
    }

    /// 手番（終局していれば `--`）と、打った手の数。
    func turn() -> [Segment] {
        let side: Segment
        switch game.status {
        case .ongoing:
            let mover = game.position.toMove
            side = Segment(Wording.side(mover), theme.side(mover))
        case .finished:
            side = Segment(Wording.noTurn, theme.dim)
        }
        return [side, Segment(Wording.moveNumber(game.moves.count), theme.dim)]
    }

    /// CAPTURES: アゲハマの棒（取った石の合計に対する割合）と数。
    func captures() -> [[Segment]] {
        let total = game.capturedByBlack + game.capturedByWhite
        return [
            panel.header(Wording.captures, title: theme.accent, frame: theme.frame, first: false),
            barRow(Stone.black, Fraction(value: game.capturedByBlack, total: total)),
            barRow(Stone.white, Fraction(value: game.capturedByWhite, total: total)),
        ]
    }

    /// SCORE: 黒勝ち・白勝ちの棒（通算の局数に対する割合）。中国ルールとコミ 7.5 なので引き分けは無い。
    func score() -> [[Segment]] {
        let tally = state.series.tally
        let total = tally.finishedGames
        return [
            panel.header(Wording.score, title: theme.accent, frame: theme.frame, first: false),
            barRow(Stone.black, Fraction(value: tally.blackWins, total: total)),
            barRow(Stone.white, Fraction(value: tally.whiteWins, total: total)),
        ]
    }

    private func barRow(_ stone: Stone, _ share: Fraction) -> [Segment] {
        row(
            [Segment(Wording.tag(stone), theme.side(stone))]
                + panel.bar(share, cells: 20, fill: theme.side(stone), frame: theme.frame)
                + [Segment("  " + Wording.padded(share.value, width: 3), theme.text)])
    }

    /// LOG: 直近の手を `count` 行（足りない分は空の行）。
    func log(rows count: Int) -> [[Segment]] {
        let cursor = Segment(panel.glyphs.cursor, theme.accent)
        let lines = MoveLogRow.recent(game, count: count).map { entry -> [Segment] in
            let black = entry.cursor == .black ? [cursor] : [Segment(entry.black, theme.side(.black))]
            let gap = String(repeating: " ", count: max(7 - (entry.cursor == .black ? 1 : entry.black.count), 1))
            let white = entry.cursor == .white ? [cursor] : [Segment(entry.white, theme.side(.white))]
            return row([Segment(entry.number + "  ", theme.dim)] + black + [Segment(gap, theme.dim)] + white)
        }
        let empty = Array(repeating: row([]), count: max(count - lines.count, 0))
        return [panel.header(Wording.log, title: theme.accent, frame: theme.frame, first: false)] + lines + empty
    }

    /// RESULT: 勝敗と差（`W+12.5`）・石と地の数・次の局までの秒読み。終局していなければ空。
    func result() -> [[Segment]] {
        guard case .finished(let outcome) = game.status else {
            return []
        }
        let frame = theme.accentAlt
        var rows = [
            panel.header(Wording.result, title: theme.accentAlt, frame: frame, first: false),
            panel.row([Segment(Wording.headline(outcome), theme.accentAlt)], frame: frame),
            panel.row([Segment(Wording.area(outcome.score), theme.text)], frame: frame),
        ]
        if let countdown = state.countdown {
            let share = Fraction(value: countdown.remaining, total: countdown.total)
            let bar = panel.bar(share, cells: 13, fill: theme.accent, frame: theme.frame)
            let seconds = Segment("  " + Wording.seconds(countdown.remaining), theme.accent)
            rows.append(panel.row([Segment(Wording.nextGame, theme.dim)] + bar + [seconds], frame: frame))
        } else {
            rows.append(panel.row([], frame: frame))
        }
        return rows
    }

    /// 縮小版の MATCH（題に局の番号・黒白の性格・手番・アゲハマ・通算）。
    func compactMatch() -> [[Segment]] {
        let series = state.series
        let tally = series.tally
        let title = Wording.match + " " + Wording.gameNumber(series.gameNumber)
        return [
            panel.header(title, title: theme.accent, frame: theme.frame, first: true),
            row([Segment("B ", theme.dim), Segment(series.players.black.name, theme.side(.black))]),
            row([Segment("W ", theme.dim), Segment(series.players.white.name, theme.side(.white))]),
            row([Segment("TURN ", theme.dim)] + turn()),
            row([
                Segment(Wording.capsShort, theme.dim),
                Segment(
                    Wording.tag(.black) + Wording.padded(game.capturedByBlack, width: 3) + "  ", theme.side(.black)),
                Segment(Wording.tag(.white) + Wording.padded(game.capturedByWhite, width: 3), theme.side(.white)),
            ]),
            row([
                Segment(Wording.score + "  ", theme.dim),
                Segment(Wording.tag(.black) + Wording.padded(tally.blackWins, width: 3) + "  ", theme.side(.black)),
                Segment(Wording.tag(.white) + Wording.padded(tally.whiteWins, width: 3), theme.side(.white)),
            ]),
        ]
    }

    func row(_ content: [Segment]) -> [Segment] {
        panel.row(content, frame: theme.frame)
    }
}
