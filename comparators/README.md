# Independent statements and proof comparison

[AxisymmetricChallenge.lean](AxisymmetricChallenge.lean) states five results of Constantin–Ignatova–Vicol
(arXiv:2609.20803) using only Mathlib imports. It contains every definition the
statements mention, including the suitable weak-solution class of the
Caffarelli–Kohn–Nirenberg formalization this library builds on. It ends with
five intentional proof placeholders. A mathematical reader can compare it with
the paper without reading the proof library.

[AxisymmetricSolution.lean](AxisymmetricSolution.lean) repeats the same definitions and statements
verbatim and proves each theorem by applying the library's statement
under `CIV/Statements/`. It does not import the Challenge. The two are separate
Lean environments, and importing both modules into one file would introduce
duplicate declarations. Each Solution proof is a bare application of the
library theorem, so it type-checks only because every Challenge definition
unfolds to the library's definition of the same name.

| Declaration in both environments | Paper | Library theorem (statement module) |
|---|---|---|
| `CIVChallenge.mainTheorem` | Theorem 1.1, `thm:main` | `CIV.mainTheorem` (`CIV/Statements/MainTheorem.lean`) |
| `CIVChallenge.axisymmetricTheorem` | Theorem 1.3, `thm:aniso:main` | `CIV.axisymmetricTheorem` (`CIV/Statements/AxisymmetricTheorem.lean`) |
| `CIVChallenge.meridionalSmallness` | Proposition 1.5, `prop:aniso:small` | `CIV.meridionalSmallness` (`CIV/Statements/MeridionalSmallnessProp.lean`) |
| `CIVChallenge.interiorAnalyticity` | Theorem 2.1, `thm:analytic:interior` | `CIV.interiorAnalyticity` (`CIV/Statements/InteriorAnalyticity.lean`) |
| `CIVChallenge.forceUnderCore` | Corollary 2.3, `cor:interior:nonanalytic` | `CIV.forceUnderCore` (`CIV/Statements/ForceUnderCore.lean`) |

The [configuration](../comparator.json) selects all five declarations for one
submission. The Challenge is 390 lines and about 20 KiB, within the
1,000-line and 100-KiB limits.

## The restated definitions

Each Challenge definition is a literal transcription of the library definition
of the same short name. None is replaced by a characterized object.

| Challenge | Library |
|---|---|
| `Vec3`, `ParabolicPoint`, `vec3EuclideanNorm`, `vec3Ball`, the `MeasurableSpace` and `MeasureSpace` instances on `ParabolicPoint` | `CKN.Foundation.Parabolic.*` |
| `spaceTimeSet`, `localBox`, `spaceTimeTestFunction`, `localLp`, `localVecLp`, `spatialPartial`, `timePartial`, `spatialSecondPartial`, `spatialGradientSq`, `IsSuitableWeakSolution` | `CKN.*` (`CKN/Statements/`) |
| `basisVec`, `HasWeakPartialDerivOn`, `HasWeakGradientOn` | `CKN.*` (`CKN/Foundation/Sobolev/`), there generic in the dimension, here at dimension 3 |
| `unitCylinder`, `multiPartial`, `meridionalPartial`, `IsClassicalSolutionOn`, `GlobalEnergyClass`, `BoundedNearOrigin`, `ForceC2Bounded`, `ForceSpatiallyAnalytic`, `AnalyticBoundOn`, `LocallyUniformlyAnalyticOn`, `rotZ`, `rotField`, `angularMean`, `IsAxisymmetricOn`, `meridional`, `AnisotropicBounds`, `radialQuotient`, `meridionalQuantity`, `MeridionalSmallness` | `CIV.*` (`CIV/Statements/`) |

The CKN library also gives `ParabolicPoint` the parabolic metric, its topology
and a Borel structure. None of the five statements uses them, so the Challenge
omits them.

## Local checks

After building the library, run:

```sh
python3 scripts/check_comparators.py
```

The checker verifies the following.

- `comparator.json` selects exactly the five theorems, with the standard axioms
  and NanoDa enabled.
- The Challenge imports only Mathlib and meets the size limits. It has exactly
  one `sorry` per theorem, and each theorem's whole proof is `by sorry`.
- The Solution imports the five statement modules and the Challenge's Mathlib
  imports, never the Challenge.
- After comments and imports are removed, the Solution is the Challenge with
  each `by sorry` replaced by a direct application of the library theorem.
  Every definition, instance and statement is therefore shared verbatim.
- Each theorem statement is byte-identical to the statement in
  `CIV/Statements/`, after namespace prefixes are stripped.
- Both files use one namespace, no `private` names and no `set_option` other
  than `autoImplicit false`.
- The Challenge's only diagnostics are the five `sorry` warnings.
- The Solution elaborates silently under `-DwarningAsError=true`.
- `#print axioms` of each Solution theorem is exactly
  `[propext, Classical.choice, Quot.sound]`.

`--no-build` performs the source checks only. `--lake` additionally builds the
`Comparators` target (`python3 scripts/build.py Comparators`). The ordinary
`lake build` target builds only the `CIV` library.

## Upstream Comparator and NanoDa

```sh
lake exe cache get
scripts/verify_comparator.sh
```

The script builds pinned revisions of
[Comparator](https://github.com/leanprover/comparator),
[lean4export](https://github.com/leanprover/lean4export),
[NanoDa](https://github.com/robsimmons/nanoda_lib) and
[Landrun](https://github.com/zouuup/landrun), then runs `comparator.json`.
Their commit pins are recorded in the script. It needs Linux with Landlock
support, Go 1.24 or later, Rust/Cargo, Git, Python 3 and the project's Lean
toolchain. Tools are stored under
`${XDG_CACHE_HOME:-$HOME/.cache}/civ-comparator`. Set `CIV_COMPARATOR_CACHE` to
use a different directory.

Comparator checks the exported statement dependency closures, the allowed
axioms and the proofs. NanoDa independently replays the exported Solution in a
second kernel. Neither check shows that the definitions express the intended
mathematics. That requires reading the Challenge against the paper, and the
definitions are where such a reading should concentrate.
