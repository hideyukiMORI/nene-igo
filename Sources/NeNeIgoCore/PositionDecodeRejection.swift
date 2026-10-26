/// 局面の文字列表現を読めない理由（ARC-008・ARC-010）。
public enum PositionDecodeRejection: Sendable, Hashable {
    /// 「盤・空白 1 つ・手番」の形でない。
    case malformed
    /// 手番が `X` でも `O` でもない。
    case unknownSideToMove
    /// 行の長さがそろっていない。
    case unevenRows
    /// 盤の大きさが 1〜19 路の範囲にない。
    case unsupportedSize
    /// 盤に `.` `X` `O` 以外の文字がある。
    case unknownCharacter
    /// 呼吸点の無い連がある。
    case chainWithoutLiberty
}
