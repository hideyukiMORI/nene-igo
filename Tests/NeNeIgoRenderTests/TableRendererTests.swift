import NeNeIgoCore
import Testing

@testable import NeNeIgoEngine
@testable import NeNeIgoRender

/// 1 画面分の格子（FR-07・FR-10・FR-15・ADR 0007）。
struct TableRendererTests {
    static let theme = Theme.standard
    static let size = TableRenderer.minimumSize

    /// シード 3 で `steps` 歩進めた列の画面。
    static func render(steps: Int, size: ScreenSize = size, countdown: Countdown? = nil) -> (GameSeries, Grid) {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first(roster: Quick.roster, using: &generator)
        for _ in 0..<steps {
            series = series.advanced(using: &generator)
        }
        let state = ScreenState(series: series, theme: theme, seed: 3, countdown: countdown)
        return (series, TableRenderer.render(state, size: size))
    }

    static func cells(_ grid: Grid) -> [Cell] {
        (0..<grid.size.rows).flatMap { row in (0..<grid.size.columns).map { grid[$0, row] } }
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    /// 盤の上の行（y）の、交点の桁から 3 桁ずつの文字列。
    static func boardRow(_ grid: Grid, y: Int) -> String {
        let frame = ScreenLayout.standard.board
        let row = frame.screenRow(of: y, .nineteen)
        return String((frame.left(of: 0)..<frame.left(of: 18) + 3).map { grid[$0, row].character })
    }

    /// 19 路で 99 × 24 に収まる（Windows Terminal の既定の 120 × 30 に入る）。
    @Test func standardLayoutFitsTheDefaultWindowsTerminal() {
        #expect(Self.size == ScreenSize(columns: 99, rows: 24))
    }

    /// 石は石の色で塗った 2 桁の空白で、数は石の数 × 2。石のセルに文字を書かない（FR-07）。
    @Test func stoneCellsAreBlankTwoColumnBlocks() {
        let (series, grid) = Self.render(steps: 60)
        for stone in Stone.allCases {
            let painted = Self.cells(grid).filter { $0.background == Self.theme.color(of: stone) }
            #expect(painted.allSatisfy { $0.character == " " })
            #expect(painted.count == series.game.position.count(of: stone) * 2)
        }
    }

    /// 石のセルだけが下線つきで、下線は碁盤の地の色（縦に並んだ石を 1 つずつ離す・ADR 0009）。
    @Test func onlyStoneCellsAreUnderlinedInTheBoardColor() {
        let (series, grid) = Self.render(steps: 60)
        let underlined = Self.cells(grid).filter { $0.style == .underlined }
        let stones = series.game.position.count(of: .black) + series.game.position.count(of: .white)
        #expect(underlined.count == stones * 2)
        #expect(underlined.allSatisfy { $0.foreground == Self.theme.board && $0.character == " " })
        #expect(
            underlined.allSatisfy {
                $0.background == Self.theme.color(of: .black) || $0.background == Self.theme.color(of: .white)
            })
    }

    /// 横に並んだ石のあいだには線の桁が 1 つ残る（石どうしが横につながって見えない）。
    @Test func horizontallyAdjacentStonesKeepALineBetweenThem() {
        let (series, grid) = Self.render(steps: 120)
        let frame = ScreenLayout.standard.board
        let position = series.game.position
        for point in position.size.points where point.x < 18 && position.state(at: point) != .empty {
            let row = frame.screenRow(of: point.y, .nineteen)
            let gap = grid[frame.left(of: point.x) + 2, row]
            #expect(gap.background == Self.theme.board)
        }
    }

    @Test func emptyBoardShowsLinesStarsAndCoordinates() {
        let (_, grid) = Self.render(steps: 0)
        #expect(Self.boardRow(grid, y: 18) == "+--" + String(repeating: "+--", count: 17) + "+  ")
        #expect(Self.boardRow(grid, y: 15) == "+--+--+--*--+--+--+--+--+--*--+--+--+--+--+--*--+--+--+  ")
        #expect(Self.boardRow(grid, y: 9).filter { $0 == "*" }.count == 3)
        #expect(Self.cells(grid).filter { $0.character == "*" }.count == 9)
        let text = Self.text(grid)
        #expect(text.contains("A  B  C  D  E  F  G  H  J  K  L  M  N  O  P  Q  R  S  T"))
        #expect(!text.contains("I  J"))
        #expect(text.contains("19  +--"))
        #expect(text.contains(" 1  +--"))
    }

    /// 画面の文字はすべて ASCII（1 文字 1 桁の前提・罫線と Emoji の文字を使わない）。
    @Test func everyCharacterIsASCII() {
        let (_, grid) = Self.render(steps: 80)
        #expect(Self.cells(grid).allSatisfy { $0.character.isASCII })
    }

