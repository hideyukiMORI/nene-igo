import NeNeIgoCore
import Testing

@testable import NeNeIgoEngine

/// キャストの顔とセリフ（FR-14・ADR 0011）。
struct BanterTests {
    /// 1 人 50 本・どの出来事にも 1 本以上・重複なし・ASCII だけ（画面の 1 文字 1 桁の前提）・COMMS の 1 行に収まる長さ。
    @Test(arguments: Persona.cast)
    func everyPersonaHasFiftyDistinctASCIILines(_ persona: Persona) {
        let all = Cue.allCases.flatMap { persona.lines(for: $0) }
        #expect(all.count == 50)
        #expect(Set(all).count == 50)
        for cue in Cue.allCases {
            #expect(!persona.lines(for: cue).isEmpty, "\(persona.name) \(cue)")
        }
        #expect(all.allSatisfy { line in line.allSatisfy(\.isASCII) && line.count <= 62 })
        for mood in Mood.allCases {
            let face = persona.face(mood)
            #expect(face.count == 3 && face.allSatisfy(\.isASCII))
        }
    }

    @Test func castFacesAndNamesDiffer() {
        #expect(Set(Persona.cast.map { $0.face(.neutral) }).count == 4)
        #expect(Persona.cast.map(\.name) == ["SENTE.SYS", "TENUKI.LOG", "MOYO.PNG", "SEKI.LCK"])
    }

    /// 局の始まりは白、黒の順に 1 言ずつ。終局は勝った側、負けた側の順。
    @Test func gamesStartWithBothSidesAndEndWithWinnerThenLoser() {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first(roster: Quick.roster, using: &generator)
        #expect(series.banter.lines.map(\.side) == [.white, .black])
        #expect(series.banter.lines.allSatisfy { $0.cue == .start })
        while case .ongoing = series.game.status {
            series = series.advanced(using: &generator)
        }
        guard case .finished(let result) = series.game.status else {
            return
        }
        #expect(series.banter.lines.map(\.side) == [result.winner, result.winner.opponent])
        #expect(series.banter.lines.map(\.cue) == [.win, .lose])
    }

    /// 同じシードからは同じ会話。
    @Test func sameSeedGivesTheSameConversation() {
        func remarks(_ seed: UInt64) -> [String] {
            var generator = SplitMix64(seed: seed)
            var series = GameSeries.first(roster: Quick.roster, using: &generator)
            var said: [String] = []
            for _ in 0..<200 {
                series = series.advanced(using: &generator)
                said.append(series.banter.lines.last?.text ?? "")
            }
            return said
        }
        #expect(remarks(8) == remarks(8))
    }

    /// 5 子以上の取りは、取られた側が必ず話す。パスは 70%・取りは 40% の確率で話す。
    @Test func bigCapturesAlwaysGetARemark() {
        var generator = SplitMix64(seed: 1)
        for _ in 0..<50 {
            let pick = Banter.pick(
                MoveFacts(mover: .black, captured: 6, isPass: false), quiet: 0, using: &generator)
            #expect(pick?.prompt == Prompt(speaker: .white, cue: .bigLoss))
        }
        var passes = 0
        for _ in 0..<1_000
        where Banter.pick(MoveFacts(mover: .white, captured: 0, isPass: true), quiet: 3, using: &generator) != nil {
            passes += 1
        }
        #expect((600...800).contains(passes))
    }
}
