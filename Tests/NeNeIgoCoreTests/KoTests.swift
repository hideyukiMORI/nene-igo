import NeNeIgoCore
import Testing

/// 単純なコウと局面スーパーコウ（FR-02）。
@Suite struct KoTests {
    /// 黒が (2,2) で白の 1 子を取ったコウ。
    static let ko = ".XO./XO.O/.XO./.... X"

    @Test func immediateRecaptureOfAKoIsRejected() throws {
        let game = try Fixture.playing([try Fixture.place(2, 2)], from: try Fixture.game(KoTests.ko))
        #expect(game.capturedByBlack == 1)
        #expect(Fixture.rejection(of: try Fixture.place(1, 2), in: game) == .superko)
    }

    @Test func recaptureAfterAnExchangeElsewhereIsLegal() throws {
        let game = try Fixture.playing(
            [try Fixture.place(2, 2), try Fixture.place(3, 0), try Fixture.place(0, 0), try Fixture.place(1, 2)],
            from: try Fixture.game(KoTests.ko))
        #expect(game.capturedByWhite == 1)
        #expect(game.position.state(at: try Fixture.point(2, 2)) == .empty)
    }

    /// コウが 2 つある盤で、黒と白が交互に別のコウを取ると、2 手前の配置に戻る手が出る。
    /// 直前の配置に戻るだけを禁じる単純なコウの規則では止まらないが、局面スーパーコウでは止まる。
    @Test func repetitionOfAnEarlierBoardIsRejectedEvenWhenItIsNotTheLastOne() throws {
        let game = try Fixture.game(".XO...XO./XO.O.X.XO/.XO...XO./......... X")
        let cycle = try Fixture.playing([try Fixture.place(2, 2), try Fixture.place(6, 2)], from: game)
        #expect(Fixture.rejection(of: try Fixture.place(7, 2), in: cycle) == .superko)
        // 白の (1,2) の取り返しは、どちらのコウも白が取った配置で、まだ現れていないので合法
        #expect(Fixture.rejection(of: try Fixture.place(1, 2), in: try Fixture.playing([.pass], from: cycle)) == nil)
    }
}