    @Test func lastMoveIsBracketedOnBothSides() throws {
        let (series, grid) = Self.render(steps: 9)
        guard case .place(let point) = try #require(series.game.moves.last) else {
            Issue.record("直前の手がパス")
            return
        }
        let frame = ScreenLayout.standard.board
        let row = frame.screenRow(of: point.y, .nineteen)
        #expect(grid[frame.left(of: point.x) - 1, row].character == "[")
        #expect(grid[frame.left(of: point.x) + 2, row].character == "]")
        #expect(Self.cells(grid).filter { $0.character == "[" }.count == 1)
        #expect(Self.cells(grid).filter { $0.character == "]" }.count == 1)
    }

    @Test func hudShowsTheGameTheCastTheTurnCapturesAndKomi() {
        let (series, grid) = Self.render(steps: 1)
        let text = Self.text(grid)
        #expect(text.contains("NENE//IGO"))
        #expect(text.contains("GAME   001"))
        #expect(text.contains("BLACK  \(series.players.black.name)"))
        #expect(text.contains("WHITE  \(series.players.white.name)"))
        #expect(text.contains("TURN   WHITE"))
        #expect(text.contains("MOVES  001"))
        #expect(text.contains("CAPS   B 000  W 000"))
        #expect(text.contains("KOMI   7.5"))
        #expect(text.contains("Q QUIT"))
        #expect(text.contains("SEED 0x0000000000000003"))
    }

    @Test func finishedGameShowsTheResultAndTheCountdown() throws {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first(roster: Quick.roster, using: &generator)
        while case .ongoing = series.game.status {
            series = series.advanced(using: &generator)
        }
        guard case .finished(let result) = series.game.status else {
            Issue.record("終局していない")
            return
        }
        let state = ScreenState(
            series: series, theme: Self.theme, seed: 3, countdown: Countdown(remaining: 2, total: 3))
        let text = Self.text(TableRenderer.render(state, size: Self.size))
        #expect(text.contains("RESULT"))
        #expect(text.contains(Wording.outcome(result)))
        #expect(text.contains("NEXT GAME IN 2"))
        #expect(text.contains("TURN   OVER"))
    }

    @Test func resultIsWrittenWithTheWinnerAndHalfPoints() throws {
        let position = try #require(
            { () -> Position? in
                if case .decoded(let decoded) = PositionCodec.decode("...../...../...../XXXXX/.OOO. X") {
                    return decoded
                }
                return nil
            }())
        let result = GameResult.deciding(AreaScore.counting(position), komi: .standard)
        #expect(Wording.outcome(result) == "B+9.5")
        #expect(Wording.komi(.standard) == "KOMI   7.5")
    }

    @Test func tooSmallScreenShowsOneLineWithTheNeededSize() {
        let small = ScreenSize(columns: Self.size.columns - 1, rows: Self.size.rows)
        let (_, grid) = Self.render(steps: 3, size: small)
        #expect(Self.text(grid).hasPrefix("TERMINAL TOO SMALL: NEED 99x24"))
        #expect(Self.cells(grid).allSatisfy { $0.background == Self.theme.ground })
    }

    @Test func emptyScreenDoesNotCrash() {
        let (_, grid) = Self.render(steps: 3, size: ScreenSize(columns: 0, rows: 0))
        #expect(grid.size == ScreenSize(columns: 0, rows: 0))
    }

    /// 文字のあるセルは前景と背景が 4.5:1 以上（WCAG）。石は碁盤の地に対して 3:1 以上（文字でない図形の基準）。
    @Test func textAndStonesHaveEnoughContrast() {
        let (_, grid) = Self.render(steps: 60)
        for cell in Self.cells(grid) where cell.character != " " {
            #expect(Contrast.ratio(cell.foreground, cell.background) >= 4.5, "\(cell)")
        }
        for stone in Stone.allCases {
            #expect(Contrast.ratio(Self.theme.color(of: stone), Self.theme.board) >= 3)
        }
        #expect(Contrast.ratio(Self.theme.marker, Self.theme.board) >= 4.5)
    }

    @Test func notationSkipsTheLetterI() throws {
        #expect(MoveNotation.name(of: try #require(Point.at(x: 7, y: 0))) == "H1")
        #expect(MoveNotation.name(of: try #require(Point.at(x: 8, y: 0))) == "J1")
        #expect(MoveNotation.name(of: try #require(Point.at(x: 15, y: 15))) == "Q16")
        #expect(MoveNotation.name(of: try #require(Point.at(x: 18, y: 18))) == "T19")
        #expect(MoveNotation.text(of: .pass) == "PASS")
    }
}
