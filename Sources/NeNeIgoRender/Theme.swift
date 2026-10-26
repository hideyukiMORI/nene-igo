import NeNeIgoCore

/// カラーテーマ。色の値を持つのはここだけ（FR-12）。12 種類で、実行中の `t` で順に替える（ADR 0011）。
///
/// 名前と地・パネル・枠・文字・控えめな文字・強調 2 色は NeNe Reversi の 12 テーマ（`Sources/NeNeReversiRender/Theme.swift`・コミット 0ee4526。
/// Reversi は NeNe Gambit の 12 テーマを写した）を写した。囲碁用に、碁盤の地・線（と星）・直前の手の印・黒石・白石の 5 色を足した（FR-12）。
/// 黒石は暗い色、白石は明るい色、碁盤の地はその間の明るさ（どちらの石も碁盤の地に対して 3:1 以上）、線と印は碁盤の地に対して 4.5:1 以上
/// （テストで確かめる）。碁盤の地は、各テーマの枠の色を白石の色へ寄せて作った（PAPER だけは紙の色に合わせた茶色）。
/// PAPER の強調の 2 色目は、パネルの帯の上で 4.5:1 に届かなかったので Reversi の 0xC7253E から 0xA81D33 へ暗くした。
public struct Theme: Sendable, Hashable {
    /// 画面と起動オプションに使う名前（`--theme NEON`）。
    public let name: String
    let ground: Rgb
    let panel: Rgb
    let frame: Rgb
    let text: Rgb
    let dim: Rgb
    let accent: Rgb
    let accentAlt: Rgb
    let board: Rgb
    let line: Rgb
    let marker: Rgb
    let blackStone: Rgb
    let whiteStone: Rgb

    /// 12 のテーマ（`t` で巡る順）。最初が既定。
    public static let catalog: [Theme] = [
        Theme(
            name: "NEON",
            hex: [
                0x05070D, 0x0A1020, 0x1E4D6B, 0xC8D3E0, 0x6B7F99, 0x00E5FF,
                0xFF2E97, 0x3D6781, 0xE4E9F0, 0x80F2FF, 0x0B0B0F, 0xEAFBFF,
            ]),
        Theme(
            name: "PHOSPHOR",
            hex: [
                0x020803, 0x061208, 0x1C4D24, 0x9CF5A8, 0x4F9A5B, 0x39FF6A,
                0xD8FF3E, 0x406D47, 0xCEFAD4, 0xD8FF3E, 0x0B0B0F, 0xE4FFE8,
            ]),
        Theme(
            name: "AMBER",
            hex: [
                0x0A0602, 0x140C04, 0x5A3A12, 0xFFC879, 0xA87A3C, 0xFFB000,
                0xFF6A1A, 0x795D37, 0xFFE4BC, 0xFFFFFF, 0x0B0B0F, 0xFFF1D6,
            ]),
        Theme(
            name: "SYNTHWAVE",
            hex: [
                0x0D0221, 0x160534, 0x4B1D7A, 0xE7D7FF, 0x9A84C4, 0xFF3CAC,
                0x00F0FF, 0x78539A, 0xF3EBFF, 0xFFFFFF, 0x0B0B0F, 0xFFF4FB,
            ]),
        Theme(
            name: "GLACIER",
            hex: [
                0x03080F, 0x08121E, 0x2A4A6A, 0xDCEBFA, 0x7E98B3, 0x7FD4FF,
                0xB6A0FF, 0x4A6580, 0xDCEBFA, 0xBFEAFF, 0x0B0B0F, 0xFFFFFF,
            ]),
        Theme(
            name: "BLOODMOON",
            hex: [
                0x080203, 0x130507, 0x5A1620, 0xF2D0D4, 0xA06A72, 0xFF2B3F,
                0xFFB347, 0x88535B, 0xF8E8EA, 0xFFFFFF, 0x0B0B0F, 0xFFF0F1,
            ]),
        Theme(
            name: "VAPOR",
            hex: [
                0x120B1F, 0x1C1230, 0x5A3F7F, 0xF3E8FF, 0xA897C4, 0x7DF9FF,
                0xFF9DE2, 0x6F5890, 0xF3E8FF, 0x7DF9FF, 0x0B0B0F, 0xFFFFFF,
            ]),
        Theme(
            name: "MONO",
            hex: [
                0x050505, 0x101010, 0x3A3A3A, 0xD9D9D9, 0x8A8A8A, 0xFFFFFF,
                0xBDBDBD, 0x636363, 0xECECEC, 0xFFFFFF, 0x0B0B0F, 0xFFFFFF,
            ]),
        Theme(
            name: "TOXIC",
            hex: [
                0x06040A, 0x0F0A16, 0x3E2A5A, 0xE2F5C8, 0x8E9A78, 0xB6FF00,
                0xC266FF, 0x6A5D7C, 0xE2F5C8, 0xB6FF00, 0x0B0B0F, 0xF4FFE6,
            ]),
        Theme(
            name: "GILDED",
            hex: [
                0x070605, 0x11100C, 0x4A3F22, 0xEDE3C8, 0x9C9278, 0xE8C15A,
                0x5AD1C8, 0x6C6247, 0xEDE3C8, 0xF4E0AC, 0x0B0B0F, 0xFFF8E6,
            ]),
        Theme(
            name: "ABYSS",
            hex: [
                0x01060A, 0x041018, 0x123A4F, 0xCBE7F2, 0x6E93A3, 0x00C2A8,
                0x3D8BFF, 0x436777, 0xCBE7F2, 0xFFFFFF, 0x0B0B0F, 0xE9FFFB,
            ]),
        Theme(
            name: "PAPER",
            hex: [
                0xF4F1EA, 0xE6E1D6, 0xB8AE9A, 0x2A2622, 0x5E564C, 0x0060C7,
                0xA81D33, 0x94876D, 0x000000, 0x4A0012, 0x1A1714, 0xF4F4F0,
            ]),
    ]

    /// 既定のテーマ。
    public static let standard = catalog[0]

    /// 名前のテーマ（大文字小文字を区別しない）。無ければ nil。
    public static func named(_ name: String) -> Theme? {
        catalog.first { $0.name == name.uppercased() }
    }

    /// `t` を押したときの次のテーマ（最後の次は最初）。
    public var next: Theme {
        let index = Self.catalog.firstIndex(of: self) ?? 0
        return Self.catalog[(index + 1) % Self.catalog.count]
    }

    /// 地・パネル・枠・文字・控えめな文字・強調 2 色・碁盤の地・線・直前の手の印・黒石・白石の順の 12 色から作る。
    private init(name: String, hex: [UInt32]) {
        precondition(hex.count == 12, "テーマの色は 12 個")
        let rgb = hex.map { Rgb(red: UInt8($0 >> 16 & 0xFF), green: UInt8($0 >> 8 & 0xFF), blue: UInt8($0 & 0xFF)) }
        self.name = name
        ground = rgb[0]
        panel = rgb[1]
        frame = rgb[2]
        text = rgb[3]
        dim = rgb[4]
        accent = rgb[5]
        accentAlt = rgb[6]
        board = rgb[7]
        line = rgb[8]
        marker = rgb[9]
        blackStone = rgb[10]
        whiteStone = rgb[11]
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

    /// HUD と COMMS でその側を表す文字の色（黒石の色は暗くて地の上で読めないので、強調の 2 色を当てる）。
    func side(_ stone: Stone) -> Rgb {
        switch stone {
        case .black:
            return accent
        case .white:
            return accentAlt
        }
    }
}
