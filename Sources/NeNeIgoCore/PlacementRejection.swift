/// 盤の上だけで決まる、打てない理由（局面スーパーコウは 1 局の履歴が要るので `MoveRejection` が持つ）。
public enum PlacementRejection: Sendable, Hashable {
    /// 盤の外の点。
    case outsideBoard
    /// 石がある点。
    case occupied
    /// 何も取らずに、打った石を含む自分の連の呼吸点が 0 になる手（FR-02）。
    case suicide
}
