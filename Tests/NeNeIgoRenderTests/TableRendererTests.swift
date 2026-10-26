import NeNeIgoCore
import Testing

@testable import NeNeIgoEngine
@testable import NeNeIgoRender

/// 1 画面分の格子（FR-07・FR-10・FR-12・FR-13・FR-15・FR-16・ADR 0007・0009・0011）。
struct TableRendererTests {
    static let boxed = TerminalTraits(frame: .boxDrawing, colors: .trueColor)
    static let layouts: [ScreenLayout] = [.large, .compact]

    /// シード 3 で `steps` 歩進めた列（プレイアウトの少ないキャスト）。
    static func series(steps: Int) -> GameSeries {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first(roster: Quick.roster, using: &generator)
        for _ in 0..<steps {
            series = series.advanced(using: &generator)
        }
        return series
    }

    /// シード 3 の第 1 局を終局まで進めた列。
    static func finished() -> GameSeries {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first(roster: Quick.roster, using: &generator)
        while case .ongoing = series.game.status {
            series = series.advanced(using: &generator)
        }
        return series
    }

    static func render(
        _ series: GameSeries, size: ScreenSize,
        options: DisplayOptions = DisplayOptions(theme: .standard, traits: boxed),
        countdown: Countdown? = nil
    ) -> Grid {
        TableRenderer.render(ScreenState(series: series, options: options, seed: 3, countdown: countdown), size: size)
    }

    static func cells(_ grid: Grid) -> [Cell] {
        (0..<grid.size.rows).flatMap { row in (0..<grid.size.columns).map { grid[$0, row] } }
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    /// 盤の上の行（y）の、交点の桁から右端までの文字列。
    static func boardRow(_ grid: Grid, _ frame: BoardFrame, y: Int) -> String {
        let row = frame.screenRow(of: y, .nineteen)
        return String((frame.left(of: 0)..<frame.left(of: 18) + frame.pointWidth).map { grid[$0, row].character })
    }

    /// 大きな盤は 102 × 25、縮小版は 80 × 24（Windows Terminal の既定の 120 × 30 と、昔ながらの 80 × 24 に入る）。
    @Test func layoutsFitTheCommonTerminalSizes() {
        #expect(TableRenderer.largeSize == ScreenSize(columns: 102, rows: 25))
        #expect(TableRenderer.minimumSize == ScreenSize(columns: 80, rows: 24))
    }

    /// 石は石の色で塗った 2 桁の空白で、数は石の数 × 2。下線は碁盤の地の色（縮小版の直前の手だけ印の色）。
    @Test(arguments: layouts)
    func stoneCellsAreBlankUnderlinedBlocks(_ layout: ScreenLayout) {
        let series = Self.series(steps: 60)
        let grid = Self.render(series, size: layout.size)
        let theme = Theme.standard
        for stone in Stone.allCases {
            let painted = Self.cells(grid).filter { $0.background == theme.color(of: stone) && $0.style == .underlined }
            #expect(painted.allSatisfy { $0.character == " " })
            #expect(painted.count == series.game.position.count(of: stone) * 2)
        }
        let marked = Self.cells(grid).filter { $0.style == .underlined && $0.foreground == theme.marker }
        let lastIsStone = series.game.moves.last.map { $0 != .pass } ?? false
        #expect(marked.count == (layout.isCompact && lastIsStone ? 2 : 0))
    }

    /// 大きな盤では横に並んだ石のあいだに線の桁が 1 つ残る。
    @Test func horizontallyAdjacentStonesKeepALineBetweenThemOnTheLargeBoard() {
        let series = Self.series(steps: 120)
        let grid = Self.render(series, size: TableRenderer.largeSize)
        let frame = ScreenLayout.large.board
        let position = series.game.position
        for point in position.size.points where point.x < 18 && position.state(at: point) != .empty {
            let gap = grid[frame.left(of: point.x) + 2, frame.screenRow(of: point.y, .nineteen)]
            #expect(gap.background == Theme.standard.board)
        }
    }

    @Test func emptyBoardShowsLinesStarsAndCoordinates() {
        let grid = Self.render(Self.series(steps: 0), size: TableRenderer.largeSize)
        let frame = ScreenLayout.large.board
        #expect(Self.boardRow(grid, frame, y: 18) == String(repeating: "+--", count: 18) + "+  ")
        #expect(
            Self.boardRow(grid, frame, y: 15) == "+--+--+--*--+--+--+--+--+--*--+--+--+--+--+--*--+--+--+  ")
        #expect(Self.cells(grid).filter { $0.character == "*" }.count == 9)
        let text = Self.text(grid)
        #expect(text.contains("A  B  C  D  E  F  G  H  J  K  L  M  N  O  P  Q  R  S  T"))
        #expect(text.contains("19  +--"))
        #expect(text.contains(" 1  +--"))
        let compact = Self.render(Self.series(steps: 0), size: TableRenderer.minimumSize)
        #expect(Self.boardRow(compact, ScreenLayout.compact.board, y: 18) == String(repeating: "+-", count: 18) + "+ ")
    }

