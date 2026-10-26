NeNe Igo @VERSION@ (Linux x86_64)
==================================

A terminal screensaver in which two of four AI characters play Go (igo) on a 19x19 board
with Monte Carlo tree search, game after game, until you press q.
Area scoring (Chinese rules) with 7.5 komi.

Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04 or later),
for example Ubuntu on WSL2 in Windows Terminal. Swift is not needed (the standard library is linked statically).

Download and verify
-------------------
1. Download these two files from the GitHub Release into one folder:
     nene-igo-@VERSION@-linux-x86_64.tar.gz
     SHA256SUMS
2. Verify (it must say OK):
     sha256sum --check SHA256SUMS
3. Extract and run:
     tar -xzf nene-igo-@VERSION@-linux-x86_64.tar.gz
     ./nene-igo-@VERSION@-linux-x86_64/nene-igo

Keys
----
  q   quit
  t   next color theme (12 themes)

Options
-------
  --theme NAME          NEON PHOSPHOR AMBER SYNTHWAVE GLACIER BLOODMOON VAPOR MONO TOXIC GILDED ABYSS PAPER
  --seed N              the same seed gives the same games and the same banter
  --move-interval SEC   time between moves (default 1.0)
  --result-pause SEC    time to show the result after a game (default 3)
  --version             print the version and exit

The terminal must be at least 80x24. At 102x25 or larger the board is drawn larger.

License: MIT (see LICENSE)
Source: https://github.com/hideyukiMORI/nene-igo
