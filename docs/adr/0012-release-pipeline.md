# ADR 0012 — 版の入力は Version.swift の 1 か所、配布物は静的リンクの 1 経路で作り、検査してから梱包する

- 状態: 受理
- 日付: 2026-10-26
- Issue: #13
- 影響する規則: ARC-006 / QLT-011 / QLT-014

## 文脈

WORK-ORDER の Phase 4: 版の入力 1 か所・`make release TAG=v<版>`・成果物の検査・`SHA256SUMS`・`install.sh`・README（英語が正・`README.ja.md`・先頭に実機の画面写真）。
SwiftPM の manifest には製品の版の欄が無い。既定の `swift build -c release` は Swift のランタイムに動的に依存し、Swift の入っていない WSL では起動しない（兄弟の NeNe Gambit の実測・Gambit ADR 0012）。
兄弟の Gambit が同じ経路を v0.1.1 まで使っている。配布の形は Gambit から移植してよい（WORK-ORDER 第 2-5 節）。

## 決定

Gambit ADR 0012 の決定 1〜5 を、名前を合わせて引き継ぐ。移植元は Gambit のコミット 64b82ec の `Sources/nene-gambit/Version.swift`・`eng/package-release.sh`・
`eng/release/README.txt`（中身は囲碁で書き直した）・`install.sh`・README の構成。

1. 版の入力は `Sources/nene-igo/Version.swift` の `Version.current`（`0.1.0`）の 1 か所。`nene-igo --version` はそこから `nene-igo <版>` の 1 行を出す
   （ARC-006 の「合成ルートが出してよい 1 行」に `--version` を足す）
2. 配布物は `eng/package-release.sh [v<版>]`（`make release TAG=v<版>`）だけが作る。別のビルドディレクトリ（`.release/build`）で規約検査・release 構成のテスト・
   `--static-swift-stdlib` のビルドを通し、`strip` してから検査する: x86-64 の ELF・動的依存が `ld-linux-x86-64.so.2` `libc.so.6` `libgcc_s.so.1` `libm.so.6` `libstdc++.so.6` の中だけ・
   `--version` が版と一致・タグが版と一致・同梱物が `nene-igo` `README.txt` `LICENSE` の 3 つと完全一致
3. 梱包は再現できる形（tar の並び・時刻・持ち主を固定・gzip の時刻を入れない）。`SHA256SUMS` をスクリプトが書く
4. `install.sh` は最新の Release（か `NENE_IGO_VERSION`）を落とし、`SHA256SUMS` で照合してから `~/.local/bin/nene-igo` に入れる。照合に失敗したら何も入れない
5. 公開は squash 統合後の clean な `main` から同じスクリプトで作り直し、短い起動を確かめてから `v<版>` のタグと同名の Release に配布物と `SHA256SUMS` を添付し、再ダウンロードして照合する。
   **公開（タグの push と Release の作成）は外に出る操作なので、施主の確認を取ってから行う**（REQUIREMENTS の Q9）
6. README の画面写真は実機（Windows Terminal）で撮ったものだけを置く（`docs/images/`。合成しない）。撮り方は ADR 0009 の「結果」

## 強制

- **active**（QLT-014）: 証明 P51（タグの不一致）・P52（静的リンクを外すと Swift のランタイムへの動的依存で落ちる）・P53（余計な同梱物）・P54（`--version` の不一致）
- `install.sh` の照合は、公開した Release に対して使い捨ての環境で確かめる（公開の後。この ADR の時点では未）

## 結果

- 実測（2026-10-26・WSL2 Ubuntu 22.04・Swift 6.4.1・この PR の木）: `make release TAG=v0.1.0` は `nene-igo-0.1.0-linux-x86_64.tar.gz`（2,617,759 バイト）と
  `SHA256SUMS`（`639c0601d5f2e6775a9bda471a45143ead63a48657b467fa6f5c13b268ea697b`）を作り、2 回作って同じ SHA-256 になった。動的依存は許可した 5 つだけ
- Swift の入っていない使い捨てのコンテナ（`ubuntu:22.04`）で、配布物の照合（`sha256sum --check`）・展開・`--version`（`nene-igo 0.1.0`）・`eng/smoke-terminal.py` の全項目が通った。
  `install.sh` の 1 行からの導入は、Release を公開してから確かめる（未）
- `.release/` を生成物の置き場として `.gitignore` に足した（CNF-005 の許可にも足した）
- 公開スクリプトは別のビルドディレクトリでテストからやり直すので数分かかる。フルゲートの代わりではない
- README の写真は v0.1.0 の直前のビルド（画面・探索・セリフは v0.1.0 と同じ。違いは `--version` と TENUKI.LOG のセリフ 1 本）で撮った。公開した版で撮り直すのは公開の後

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 版を `VERSION` ファイルに置き、ビルド時に読む | SwiftPM でビルド時にファイルを読むにはビルドプラグインが要る（SWF-009 で禁止） |
| 版を git のタグから取る | タグの無い木で `--version` が決まらない |
| Swift のランタイムを同梱して動的リンクのまま配る | 同梱物と `LD_LIBRARY_PATH` の扱いが増える。静的リンクなら 1 ファイルで動く |
| CI で Release を自動で作る | 公開は施主の確認を取る外の操作（Q9）。CI に品質判断以外の仕事を足さない（CNF-018） |
