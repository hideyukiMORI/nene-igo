import NeNeIgoCore
import Testing

/// 中国ルールの数え方とコミ 7.5（FR-04）。局面は手で作った終局図。
@Suite struct ScoringTests {
    private func result(_ text: String) throws -> GameResult {
        GameResult.deciding(AreaScore.counting(try Fixture.position(text)), komi: .standard)
    }

    /// 石の無い盤はどちらの地でもない。コミ 7.5 で白の勝ち。
    @Test func emptyBoardIsWonByWhiteByTheKomi() throws {
        let outcome = try result(".../.../... X")
        #expect(outcome.score.black == 0)
        #expect(outcome.score.white == 0)
        #expect(outcome.winner == .white)
        #expect(outcome.marginInHalfPoints == 15)
    }

    /// 石と、その色だけに囲まれた空点を数える。黒 5 子＋地 5・白 5 子＋地 10。
    @Test func stonesAndTheirTerritoryAreCounted() throws {
        let outcome = try result(".XO../.XO../.XO../.XO../.XO.. X")
        #expect(outcome.score.black == 10)
        #expect(outcome.score.white == 15)
        #expect(outcome.winner == .white)
        #expect(outcome.marginInHalfPoints == 25)
    }

    /// 黒と白の両方に接する空点（セキの駄目と同じ扱い）は誰のものでもない。
    @Test func pointsTouchingBothColorsBelongToNobody() throws {
        let outcome = try result("X.O/X.O/X.O X")
        #expect(outcome.score.black == 3)
        #expect(outcome.score.white == 3)
        #expect(outcome.marginInHalfPoints == 15)
    }

    /// 黒の地が十分に広ければ、コミ 7.5 を引いても黒の勝ち。黒 5 子＋地 15・白 3 子（両端の空点は両方に接するので誰のものでもない）。
    @Test func blackWinsWhenItsAreaBeatsTheKomi() throws {
        let outcome = try result("...../...../...../XXXXX/.OOO. X")
        #expect(outcome.score.black == 20)
        #expect(outcome.score.white == 3)
        #expect(outcome.winner == .black)
        #expect(outcome.marginInHalfPoints == 19)
    }

    /// セキ: 黒の連と白の連が 2 つの駄目だけを分け合い、どちらも詰めると取られる。駄目は誰のものでもない。
    @Test func sekiLibertiesAreNotTerritory() throws {
        let outcome = try result("OOOOO/OXXXO/.X.OO X")
        #expect(outcome.score.black == 4)
        #expect(outcome.score.white == 9)
        let game = try Fixture.game("OOOOO/OXXXO/.X.OO O")
        let filled = try Fixture.playing([try Fixture.place(0, 0)], from: game)
        let refuted = try Fixture.playing([try Fixture.place(2, 0)], from: filled)
        #expect(refuted.capturedByBlack == 10)
    }

    @Test func komiMustBeAnOddNumberOfHalfPoints() {
        #expect(Komi.make(halfPoints: 15) == .standard)
        #expect(Komi.make(halfPoints: 14) == nil)
        #expect(Komi.make(halfPoints: 0) == nil)
    }
}
