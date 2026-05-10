# Changelog

All notable changes to `donna` will be documented in this file.

## [0.1.0] — 2026-05-10

Initial release.

### Added

- `donna new` — create a new Donna project
- `donna build` — build libraries and application binaries
- `donna run` — build and run application projects
- `donna check` — typecheck projects with dependency resolution
- `donna test` — generate and run project test runners
- `donna docs` — generate package documentation
- `donna format` — format Donna source files
- `donna clean` — remove generated build output
- Git dependency resolution with lockfile support
- Standard library dependency support through `donna_stdlib`
- Test runner filtering, timings, and failure summaries
- Docgen support for module/function comments, examples, copy buttons, and Donna highlighting
- QBE-based native code generation
- C FFI compilation and linking
- C compiler detection with `DONNA_CC`, `cc`, and `zig cc` fallback
- Clear errors for missing QBE, missing C compiler, and projects without a `main` when using `donna run`
- Aligned CLI logging for build, check, clean, and test output

### Platform Notes

- Prebuilt binaries are intended for macOS, Linux, and Windows.
- QBE and a C compiler are required on `PATH` when compiling Donna projects.
- Windows users can use the release `.zip`; Zig is the recommended native C compiler path because Donna falls back to `zig cc` when `cc` is unavailable.
- Other native C compilers can be used through `cc` or `DONNA_CC`; WSL remains a good source-build option.
