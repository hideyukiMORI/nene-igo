import NeNeIgoCore
import Testing

/// 取り・盤の端と隅・自殺手・取りながらの一見自殺（FR-02）。局面は上の行から書く（PositionCodec）。
@Suite struct CaptureTests {
    @Test func singleStoneIsCapturedWhenItsLastLibertyIsFilled() throws {
        let game = try Fixture.game("...../...../..O../.OXO./..... O")
        let after = try Fixture.playing([try Fixture.place(2, 0)], from: game)
        #expect(after.position.state(at: try Fixture.point(2, 1)) == .empty)
        #expect(after.capturedByWhite == 1)
        #expect(after.capturedByBlack == 0)
        #expect(after.position.count(of: .black) == 0)
    }

    @Test func stoneInTheCornerHasTwoLiberties() throws {
        let game = try Fixture.game("X../O../... O")
        let after = try Fixture.playing([try Fixture.place(1, 2)], from: game)
        #expect(after.position.state(at: try Fixture.point(0, 2)) == .empty)
        #expect(after.capturedByWhite == 1)
    }

    @Test func largeChainAlongTheEdgeIsCapturedAtOnce() throws {
        let game = try Fixture.game("OOOO./XXXX./OOOO. O")
        let after = try Fixture.playing([try Fixture.place(4, 1)], from: game)
        #expect(after.capturedByWhite == 4)
        #expect(after.position.count(of: .black) == 0)
        #expect(PositionCodec.encode(after.position) == "OOOO./....O/OOOO. X")
    }

    /// 隅の点は白にとって呼吸点が無い点だが、黒の 2 つの連を同時に取るので合法。
    @Test func captureOfTwoChainsAtOnceMakesAnApparentSuicideLegal() throws {
        let game = try Fixture.game(".XO../XO.../O..../...../..... O")
        let after = try Fixture.playing([try Fixture.place(0, 4)], from: game)
        #expect(after.capturedByWhite == 2)
        #expect(after.position.state(at: try Fixture.point(0, 4)) == .white)
        #expect(after.position.state(at: try Fixture.point(1, 4)) == .empty)
        #expect(after.position.state(at: try Fixture.point(0, 3)) == .empty)
    }

    @Test func singleStoneSuicideIsRejected() throws {
        let game = try Fixture.game(".O./O../... X")
        #expect(Fixture.rejection(of: try Fixture.place(0, 2), in: game) == .placement(.suicide))
    }

    @Test func suicideOfAChainIsRejected() throws {
        let game = try Fixture.game(".XO/OO./... X")
        #expect(Fixture.rejection(of: try Fixture.place(0, 2), in: game) == .placement(.suicide))
    }

    @Test func occupiedPointIsRejected() throws {
        let game = try Fixture.game("X../.../... O")
        #expect(Fixture.rejection(of: try Fixture.place(0, 2), in: game) == .placement(.occupied))
    }

    @Test func pointOutsideTheBoardIsRejected() throws {
        let game = try Fixture.game(".../.../... X")
        #expect(Fixture.rejection(of: try Fixture.place(3, 0), in: game) == .placement(.outsideBoard))
    }

    /// 取られた側の石は、取った側のアゲハマになる。黒が取る場合も数える。
    @Test func blackCapturesAreCountedForBlack() throws {
        let game = try Fixture.game("...../...../..X../.XOX./..... X")
        let after = try Fixture.playing([try Fixture.place(2, 0)], from: game)
        #expect(after.capturedByBlack == 1)
        #expect(after.capturedByWhite == 0)
    }
}
