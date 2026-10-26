/// 1 局の中で手を打てない理由（FR-02）。
public enum MoveRejection: Sendable, Hashable {
    /// 盤の上だけで決まる理由（盤の外・占有・自殺手）。
    case placement(PlacementRejection)
    /// 打った後の盤上の石の配置が、この局で前に現れた配置と同じになる（局面スーパーコウ。単純なコウを含む）。
    case superko
    /// もう終局している。
    case gameOver
}
