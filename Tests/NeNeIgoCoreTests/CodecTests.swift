import NeNeIgoCore
import Testing

/// 局面の文字列表現（ADR 0005）。読んで書くと同じ文字列に戻り、読めない文字列は閉じた理由で返る。
@Suite struct CodecTests {
    @Test(arguments: [
        ".../.../... X",
        "X../O../... O",
        ".XO./XO.O/.XO./.... X",
        "OOOOO/OXXXO/.X.OO X",
        String(repeating: "...................", count: 1) + String(repeating: "/...................", count: 18)
            + " O",
    ])
    func decodingThenEncodingGivesTheSameText(_ text: String) throws {
        #expect(PositionCodec.encode(try Fixture.position(text)) == text)
    }

    @Test func rowsAreWrittenFromTheTopAndPointsFromTheLeft() throws {
        let position = try Fixture.position("X../.../..O X")
        #expect(position.state(at: try Fixture.point(0, 2)) == .black)
        #expect(position.state(at: try Fixture.point(2, 0)) == .white)
        #expect(position.size.width == 3)
        #expect(position.size.height == 3)
    }

    @Test(arguments: [
        ("", PositionDecodeRejection.malformed),
        (".../.../...", .malformed),
        (".../.../...  X", .malformed),
        (".../.../... B", .unknownSideToMove),
        ("../.../... X", .unevenRows),
        (" X", .unsupportedSize),
        ("..................../ X", .unevenRows),
        ("....................", .malformed),
        (".x./.../... X", .unknownCharacter),
        ("XO X", .chainWithoutLiberty),
    ])
    func unreadableTextIsRejectedWithAReason(_ text: String, _ reason: PositionDecodeRejection) {
        #expect(PositionCodec.decode(text) == .rejected(reason))
    }

    @Test func boardWiderThanNineteenIsRejected() {
        #expect(PositionCodec.decode(String(repeating: ".", count: 20) + " X") == .rejected(.unsupportedSize))
    }
}
