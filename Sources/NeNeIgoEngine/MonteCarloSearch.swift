import NeNeIgoCore

/// モンテカルロ木探索（UCT）＋自分の眼を埋めないプレイアウト（FR-03・ADR 0010）。
///
/// プレイアウトの数で打ち切り、時計を知らない。乱数は引数で受け取る（同じ乱数源からは同じ手・FR-05 の決定性）。
/// 手の合法判定はすべて Core の `Game.apply`（第 2 の合法判定を作らない・ARC-001）。
public enum MonteCarloSearch {
    /// 局面で打つ手を選ぶ。終局した局は渡さない。
    public static func choose(
        _ game: Game, profile: SearchProfile, using generator: inout some RandomNumberGenerator
    ) -> Move {
        var tree = [root(of: game, using: &generator)]
        for _ in 0..<profile.playouts {
            iterate(&tree, game: game, profile: profile, using: &generator)
        }
        return pick(tree, opening: game.moves.count < profile.openingMoves, using: &generator)
    }

    /// 根の節。根の手番の側の候補を乱数の順に並べる。
    private static func root(of game: Game, using generator: inout some RandomNumberGenerator) -> TreeNode {
        TreeNode(
            move: .pass, mover: game.position.toMove.opponent, parent: -1, children: [],
            untried: candidates(game, using: &generator), visits: 0, wins: 0)
    }

    /// 1 回の選択・展開・プレイアウト・逆伝播。
    private static func iterate(
        _ tree: inout [TreeNode], game: Game, profile: SearchProfile, using generator: inout some RandomNumberGenerator
    ) {
        var node = 0
        var current = game
        while tree[node].untried.isEmpty, !tree[node].children.isEmpty {
            node = bestChild(tree, of: node, exploration: profile.exploration)
            current.apply(tree[node].move)
        }
        node = expand(&tree, node, &current, using: &generator)
        Playout.run(&current, style: profile.style, using: &generator)
        let winner = winnerOf(current)
        var walk = node
        while walk >= 0 {
            tree[walk].visits += 1
            tree[walk].wins += tree[walk].mover == winner ? 1 : 0
            walk = tree[walk].parent
        }
    }

    /// まだ試していない手を 1 つ節にする。打てない手（自殺手・スーパーコウ）は捨てて次を試す。試せる手が無ければその節のまま。
    private static func expand(
        _ tree: inout [TreeNode], _ node: Int, _ current: inout Game, using generator: inout some RandomNumberGenerator
    ) -> Int {
        while let move = tree[node].untried.popLast() {
            let mover = current.position.toMove
            guard current.apply(move) == .applied else {
                continue
            }
            let child = TreeNode(
                move: move, mover: mover, parent: node, children: [],
                untried: current.isOver ? [] : candidates(current, using: &generator), visits: 0, wins: 0)
            tree.append(child)
            tree[node].children.append(tree.count - 1)
            return tree.count - 1
        }
        return node
    }

    /// 手番の側の眼でない空点を乱数の順に並べた候補。無ければパスだけ（打てる意味のある手が無くなったらパスする）。
    static func candidates(_ game: Game, using generator: inout some RandomNumberGenerator) -> [Move] {
        let mover = game.position.toMove
        let points = game.position.emptyPoints().filter { !EyeShape.isEye($0, of: mover, in: game.position) }
        let moves = points.shuffled(using: &generator).map { Move.place($0) }
        return moves.isEmpty ? [.pass] : moves
    }

    /// UCT の値がいちばん大きい子。
    private static func bestChild(_ tree: [TreeNode], of node: Int, exploration: Double) -> Int {
        let logParent = NaturalLog.ln(Double(max(tree[node].visits, 1)))
        var best = tree[node].children[0]
        var bestValue = -Double.infinity
        for child in tree[node].children {
            let visits = Double(max(tree[child].visits, 1))
            let value = tree[child].wins / visits + exploration * SquareRoot.of(logParent / visits)
            if value > bestValue {
                best = child
                bestValue = value
            }
        }
        return best
    }

    /// 打つ手: 訪問のいちばん多い子（同数なら先に並んだ子。並びは乱数の順）。序盤は上位 3 つから訪問の数に比例した乱数で選ぶ。
    private static func pick(_ tree: [TreeNode], opening: Bool, using generator: inout some RandomNumberGenerator)
        -> Move
    {
        let ranked = tree[0].children.sorted { tree[$0].visits > tree[$1].visits }
        guard let first = ranked.first else {
            return .pass
        }
        guard opening else {
            return tree[first].move
        }
        let top = Array(ranked.prefix(3))
        let total = top.reduce(0) { $0 + tree[$1].visits + 1 }
        var roll = Int.random(in: 0..<total, using: &generator)
        for child in top {
            roll -= tree[child].visits + 1
            if roll < 0 {
                return tree[child].move
            }
        }
        return tree[first].move
    }

    private static func winnerOf(_ game: Game) -> Stone {
        switch game.status {
        case .finished(let result):
            return result.winner
        case .ongoing:
            preconditionFailure("プレイアウトは終局まで打つ")
        }
    }
}
