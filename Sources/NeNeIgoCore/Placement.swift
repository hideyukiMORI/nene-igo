/// 局面に手を打った結果（Core の中だけ。外へは `PlayOutcome` と `MoveApplication` で見せる）。
enum Placement {
    /// 打った。その手で取った石の数。
    case placed(captured: Int)
    case rejected(PlacementRejection)
}