    /// ASCII の枠では画面の文字はすべて ASCII。罫線の枠でも、ASCII 以外は枠の字形だけ（石に Emoji の文字を使わない）。
    @Test func charactersAreASCIIOrFrameGlyphs() {
        let series = Self.series(steps: 30)
        let ascii = Self.render(
            series, size: TableRenderer.largeSize,
            options: DisplayOptions(theme: .standard, traits: TerminalTraits(frame: .ascii, colors: .trueColor)))
        #expect(Self.cells(ascii).allSatisfy { $0.character.isASCII })
        let glyphs = FrameGlyphs.of(.boxDrawing)
        let allowed = Set(
            [
                glyphs.topLeft, glyphs.topRight, glyphs.teeLeft, glyphs.teeRight, glyphs.bottomLeft, glyphs.bottomRight,
                glyphs.horizontal, glyphs.vertical, glyphs.barFull, glyphs.barEmpty, glyphs.barOpen, glyphs.barClose,
                glyphs.marker, glyphs.cursor,
            ].flatMap { Array($0) })
        let boxed = Self.render(series, size: TableRenderer.largeSize)
        #expect(Self.cells(boxed).allSatisfy { $0.character.isASCII || allowed.contains($0.character) })
        #expect(Self.cells(boxed).contains { $0.character == Character(glyphs.topLeft) })
    }

