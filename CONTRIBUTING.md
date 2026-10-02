# Contributing

This repository formalizes the main results of Constantin, Ignatova and Vicol,
arXiv:2609.20803, in Lean 4 and Mathlib, on top of the Lean formalization of the
Caffarelli–Kohn–Nirenberg theorem. The statements of the thirteen formalized
results are in [CIV/Statements](CIV/Statements).

## Development environment

Install the pinned toolchain and obtain the Mathlib cache:

```sh
elan toolchain install leanprover/lean4:v4.35.0-rc2
lake exe cache get
```

Keep the committed `lake-manifest.json`. Avoid `lake update` and `lake clean`
when verifying this version: they can change dependencies or remove the cache.
The build wrapper checks the toolchain, the Mathlib and CKN revisions and that
neither package tree changes during a build.

## Lean source conventions

Every Lean file begins with:

```lean
-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.
```

Use `set_option autoImplicit false`. Library code must contain no `sorry`,
`admit`, `sorryAx`, or custom axiom declarations. The only exceptions are the
five deliberately unproved statements of the comparator Challenge, whose
separate Solution provides the proofs.

Do not add heartbeat overrides or use bare `linarith` or `nlinarith`; use
explicit `only` arguments. Lean files must remain at most 1,500 lines. The
ambient space is the CKN formalization's `Vec3 = Fin 3 → ℝ` with
`ParabolicPoint = Vec3 × ℝ`; do not state results over `EuclideanSpace`.
The library builds with warnings treated as errors. Docstrings cite the paper
by its LaTeX labels (for example `thm:aniso:main`), never by line numbers.

## Building and checking changes

From the repository root:

```sh
python3 scripts/build.py CIV
python3 scripts/build.py Comparators
python3 scripts/check_comparators.py
python3 scripts/check_public.py
python3 scripts/check_axioms.py --root .
```

The main build runs the source-rule and duplicate-declaration checks first.
Every module of the library is in the import closure of `CIV.lean`, so the
first command builds all of it. The [verification guide](docs/VERIFICATION.md)
explains each check.

For a focused check after building the file's imports:

```sh
scripts/lean_direct.sh CIV/Statements/MainTheorem.lean \
  -DautoImplicit=false -DwarningAsError=true
```

Changes to the statements in `CIV/Statements` or to the definitions they use
need mathematical review against the paper. Update the
[comparator definitions](comparators/README.md) together with any changed
library definition and rerun both the local checks and the upstream Comparator.

## Submitting a change

Describe the mathematical or implementation change and include the relevant
build and checker results. For a new public theorem, include its
`#print axioms` output. Keep generated build files and temporary probes out of
the commit.
