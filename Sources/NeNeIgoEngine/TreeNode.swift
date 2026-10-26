import NeNeIgoCore

/// MCTS の木の 1 つの節（`MonteCarloSearch` の中だけ。配列の位置で親と子を指す）。
struct TreeNode {
    /// この節に入った手（根は自分の局の直前の手と無関係なのでパスを置く）。
    let move: Move
    /// この手を打った側（勝ちを数える側）。
    let mover: Stone
    let parent: Int
    var children: [Int]
    /// まだ節にしていない手（合法かは節にするときに Core で確かめる）。
    var untried: [Move]
    var visits: Int
    var wins: Double
}
