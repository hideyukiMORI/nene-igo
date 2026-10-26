@testable import NeNeIgoEngine

/// テストを速く回すための、プレイアウトの少ないキャスト（製品のキャストは `Persona.cast`）。
enum Quick {
    static func persona(_ name: String, playouts: Int, style: PlayoutStyle = .scatter) -> Persona {
        guard let profile = SearchProfile.make(playouts: playouts, exploration: 1.0, style: style, openingMoves: 2)
        else {
            preconditionFailure("範囲外")
        }
        return Persona.make(name: name, profile: profile)
    }

    static let roster = [
        persona("FAST.A", playouts: 3), persona("FAST.B", playouts: 3, style: .contact),
        persona("FAST.C", playouts: 3, style: .centerSeeking),
    ]
}
