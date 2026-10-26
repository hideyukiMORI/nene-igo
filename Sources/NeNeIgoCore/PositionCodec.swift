/// 局面の文字列表現の読み書き（唯一の経路・ADR 0005）。
///
/// 形は「盤・空白 1 つ・手番」。盤は上の行（`y` が大きい側）から下の行へ `/` で区切り、各行は左から黒 `X`・白 `O`・空点 `.`。
/// 手番は `X` か `O`。例: 3 路の空の盤で黒の手番は `.../.../... X`。行の数が高さ、行の長さが幅になる。
public enum PositionCodec {
    /// 局面を文字列にする。
    public static func encode(_ position: Position) -> String {
        let size = position.size
        let rows = (0..<size.height).reversed().map { y in
            String((0..<size.width).compactMap { x in Point.at(x: x, y: y) }.map { symbol(of: position.state(at: $0)) })
        }
        return rows.joined(separator: "/") + " " + String(symbol(of: PointState.occupied(by: position.toMove)))
    }

    /// 文字列を読む。読めなければ閉じた理由で返す（例外にしない）。
    public static func decode(_ text: String) -> PositionDecodeOutcome {
        let parts = text.split(separator: " ", omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            return .rejected(.malformed)
        }
        guard let toMove = sideToMove(parts[1]) else {
            return .rejected(.unknownSideToMove)
        }
        let rows = parts[0].split(separator: "/", omittingEmptySubsequences: false).map { Array($0) }
        guard let width = rows.first?.count, rows.allSatisfy({ $0.count == width }) else {
            return .rejected(.unevenRows)
        }
        guard let size = BoardSize.make(width: width, height: rows.count) else {
            return .rejected(.unsupportedSize)
        }
        let symbols = rows.reversed().flatMap { $0 }
        let states = symbols.compactMap(state(of:))
        guard states.count == symbols.count else {
            return .rejected(.unknownCharacter)
        }
        switch Position.make(size: size, states: states, toMove: toMove) {
        case .made(let position):
            return .decoded(position)
        case .rejected(.chainWithoutLiberty):
            return .rejected(.chainWithoutLiberty)
        case .rejected(.wrongPointCount):
            preconditionFailure("行と列から数えた点の数は盤の大きさと一致する")
        }
    }

    private static func symbol(of state: PointState) -> Character {
        switch state {
        case .empty:
            return "."
        case .black:
            return "X"
        case .white:
            return "O"
        }
    }

    private static func state(of symbol: Character) -> PointState? {
        PointState.allCases.first { self.symbol(of: $0) == symbol }
    }

    private static func sideToMove(_ text: Substring) -> Stone? {
        Stone.allCases.first { String(symbol(of: PointState.occupied(by: $0))) == text }
    }
}
