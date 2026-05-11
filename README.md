# The Donna Programming Language
<img width="200" align="right" alt="Donna" src="assets/logo.png" />

<img src="https://img.shields.io/badge/Donna-The_Correct_Way_to_Code-FF6347?style=for-the-badge" alt="Donna"/>
<img src="https://img.shields.io/badge/Language_Tour-Read-2F81F7?style=for-the-badge" alt="Language Tour"/><a href="https://github.com/donna-lang/donna/releases"><img src="https://img.shields.io/github/v/release/donna-lang/donna?style=for-the-badge&color=FF6347&label=Release" alt="Latest release"/></a><a href="https://github.com/donna-lang/donna/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/donna-lang/donna/test.yml?branch=main&label=Tests&style=for-the-badge" alt="Tests"/></a><img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey?style=for-the-badge" alt="Platform"/><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>

---

Donna is a small, sharp, indentation-based functional language that likes native binaries, tidy code, and getting out of your way. It compiles through [QBE](https://c9x.me/compile/), brings Hindley-Milner type inference, algebraic data types, pattern matching, and no dramatic ceremony.

> "I'm Donna." — Donna Paulsen

## Install

### Prebuilt binaries

Download the latest archive for your platform from [Releases](https://github.com/donna-lang/donna/releases).

Extract it and put the `donna` binary on your `PATH`:

```sh
chmod +x donna
mv donna /usr/local/bin/donna
```

Check the install:

```sh
donna version
```

Donna also needs QBE and a C compiler available on your `PATH` when compiling projects.

### Build from source

Dependencies:

- QBE
- a C compiler (`cc`, `clang`, `gcc`, or `zig cc`)
- `make`
- `git`

Then:

```sh
git clone https://github.com/donna-lang/donna.git
cd donna
make build
```

The binary will be created at:

```sh
build/bin/donna
```

### Windows

Windows users should download the Windows `.zip` from [Releases](https://github.com/donna-lang/donna/releases), extract it, and add the extracted folder to the user `Path`.

Donna looks for a C compiler in this order: `DONNA_CC`, `cc`, then `zig cc`.

Recommended Windows setup:

1. Install Zig and make sure `zig` is available in the terminal.
2. Or install another native C compiler and make it available as `cc`, or set `DONNA_CC`.
3. Use WSL if you prefer a Linux-like source build environment.

Native Windows source builds also need QBE and `make`.

## Quick start

```sh
donna new myapp
cd myapp
donna run
```

## Documentation

Work in Progress

## Licence

MIT
