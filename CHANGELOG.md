# Changelog

All notable changes to `donna` will be documented in this file.

## Unreleased

### Fixed

- Generated project GitHub Actions now install QBE using Donna's maintained `install-qbe` script before running `donna format`, `donna check`, and `donna test`.
- `donna check` now works for multi-module libraries without requiring a root `src/<name>.donna` file.
- Type diagnostics from `donna check`, `donna build`, and `donna test` no longer get wrapped with an extra `error: type error in ...` prefix.
- Missing module calls such as `string.to_slug(...)` without `import donna/string` are covered by a regression test and report `undefined module` with a source span and hint.

### Enhancements

- `donna clean` now supports `--docs`, `--lock`, and `--all` for removing generated docs and lockfiles explicitly.
- Compiler diagnostics now use light-blue gutter/source-location styling and an orange `hint:` label to match the website error style.

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
