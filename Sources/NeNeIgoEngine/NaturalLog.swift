/// 自然対数（Foundation を使わずに UCT の ln を求める・ARC-003）。
///
/// x = m × 2^e（m は 1 以上 2 未満）に分け、ln x = e × ln 2 + ln m。ln m は atanh の級数（収束が速い範囲だけを使う）。
enum NaturalLog {
    private static let ln2 = 0.693_147_180_559_945_3

    static func ln(_ value: Double) -> Double {
        precondition(value > 0, "正の数だけ")
        let exponent = Double(value.exponent)
        let mantissa = value.significand
        let y = (mantissa - 1) / (mantissa + 1)
        let y2 = y * y
        var term = y
        var sum = 0.0
        var n = 1.0
        for _ in 0..<12 {
            sum += term / n
            term *= y2
            n += 2
        }
        return exponent * ln2 + 2 * sum
    }
}
