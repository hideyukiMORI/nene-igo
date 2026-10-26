/// 平方根（ニュートン法）。`Double.squareRoot()` は release 構成で libm の `sqrt` を呼び、Glibc を import しない target
/// （Engine のテスト）ではリンクできなかった（2026-10-26 の実測・ADR 0010）。Engine は標準モジュールを import しない（ARC-003）。
enum SquareRoot {
    static func of(_ value: Double) -> Double {
        guard value > 0 else {
            return 0
        }
        var guess = Double(sign: .plus, exponent: value.exponent / 2, significand: 1)
        for _ in 0..<8 {
            guess = (guess + value / guess) / 2
        }
        return guess
    }
}
