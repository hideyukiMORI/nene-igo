import NeNeIgoCore
import Testing

/// 合法局面数を、一次資料（Tromp の公表値・TrompCount）と完全に一致させる（FR-02・ADR 0006）。
@Suite struct LegalPositionCountTests {
    /// 3^(m×n) 通りの置き方を全部 `Position.make` に渡し、作れたものを数える。
    @Test(arguments: TrompCount.enumerated)
    func everyArrangementIsCountedLikeTromp(_ expected: TrompCount) throws {
        let size = try #require(BoardSize.make(width: expected.width, height: expected.height))
        var states = [PointState](repeating: .empty, count: size.pointCount)
        var legal = 0
        repeat {
            switch Position.make(size: size, states: states, toMove: .black) {
            case .made:
                legal += 1
            case .rejected:
                break
            }
        } while LegalPositionCountTests.advance(&states)
        #expect(legal == expected.legalPositions)
    }

    /// 3 進の数として 1 つ進める。全部が白になった次は false。
    private static func advance(_ states: inout [PointState]) -> Bool {
        for index in states.indices {
            switch states[index] {
            case .empty:
                states[index] = .black
                return true
            case .black:
                states[index] = .white
                return true
            case .white:
                states[index] = .empty
            }
        }
        return false
    }
}
