/// プレイアウトの手の好み（FR-06・ADR 0010）。どれも候補の試す順を変えるだけで、合法判定は Core の `Game.apply` を通る。
public enum PlayoutStyle: Sendable, Hashable {
    /// 好みなし（空点から一様に選ぶ）。
    case scatter
    /// 半分の確率で、直前の手の周り 8 点から先に試す（接触して打ち合う）。
    case contact
    /// 盤の 1 線（いちばん外の線）の点を、半分の確率で選び直す（中央を好む）。
    case centerSeeking
}
