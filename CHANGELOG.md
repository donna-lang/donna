# Changelog

All notable changes to `donna` will be documented in this file.

## Unreleased

### Added

- Lambda expressions now generate closure values with heap-allocated capture environments, allowing lambdas to reference values from their enclosing scope. Named functions used as values now get closure adapters so higher-order calls use the same closure ABI.

### Changed

- Updated `donna_stdlib` dependency to v0.3.1 and changed new-project templates to require `>=0.3.1`.

## [0.3.0] — 2026-05-25

### Added

- Checker now validates qualified constructor patterns (`module.Name`) against imported constructor metadata, reporting `TypeUndefinedConstructor` when the constructor is not found. Unqualified patterns (`Name`) are unchanged.
- Opaque type support: `opaque type` declares a type whose constructors are hidden from importing modules. The checker includes opaque constructors in the module interface with an `is_opaque` flag, registers them in the importing module's environment, and reports `TypeOpaqueConstructor` when a qualified pattern attempts to destructure an opaque constructor from another module. Within the defining module, opaque constructors remain fully accessible.
- Static analysis warnings are now surfaced during `donna build`, `donna check`, and `donna test`. The analyser runs on every successfully parsed module and prints warnings for: unused variables, unused parameters, unused private functions, unused imports, `todo` placeholders, and `echo` debug calls.
- Warnings are shown even on cached (incremental) builds: when a module's SSA artifact is up to date the pipeline re-lexes and re-parses the source to run the analyser, so warnings are never silently suppressed.
- Checker now detects duplicate function definitions within a module and reports `TypeDuplicateFunction` with the span of the second definition, instead of silently overwriting the first and crashing the linker with a duplicate-symbol error.
- Build and check output ends with a styled summary line: `Found N error(s) and M warning(s)`. Error counts are shown in bold red, warning counts in bold yellow; zero counts are dimmed. The line is omitted entirely when both counts are zero.

### Changed

- Interface cache format updated from `donna-iface-v1` to `donna-iface-v2`: constructor entries now carry an `is_opaque` flag. Old v1 caches are silently discarded, triggering recompilation.
- `TypedTypeDef` changed from 3 to 4 fields (added `is_opaque: Bool`). Constructor info tuples changed from `#(String, List(types.Type), Int)` to `#(String, List(types.Type), Int, Bool)` (added `is_opaque` flag). All `Env`, `ModuleInterface`, and `TypedModule` field counts remain unchanged.
- `ParseUnexpectedToken` errors now detect when the unexpected token is a reserved keyword (`as`, `case`, `fn`, `let`, `type`, etc.) and show a targeted hint: `` `let` is a reserved keyword and cannot be used as a name ``, instead of the generic "function names must start with a lowercase letter".
- Warning and error caret positions now point to the bound name or alias rather than the keyword. `let message = …` highlights `message`; `import donna/list` highlights `list`; both previously pointed at the `let` / `import` keyword token.
- Unused-import detection in the analyser now covers qualified constructor patterns (`module.Constructor` in `case` arms), type annotations in function parameters and return types, ADT constructor field types, and constant type annotations. Previously these reference sites were invisible to the analyser, causing false "unused import" warnings for imports that were genuinely used.
- Type mismatch diagnostics now use an expanded Expected/Found layout, and return-type mismatches underline the returned expression rather than the function name.
- String literal spans now cover the full literal, so diagnostics underline `"value"` instead of only the opening quote.

### Fixed

