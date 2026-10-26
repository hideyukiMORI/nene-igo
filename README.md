# NeNe Igo

A terminal screensaver in which two hand-written Go (igo) AIs play each other on a 19x19 board, game after game, until you press `q`.
Written in Swift for Ubuntu on WSL2 and Windows Terminal. The AI (rules, Monte Carlo tree search, area scoring with 7.5 komi) is written from scratch,
with no external engine. It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess) and
[NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi).

🚧 **Early.** `nene-igo` draws two of four AI characters playing each other on a 19x19 board with Monte Carlo tree search,
game after game, and restores the terminal however it ends. The rules (captures, suicide, positional superko, passes, area scoring) match the counts of
legal positions on 19 small boards published by John Tromp. The themes and the banter come next.

## Development

```bash
make bootstrap   # once after cloning (commit hook and a static SwiftLint binary)
make check       # the one definition of done, identical locally and on CI
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). What the machines enforce right now is in [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md); the owner's decisions are in [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)

## License

MIT ([LICENSE](LICENSE))
