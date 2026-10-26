import NeNeIgoCore

/// 盤を描くのに要る値の組（`BoardFrame` の中だけ）。
struct BoardScene {
    let position: Position
    let last: Point?
    let theme: Theme
}
