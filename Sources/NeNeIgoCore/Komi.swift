/// コミ: 白に足す目数。半目の単位で持ち、半目が奇数個なので引き分けは起きない（FR-04）。
public struct Komi: Sendable, Hashable {
    /// 半目の数（7.5 目なら 15）。
    public let halfPoints: Int

    /// 7.5 目（REQUIREMENTS の Q5）。
    public static let standard = Komi(halfPoints: 15)

    private init(halfPoints: Int) {
        self.halfPoints = halfPoints
    }

    /// 半目の数から作る。引き分けが起きないよう、正の奇数だけを受け付ける。
    public static func make(halfPoints: Int) -> Komi? {
        halfPoints > 0 && halfPoints % 2 == 1 ? Komi(halfPoints: halfPoints) : nil
    }
}