- Missing imports added across the codebase to satisfy stricter v0.2.2 release binary checks.
- `bind_pattern_typed`, `bind_pattern_typed_list`, and `bind_pattern_typed_repeated` now propagate pattern errors through the typechecker, reporting `TypeUndefinedConstructor` errors in case clauses and let-pattern statements instead of silently falling through.
- `cmd_build.donna` `iface_has_main` matched `ModuleInterface` with an extra wildcard field that no longer exists.
- `analyser.donna` was missing `import utilities/location`, preventing it from compiling. This was silent because the analyser was never called; now that it is wired in, the import is required.
- `module_qbe_prefix` in the codegen and `mod_name_to_stem` in the pipeline now replace `-` with `_` in addition to `/`. Projects whose source files contain hyphens (e.g. `error-tests.donna`) previously generated invalid QBE identifiers like `$error-tests_main`, causing a QBE "integer expected" crash. Hyphens in module names are now normalized to underscores throughout.
- Removed one genuinely unused import (`donna/list` in `typed_ast.donna`, `donna/int` in `pipeline.donna`) and prefixed two unreachable bindings (`_env4` in `checker.donna`, `_left_type` in `binop_result_type`) that were surfaced by the newly working analyser. The compiler itself now builds with zero warnings.
- `TypeNotAFunction` is now emitted when a call expression's callee is a known concrete type (`Int`, `String`, `Bool`, etc.). Previously the checker silently returned a fresh type variable, allowing `x(1, 2)` where `x: Int` to type-check without error. Calls whose callee type is still unknown (`TTypeVar`) remain silent to avoid cascading errors.
- `panic` argument is now type-checked: the message expression must be a `String`. Writing `panic 42` now reports `error: type mismatch — expected String, found Int`. Previously any expression was accepted, which would generate broken QBE passing an integer as a `%s` pointer to `fprintf`.
- `panic` is now rejected by the checker with `TypePanic`, stopping compilation with a Donna diagnostic instead of compiling to runtime output and a successful build.
- Function bodies whose inferred type differs from the declared return type now report a return-type `type mismatch` diagnostic instead of allowing bad codegen paths that could crash later.
- Undefined value names now report `TypeUndefinedVar` during checking instead of receiving an unconstrained type variable and falling through to QBE or linker failures.
- Missing members on imported modules, such as `io.stderr` when only `io.eprint` exists, now report `TypeUndefinedVar("io.stderr", ...)` before codegen instead of reaching the linker as an unresolved symbol.
- `Nil` used as a value expression is now correctly typed as `TNil` in the type environment. Previously it received a fresh type variable.
- `TypeUndefinedConstructor` hint changed from "add the missing import" (misleading when the module is already imported but the constructor name is wrong) to "check the constructor name is spelled correctly and the right module is imported".

## [0.2.2] — 2026-05-19
- Fix a bug in doc generation 

## [0.2.1] — 2026-05-19

### Changed

- All type variants in `ast.donna` now use labeled fields (`is_pub`, `is_extern`, `is_opaque`, etc.) while keeping positional pattern matching working.
- Updated `donna_stdlib` dependency to v0.3.0 with `io`/`path` modules.
- `pipeline.donna` uses `path.join`/`basename`/`drop_extension` (moved from `files` in stdlib v0.3.0).
- Replaced all `echo` built-in calls with `io.print`/`io.println` across the codebase; `echo` is now a debug-only option.
- All `io.print` calls in `logger.donna` and `donna.donna` changed to `io.println` for proper newline-separated CLI output.
- Test runner template now uses `io.println` (maps to `puts`) with concatenation inside the call so test names and durations appear in output.

### Fixed

- Removed unused imports, prefixed unused parameters with `_`, and prefixed unused functions with `_` throughout.
- Test runner no longer drops test names and durations (concatenation was dead code outside the `println` call).
- `tester_test` expected template updated to match `io.println` output.

## [0.2.0] — 2026-05-18

### Added

- `donna build --release` now writes optimized application binaries under `build/release/target/<target>/bin/`.
- `donna build --release --target=<target>` supports QBE targets `amd64_sysv`, `amd64_apple`, `amd64_win`, `arm64`, and `arm64_apple`, with `amd64` as the Linux x86_64 directory alias.
- `donna build --release --target=all` builds every supported release target except `rv64`.
- `donna deps clean`, `donna deps update [NAME]`, and `donna deps tree` manage package caches, refresh lockfiles, and inspect resolved dependencies.
- Type variant declarations support optional field labels such as `Some(value: a)` while keeping constructor calls positional.
- Module interfaces are now cached beside SSA artifacts as `.iface` files, so unchanged modules can skip lexing, parsing, and typechecking on later checks and builds.

