import NeNeIgoCore

/// 誰が、どの出来事について話すか。
struct Prompt: Sendable, Hashable {
    let speaker: Stone
    let cue: Cue
}
