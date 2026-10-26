import NeNeIgoCore

/// カラーテーマ。色の値を持つのはここだけ（FR-12）。
///
/// いまは 1 つ（Phase 3 の手順 2）。12 テーマと `t` での切り替えは手順 5 で入れる。地・文字・控えめな文字・強調は
/// NeNe Reversi の既定テーマ NEON（`Sources/NeNeReversiRender/Theme.swift`・コミット e4a6f52）を写し、碁盤の地・線・直前の手の印・石の 2 色を足した。
/// 黒石は暗い色（画面の地とは別の値）、白石は明るい色にし、碁盤の地はその間の明るさにする（どちらの石も碁盤の地に対して 3:1 以上・テストで確かめる）。
public struct Theme: Sendable, Hashable {
    /// 画面と起動オプションに使う名前。
    public let name: String
    let ground: Rgb
    let text: Rgb
    let dim: Rgb
    let accent: Rgb
    let board: Rgb
    let line: Rgb
    let marker: Rgb
    let blackStone: Rgb
    let whiteStone: Rgb

    /// 既定のテーマ。
    public static let standard = Theme(
        name: "NEON",
        hex: [0x05070D, 0xC8D3E0, 0x6B7F99, 0x00E5FF, 0x33688A, 0xD8F4FF, 0xFFF06A, 0x0C0F16, 0xEAFBFF]
    )

    /// 名前と 9 色（地・文字・控えめな文字・強調・碁盤の地・碁盤の線・直前の手の印・黒石・白石の順）から作る。
    private init(name: String, hex: [UInt32]) {
        precondition(hex.count == 9, "テーマの色は 9 つ")
        let colors = hex.map { value in
            Rgb(red: UInt8(value >> 16 & 0xFF), green: UInt8(value >> 8 & 0xFF), blue: UInt8(value & 0xFF))
        }
        self.name = name
        ground = colors[0]
        text = colors[1]
        dim = colors[2]
        accent = colors[3]
        board = colors[4]
        line = colors[5]
        marker = colors[6]
        blackStone = colors[7]
        whiteStone = colors[8]
    }

    /// 石の色。
    func color(of stone: Stone) -> Rgb {
        switch stone {
        case .black:
            return blackStone
        case .white:
            return whiteStone
        }
    }
}
