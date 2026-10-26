import NeNeIgoCore

/// 対局中の発言（COMMS）の状態。どの出来事で誰が話すかの規則はここだけにある（ADR 0011）。
///
/// - 1 手に 1 行まで。その手でいちばん優先度の高い出来事だけを見て、確率に外れたら黙る
/// - 同じ側は話してから 2 手は黙る（局の始まりと終わりは例外で、両者が続けて話す）
/// - 返しのひと言は次の 1 歩で出す。同じ人は直近 8 回と同じセリフを言わない
/// - 乱数は引数から受け取るので、同じシードからは同じ会話になる
/// 移植元: NeNe Gambit `Sources/NeNeGambitEngine/Banter.swift`（コミット 64b82ec）。出来事を囲碁のもの（取り・大きな取り・パス・静かな局面）に替えた。
public struct Banter: Sendable, Hashable {
    /// 画面に出す発言（古い順・最後の 2 つ）。
    public let lines: [Remark]
    private let recent: [String: [String]]
    private let lastSpoke: [Stone: Int]
    private let pending: Prompt?
    private let ply: Int
    /// 最後に石が取られてから打たれた手の数。
    private let quiet: Int

    static let silent = Banter(lines: [], recent: [:], lastSpoke: [:], pending: nil, ply: 0, quiet: 0)

    /// 局の始まり: 白、黒の順に 1 言ずつ。
    func starting(_ players: Players, using generator: inout some RandomNumberGenerator) -> Banter {
        let fresh = Banter(lines: lines, recent: recent, lastSpoke: [:], pending: nil, ply: 0, quiet: 0)
        return fresh.saying(Prompt(speaker: .white, cue: .start), players, using: &generator)
            .saying(Prompt(speaker: .black, cue: .start), players, using: &generator)
    }

    /// 1 手の後。終局なら両者の最後のひと言、そうでなければ規則に従って 0〜1 行。
    func reacting(
        to facts: MoveFacts, status: GameStatus, players: Players, using generator: inout some RandomNumberGenerator
    ) -> Banter {
        let ticked = Banter(
            lines: lines, recent: recent, lastSpoke: lastSpoke, pending: nil, ply: ply + 1,
            quiet: facts.captured > 0 ? 0 : quiet + 1)
        if case .finished(let result) = status {
            return ticked.saying(Prompt(speaker: result.winner, cue: .win), players, using: &generator)
                .saying(Prompt(speaker: result.winner.opponent, cue: .lose), players, using: &generator)
        }
        if let pending {
            return ticked.saying(pending, players, using: &generator)
        }
        guard let pick = Self.pick(facts, quiet: ticked.quiet, using: &generator), ticked.mayTalk(pick.prompt.speaker)
        else {
            return ticked
        }
        let spoken = ticked.saying(pick.prompt, players, using: &generator)
        return Banter(
            lines: spoken.lines, recent: spoken.recent, lastSpoke: spoken.lastSpoke, pending: pick.reply,
            ply: spoken.ply, quiet: spoken.quiet)
    }

    private func mayTalk(_ side: Stone) -> Bool {
        lastSpoke[side].map { ply - $0 > 2 } ?? true
    }

    /// 1 行を言う。直近 8 回のセリフを避けて乱数で選ぶ（全部が直近なら避けない）。
    private func saying(_ prompt: Prompt, _ players: Players, using generator: inout some RandomNumberGenerator)
        -> Banter
    {
        let persona = players.persona(for: prompt.speaker)
        let all = persona.lines(for: prompt.cue)
        let said = recent[persona.name] ?? []
        let fresh = all.filter { !said.contains($0) }
        let text = (fresh.isEmpty ? all : fresh).randomElement(using: &generator) ?? ""
        var remembered = recent
        remembered[persona.name] = Array((said + [text]).suffix(8))
        var spoke = lastSpoke
        spoke[prompt.speaker] = ply
        let remark = Remark(side: prompt.speaker, persona: persona, cue: prompt.cue, text: text)
        return Banter(
            lines: Array((lines + [remark]).suffix(2)), recent: remembered, lastSpoke: spoke, pending: nil, ply: ply,
            quiet: quiet)
    }

    /// その手でいちばん優先度の高い出来事と、その確率の抽選の結果。
    static func pick(_ facts: MoveFacts, quiet: Int, using generator: inout some RandomNumberGenerator) -> BanterPick? {
        let mover = facts.mover
        let other = mover.opponent
        let roll = Int.random(in: 0..<100, using: &generator)
        let coin = Bool.random(using: &generator)
        if facts.captured >= 5 {
            let reply = coin ? Prompt(speaker: mover, cue: .bigCapture) : nil
            return BanterPick(prompt: Prompt(speaker: other, cue: .bigLoss), reply: reply)
        }
        if facts.isPass {
            return roll < 70 ? BanterPick(prompt: Prompt(speaker: mover, cue: .pass), reply: nil) : nil
        }
        if facts.captured > 0 {
            let prompt = coin ? Prompt(speaker: mover, cue: .capture) : Prompt(speaker: other, cue: .lost)
            return roll < 40 ? BanterPick(prompt: prompt, reply: nil) : nil
        }
        if quiet > 0, quiet % 15 == 0, roll < 50 {
            return BanterPick(prompt: Prompt(speaker: other, cue: .idle), reply: nil)
        }
        return nil
    }
}
