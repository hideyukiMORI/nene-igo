import NeNeIgoCore

/// LOG の 1 行（`012.  Q16    D4`）。黒白 1 手ずつ（パスも手なので、手は黒から必ず交互になる）。
/// 続いている局では、次に打つ側の空きにカーソルを置く。
/// 移植元: NeNe Reversi `Sources/NeNeReversiRender/MoveLogRow.swift`（コミット 0ee4526）。番号を 3 桁にした（1 局が 400 手を超える）。
struct MoveLogRow: Sendable, Hashable {
    let number: String
    let black: String
    let white: String
    let cursor: LogCursor

    /// 直近の `count` 行。
    static func recent(_ game: Game, count: Int) -> [MoveLogRow] {
        guard count > 0 else {
            return []
        }
        let moves = game.moves.map(MoveNotation.text)
        var rows = stride(from: 0, to: moves.count, by: 2).map { index in
            MoveLogRow(
                number: label(index / 2 + 1), black: moves[index],
                white: index + 1 < moves.count ? moves[index + 1] : "", cursor: .none)
        }
        if case .ongoing = game.status {
            if moves.count % 2 == 0 {
                rows.append(MoveLogRow(number: label(moves.count / 2 + 1), black: "", white: "", cursor: .black))
            } else if let last = rows.popLast() {
                rows.append(MoveLogRow(number: last.number, black: last.black, white: "", cursor: .white))
            }
        }
        return Array(rows.suffix(count))
    }

    private static func label(_ number: Int) -> String {
        Wording.padded(number, width: 3) + "."
    }
}
