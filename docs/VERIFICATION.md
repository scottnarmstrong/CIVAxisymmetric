# Verification

Run these commands from the repository root. The toolchain and dependencies
are pinned by `lean-toolchain`, `lakefile.toml` and `lake-manifest.json`: Lean
and Mathlib at v4.35.0-rc2, and the
[Caffarelli–Kohn–Nirenberg formalization](https://github.com/scottnarmstrong/CaffarelliKohnNirenberg)
at a fixed commit.

## Install and build

With `elan` and Python 3 installed:

```sh
elan toolchain install leanprover/lean4:v4.35.0-rc2
lake exe cache get
CIV_IGNORE_PACKAGE_BUILD=1 python3 scripts/build.py CIV
```

`lake exe cache get` clones the dependencies and downloads the Mathlib build.
The CKN dependency has no binary cache: the first build compiles it from source
before the library itself. `CIV_IGNORE_PACKAGE_BUILD=1` lets this first build
create the compiled files of the two packages (their `.lake/build` trees); the
sources of both are still checked. Later builds need no variable. The root module `CIV.lean` imports the thirteen
statement modules of [CIV/Statements](../CIV/Statements), and every module of
the library is in their import closure, so this one build checks all of it.
Library warnings are treated as errors.

The build wrapper first runs the source-rule and duplicate-declaration checks.
It then checks the Lean version, the Mathlib revision and cache, the CKN
revision, and that neither package tree changes during the build (with
`CIV_IGNORE_PACKAGE_BUILD=1`, that neither package's sources change). Keep the
committed manifest and avoid `lake update` or `lake clean` during
verification. A successful build ends with:

```text
guarded local build: PASS (Mathlib and CKN package trees unchanged)
```

For a disposable checkout, CI sets `CIV_MAIN_CHECKOUT` to a different path and
uses `python3 scripts/build.py --fresh CIV`. This records the package-tree
changes of a first build (the compilation of CKN) instead of rejecting them.
Ordinary development builds use the stricter command above.

## The thirteen results and their axioms

After building the library:

```sh
probe_dir=$(mktemp -d)
cat > "$probe_dir/MainAxioms.lean" <<'LEAN'
import CIV
#print axioms CIV.mainTheorem
#print axioms CIV.axisymmetricTheorem
#print axioms CIV.meridionalSmallness
#print axioms CIV.interiorAnalyticity
#print axioms CIV.forceUnderCore
#print axioms CIV.axisMaximumPrinciple
#print axioms CIV.regularAnnulus
#print axioms CIV.comparison
#print axioms CIV.comparisonAncient
#print axioms CIV.closureLemma
#print axioms CIV.serrinInteriorEstimates
#print axioms CIV.gktCriterion
#print axioms CIV.timeZeroSingularSetNull
LEAN
scripts/lean_direct.sh "$probe_dir/MainAxioms.lean" \
  -DautoImplicit=false -DwarningAsError=true
rm -rf -- "$probe_dir"
```

Each result should list exactly `[propext, Classical.choice, Quot.sound]`,
the standard logical axioms. The CI workflow runs the same probe and fails on
any other output.

## Source checks and axioms of every declaration

```sh
python3 scripts/check_rules.py
python3 scripts/dup_decls.py
python3 scripts/check_public.py
python3 scripts/check_axioms.py --root .
```

The source checks enforce the repository conventions (copyright headers, file
length, no heartbeat overrides, no bare `linarith`, no placeholder or axiom in
the library) and reject duplicate declarations. The public-file check verifies
the allowed file types, local documentation links and library imports.

The axiom checker imports every CIV module and prints the axioms of every named
public declaration found by its source lexer. Only `propext`,
`Classical.choice` and `Quot.sound` are accepted; `sorryAx` and custom axioms
are rejected. A failed Lean probe or a nonzero exit status is a verification
failure.

## Independent theorem statements

```sh
python3 scripts/build.py Comparators
python3 scripts/check_comparators.py
```

The [Challenge](../comparators/AxisymmetricChallenge.lean) states five of the results
(`thm:main`, `thm:aniso:main`, `prop:aniso:small`, `thm:analytic:interior`,
`cor:interior:nonanalytic`) using Mathlib alone, with one intentional proof
placeholder each. The separate [Solution](../comparators/AxisymmetricSolution.lean) proves
the same named statements from the library. The local checker compares the
source texts and the theorem statements with the library's and verifies the
solutions' exact standard axiom sets; see the
[comparator guide](../comparators/README.md).

Run the upstream verification, including the independent NanoDa kernel replay:

```sh
scripts/verify_comparator.sh
```

This builds pinned verification tools in a user cache and runs them with
[comparator.json](../comparator.json). It requires Linux with Landlock support,
Go 1.24 or later, Rust/Cargo, Python 3, Git and Lean.

## Verify a fresh clone

`scripts/verify_fresh_clone.sh` creates a temporary clone, obtains the
dependency cache, and runs the builds, local comparator checks, source checks
and axiom checks above, ending with the axiom probe of the thirteen results.
Run the upstream Comparator separately as described above. The script clones
`CIV_REPO_URL` when set, or the configured `origin` remote. Use
`--expected-sha SHA` to require a particular commit, `--plan` to print the
commands, or `--keep-on-failure` to retain a failed checkout for inspection.

Compilation establishes that the proofs are accepted by Lean. Mathematical
review remains necessary to check that the formal statements and definitions
express the intended results; the [design notes](DESIGN_NOTES.md) and the
[deviations](DEVIATIONS.md) record how they relate to the paper.
