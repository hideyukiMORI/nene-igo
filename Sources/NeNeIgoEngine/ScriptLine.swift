/// 台本の 1 行（どの出来事で言うか・何と言うか）。移植元: NeNe Gambit `Sources/NeNeGambitEngine/ScriptLine.swift`（コミット 64b82ec）。
struct ScriptLine: Sendable, Hashable {
    let cue: Cue
    let text: String

    init(_ cue: Cue, _ text: String) {
        self.cue = cue
        self.text = text
    }
}
