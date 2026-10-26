import Testing

/// John Tromp が公表している m×n 盤の合法局面数（一次資料から写した値・ADR 0006）。
///
/// 出典（2026-10-26 に取得して写した）:
/// - https://tromp.github.io/go/legal.html （n×n の表。1: 1・2: 57・3: 12675・4: 24318165）
/// - https://tromp.github.io/go/L1.html ・ L2.html ・ L3.html ・ L4.html （1×n・2×n・3×n・4×n の表）
///
/// 数え方は出典と同じ: 盤の各点を空・黒・白のどれかにした 3^(m×n) 通りのうち、すべての連に呼吸点があるもの。
/// 手番は含めず、回転・裏返しで同じになる配置も別に数える。
struct TrompCount: Sendable, CustomTestStringConvertible {
    let width: Int
    let height: Int
    let legalPositions: Int

    var testDescription: String {
        "\(width)x\(height) = \(legalPositions)"
    }

    /// 全部の置き方を数え上げて確かめる大きさ（3^(m×n) が 4,300 万以下）。
    static let enumerated: [TrompCount] = [
        TrompCount(width: 1, height: 1, legalPositions: 1),
        TrompCount(width: 1, height: 2, legalPositions: 5),
        TrompCount(width: 1, height: 3, legalPositions: 15),
        TrompCount(width: 1, height: 4, legalPositions: 41),
        TrompCount(width: 1, height: 5, legalPositions: 113),
        TrompCount(width: 1, height: 6, legalPositions: 313),
        TrompCount(width: 1, height: 7, legalPositions: 867),
        TrompCount(width: 1, height: 8, legalPositions: 2401),
        TrompCount(width: 2, height: 2, legalPositions: 57),
        TrompCount(width: 2, height: 3, legalPositions: 489),
        TrompCount(width: 2, height: 4, legalPositions: 4125),
        TrompCount(width: 2, height: 5, legalPositions: 35117),
        TrompCount(width: 2, height: 6, legalPositions: 299681),
        TrompCount(width: 2, height: 7, legalPositions: 2_557_605),
        TrompCount(width: 2, height: 8, legalPositions: 21_826_045),
        TrompCount(width: 3, height: 3, legalPositions: 12675),
        TrompCount(width: 3, height: 4, legalPositions: 321689),
        TrompCount(width: 3, height: 5, legalPositions: 8_180_343),
        TrompCount(width: 4, height: 4, legalPositions: 24_318_165),
    ]
}