    @Test func lastMoveIsBracketedOnTheLargeBoard() throws {
        var steps = 9
        var series = Self.series(steps: steps)
        while series.game.moves.last == .pass {
            steps += 1
            series = Self.series(steps: steps)
        }
        guard case .place(let point) = try #require(series.game.moves.last) else {
            return
        }
        let grid = Self.render(series, size: TableRenderer.largeSize)
        let frame = ScreenLayout.large.board
        let row = frame.screenRow(of: point.y, .nineteen)
        #expect(grid[frame.left(of: point.x) - 1, row].character == "[")
        #expect(grid[frame.left(of: point.x) + 2, row].character == "]")
    }

    @Test func hudShowsTheMatchTheCapturesAndTheKeys() {
        let series = Self.series(steps: 1)
        let text = Self.text(Self.render(series, size: TableRenderer.largeSize))
        #expect(text.contains("NENE//IGO"))
        #expect(text.contains("GAME 001"))
        #expect(text.contains("SEED 0x0000000000000003"))
        #expect(text.contains("24BIT"))
        #expect(text.contains("BLACK     \(series.players.black.name)"))
        #expect(text.contains("WHITE     \(series.players.white.name)"))
        #expect(text.contains("TURN      WHITE :: MOVE 001"))
        #expect(text.contains("KOMI      7.5"))
        #expect(text.contains("[ CAPTURES ]"))
        #expect(text.contains("[ SCORE ]"))
        #expect(text.contains("[ LOG ]"))
        #expect(text.contains("[q] QUIT"))
        #expect(text.contains("[t] THEME: NEON"))
        #expect(text.contains("LAST \(MoveNotation.text(of: series.game.moves[0]))"))
    }

    /// COMMS: 局の始まりに白、黒の順で 1 言ずつ。名前と顔とセリフ。
    @Test func commsShowTheOpeningRemarks() {
        let series = Self.series(steps: 0)
        let text = Self.text(Self.render(series, size: TableRenderer.largeSize))
        #expect(series.banter.lines.count == 2)
        for remark in series.banter.lines {
            #expect(text.contains(remark.text))
            #expect(text.contains(remark.face))
        }
    }

    @Test(arguments: layouts)
    func finishedGameShowsTheResultAndTheCountdown(_ layout: ScreenLayout) {
        let series = Self.finished()
        guard case .finished(let result) = series.game.status else {
            Issue.record("終局していない")
            return
        }
        let grid = Self.render(series, size: layout.size, countdown: Countdown(remaining: 2, total: 3))
        let text = Self.text(grid)
        #expect(text.contains("[ RESULT ]"))
        #expect(text.contains(">> " + Wording.outcome(result)))
        #expect(text.contains("NEXT GAME"))
        #expect(text.contains("2s"))
        #expect(text.contains("TURN") && text.contains("--"))
    }

    @Test func resultIsWrittenWithTheWinnerAndHalfPoints() throws {
        guard case .decoded(let position) = PositionCodec.decode("...../...../...../XXXXX/.OOO. X") else {
            Issue.record("読めない")
            return
        }
        let result = GameResult.deciding(AreaScore.counting(position), komi: .standard)
        #expect(Wording.outcome(result) == "B+9.5")
        #expect(Wording.points(halfPoints: 15) == "7.5")
    }

    @Test func tooSmallScreenShowsOneLineWithTheNeededSize() {
        let small = ScreenSize(columns: 79, rows: 24)
        let grid = Self.render(Self.series(steps: 3), size: small)
        #expect(Self.text(grid).hasPrefix("TERMINAL TOO SMALL (NEED 80x24)"))
        #expect(Self.cells(grid).allSatisfy { $0.background == Theme.standard.ground })
        #expect(Self.render(Self.series(steps: 3), size: ScreenSize(columns: 0, rows: 0)).size.columns == 0)
    }

    /// 12 テーマ × 2 つの配置 × 対局中と終局後で、英字・数字と盤の記号（`+ - * [ ]`）は前景と背景が 4.5:1 以上（WCAG）。
    /// 石は碁盤の地に対して 3:1 以上、黒石は白石より暗い。枠の罫線と飾りの記号は控えめな色で描く設計なので対象にしない。
    @Test(arguments: Theme.catalog)
    func everyThemeHasEnoughContrast(_ theme: Theme) {
        let options = DisplayOptions(theme: theme, traits: Self.boxed)
        let marks = Set("+-*[]")
        for layout in Self.layouts {
            for series in [Self.series(steps: 60), Self.finished()] {
                let grid = Self.render(
                    series, size: layout.size, options: options, countdown: Countdown(remaining: 1, total: 3))
                for cell in Self.cells(grid)
                where cell.character.isLetter || cell.character.isNumber
                    || (marks.contains(cell.character) && cell.background == theme.board)
                {
                    #expect(Contrast.ratio(cell.foreground, cell.background) >= 4.5, "\(theme.name) \(cell)")
                }
            }
        }
        for stone in Stone.allCases {
            #expect(Contrast.ratio(theme.color(of: stone), theme.board) >= 3, "\(theme.name) \(stone)")
        }
        #expect(Contrast.luminance(theme.blackStone) < Contrast.luminance(theme.whiteStone))
        #expect(theme.blackStone != theme.ground && theme.whiteStone != theme.ground)
    }

    @Test func themesCycleAndCanBeNamed() {
        #expect(Theme.catalog.count == 12)
        #expect(Set(Theme.catalog.map(\.name)).count == 12)
        #expect(Theme.named("paper")?.name == "PAPER")
        #expect(Theme.named("nope") == nil)
        var theme = Theme.standard
        for _ in 0..<12 {
            theme = theme.next
        }
        #expect(theme == Theme.standard)
        #expect(Theme.standard.next.name == "PHOSPHOR")
    }

    @Test func notationSkipsTheLetterI() throws {
        #expect(MoveNotation.name(of: try #require(Point.at(x: 7, y: 0))) == "H1")
        #expect(MoveNotation.name(of: try #require(Point.at(x: 8, y: 0))) == "J1")
        #expect(MoveNotation.name(of: try #require(Point.at(x: 15, y: 15))) == "Q16")
        #expect(MoveNotation.text(of: .pass) == "PASS")
    }
}
