/// セルの文字以外の見た目（閉じた選択肢）。
public enum CellStyle: Sendable, Hashable {
    /// 飾りなし。
    case plain
    /// 下線を前景色で引く（SGR 4）。石のセルの下端に碁盤の地の色の細い線を引き、縦に並んだ石を 1 つずつ離して見せる（ADR 0009）。
    case underlined
}
