# Changelog

## 0.4.0

- Refresh deps (spellweaver, credo, dialyxir, ex_doc, igniter).
- Pass `--strict` to credo in default aliases so the strict mode (already set
  in the generated `.credo.exs`) is obvious at the call site.
- Fill out the CI template to match `mix check`: `hex.audit`, `credo --strict`,
  `spellweaver.check`, and `dialyzer` now run on the lint matrix row, and the
  build cache covers `_build` so the dialyzer PLT survives between runs.

## 0.3.0

- Improve how Igniter installer handles aliases.
- Make library compatible with precommit convention from phoenix.

## 0.2.0

- Update all linters to recent version.
- Igniter installer will now add default .cspell.json to make it less annoying.
- Igniter installer will now add default config for :bun to avoid a warning from spellweaver.

## 0.1.0

Initial release. Created the library with an install task that should inject
the desirable good practices and nuisance setup stuff for a typical library.

## 0.1.1

- Add hex.audit to default checks.
- Add spellweaver.check to default checks.
- Upgrade spellweaver to a version that is less messy.
