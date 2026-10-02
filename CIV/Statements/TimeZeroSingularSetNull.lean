-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Main.TimeZeroSingularSetNull
public import CKN.Statements.SuitableWeakSolution
public import CIV.Statements.ForceC2Bounded
public import CIV.Statements.GlobalEnergyClass
public import CIV.Statements.SingularSlice
public import CIV.Statements.UnitCylinder
public import Mathlib.MeasureTheory.Measure.Hausdorff

@[expose] public section

open MeasureTheory Set
open scoped ENNReal
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Partial regularity at the blow-up time (the manuscript's `H¹(S₀) = 0`, obtained there from
Caffarelli–Kohn–Nirenberg / Gustafson–Kang–Tsai applied at points of the top boundary of `Q`):
the set of points `x ∈ B(1)` near which `u` is unbounded as `t ↑ 0` has one-dimensional
Hausdorff measure zero.

This statement bundles CKN's partial regularity together with the Gustafson–Kang–Tsai criterion
(their Theorem 1.1(ii)) applied at the points `(x, 0)` of the top boundary of `Q`, which the
footnote in the proof of `lem:aniso:annulus` justifies from the structure of their proof
(backward cylinders inside `Q` and a local energy inequality that, for a pair smooth on
compact subsets of `Q`, is an identity at every `s < 0`); see design note R12. The proof uses less: see
deviation D7 in `docs/DEVIATIONS.md`. -/
theorem timeZeroSingularSetNull (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : CKN.IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (hMf : ForceC2Bounded f) :
    μH[1] (singularSlice u ∩ vec3Ball 0 1) = 0 :=
by exact CIV.Main.timeZeroSingularSetNull q u Du p f hsol henergy hu hp hf hMf

end CIV