### Changed

- Release builds prefer `zig cc` when `DONNA_CC` is not set, giving cross-target builds a predictable compiler path while keeping normal `donna build` behavior unchanged.
- `donna test` now compiles only the transitive local source modules imported by the selected test files, reducing runner build time for large projects and filtered test runs.
- `donna test` now avoids rewriting unchanged generated runner and scrubbed SSA files, and reuses the existing test executable when all link inputs are current.
- `donna check` success summaries now use the same aligned orange action-label style as the rest of the CLI output.
- `donna format`, `donna docs`, and `donna test` status lines now use the same aligned orange action-label style as build/check output.

### Fixed

- Cyclic dependencies are now reported as Donna dependency errors before build/check/test reach compilation or linking.
- Build, test, and format now preserve lexer/parser diagnostics with source snippets instead of collapsing them into `parse error: <file>`.
- Build and test linker failures now include the C compiler command, linker output, and a Donna hint instead of a plain `linker failed`.
- Doc generation now calls the current parser API, fixing stale cached builds that could hide a wrong-arity parser call until a full test compile.
- `donna test` now avoids linking the git `donna` package when testing `donna_stdlib` itself, preventing duplicate standard-library symbols from transitive dev dependencies.
- Function and constructor calls with the wrong number of arguments now produce a Donna type error instead of reaching codegen with invalid call data.

## [0.1.3] — 2026-05-16

### Fixed

- Path and git dependencies now resolve their own transitive `[dependencies]`, so packages can import modules from dependencies of dependencies without the root project declaring each one directly.
- Qualified constructor calls and patterns now use module-aware constructor metadata, fixing collisions such as `sqlite.Text` and `mustache.Text` in the same module.

## [0.1.2] — 2026-05-15

### Fixed

- Git package caches are now refreshed when resolving unlocked dependencies, so a stale `~/.donna/packages/<name>` checkout no longer hides newer matching tags or branches.
- QBE installation now prefers system packages when available and falls back to QBE's official git repository, avoiding the flaky self-hosted mirror in CI.
- `donna new` now generates a CI workflow that installs QBE directly instead of checking out the Donna compiler just to run `make install-qbe`.
- QBE backend failures now stop `donna build` and `donna test` with a Donna error instead of continuing to a misleading linker failure.
- `donna test` now reports public test functions that do not end with `_test` before generating the runner, avoiding unresolved-symbol linker errors.
- `codesign` is only attempted on macOS, so Linux and other platforms do not run macOS-specific signing commands.
- Float fields in constructors and generic constructor calls now use the correct QBE ABI, fixing cases such as `Parsed(Float)`.

## [0.1.1] — 2026-05-11

### Fixed

- Generated project GitHub Actions now install QBE using Donna's maintained `install-qbe` script before running `donna format`, `donna check`, and `donna test`.
- `donna check` now works for multi-module libraries without requiring a root `src/<name>.donna` file.
- Type diagnostics from `donna check`, `donna build`, and `donna test` no longer get wrapped with an extra `error: type error in ...` prefix.
- Missing module calls such as `string.to_slug(...)` without `import donna/string` are covered by a regression test and report `undefined module` with a source span and hint.
- CLI exit codes now correctly fail for structured diagnostics and plain lex/parse errors after diagnostic prefix cleanup.

### Enhancements

- `donna clean` now supports `--docs`, `--lock`, and `--all` for removing generated docs and lockfiles explicitly.
- Compiler diagnostics now use light-blue gutter/source-location styling and an orange `hint:` label to match the website error style.
- Add octal and scientific notation number formats.

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
